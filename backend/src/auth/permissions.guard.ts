import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PrismaService } from '../prisma/prisma.service';
import { PERMISSIONS_KEY } from './permissions.decorator';

/**
 * Menegakkan izin per-peran per-modul di sisi server (FR-USR-03, FR-USR-04).
 *
 * Izin TIDAK disimpan di dalam token supaya perubahan izin lewat layar
 * "Peran & izin" langsung berlaku tanpa pengguna harus masuk ulang. Sebagai
 * gantinya izin dibaca dari basis data dan disimpan sementara di memori
 * (TTL pendek) agar tidak menambah satu query di setiap permintaan.
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  private static readonly ttlMs = 30_000;
  private readonly cache = new Map<string, { codes: Set<string>; exp: number }>();

  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  private async codesFor(userId: string): Promise<Set<string>> {
    const hit = this.cache.get(userId);
    if (hit && hit.exp > Date.now()) return hit.codes;

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        isActive: true,
        role: {
          select: {
            rolePermissions: { select: { permission: { select: { code: true } } } },
          },
        },
      },
    });
    if (!user) throw new ForbiddenException('Pengguna tidak ditemukan.');
    if (!user.isActive) {
      throw new ForbiddenException('Akun ini sudah dinonaktifkan.');
    }
    const codes = new Set(
      user.role.rolePermissions.map((rp) => rp.permission.code),
    );
    this.cache.set(userId, { codes, exp: Date.now() + PermissionsGuard.ttlMs });
    return codes;
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const required = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );
    // Rute tanpa anotasi: cukup sudah terautentikasi (JwtAuthGuard).
    if (!required?.length) return true;

    const req = context.switchToHttp().getRequest();
    const userId: string | undefined = req.user?.sub;
    if (!userId) throw new ForbiddenException('Konteks pengguna tidak ada.');

    const owned = await this.codesFor(userId);
    if (required.some((c) => owned.has(c))) return true;

    throw new ForbiddenException(
      `Peran Anda tidak punya izin untuk tindakan ini (butuh ${required.join(' atau ')}).`,
    );
  }
}
