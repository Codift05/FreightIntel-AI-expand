import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { IS_PUBLIC_KEY } from './public.decorator';

/**
 * Memeriksa `Authorization: Bearer <jwt>` pada SELURUH rute kecuali yang
 * ditandai `@Public()`.
 *
 * Selain memverifikasi token, guard ini **menimpa** header `x-company-id`
 * dengan `companyId` dari dalam token. Alasannya: header dikirim oleh klien
 * sehingga bisa dipalsukan, sedangkan isi token sudah ditandatangani server.
 * Dengan begitu isolasi data antar-perusahaan (FR-CMP-05) ditentukan server,
 * dan seluruh controller yang membaca header tidak perlu diubah.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const req = context.switchToHttp().getRequest();
    const header: string | undefined = req.headers?.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token tidak ada. Silakan masuk dulu.');
    }

    try {
      const payload = await this.jwt.verifyAsync(header.slice(7).trim());
      req.user = payload;
      // Konteks perusahaan berasal dari token, bukan dari header klien.
      if (payload?.companyId) {
        req.headers['x-company-id'] = payload.companyId;
      }
      return true;
    } catch {
      throw new UnauthorizedException('Token tidak sah atau sudah kedaluwarsa.');
    }
  }
}
