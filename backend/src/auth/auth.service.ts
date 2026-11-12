import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async login(email: string, password?: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: email.trim().toLowerCase() },
      include: {
        role: {
          include: {
            rolePermissions: { include: { permission: true } },
          },
        },
        company: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Email atau kata sandi tidak valid.');
    }

    if (password) {
      const valid = await bcrypt.compare(password, user.passwordHash);
      if (!valid) {
        throw new UnauthorizedException('Email atau kata sandi tidak valid.');
      }
    }

    await this.prisma.auditLog.create({
      data: {
        companyId: user.companyId,
        userId: user.id,
        actorName: user.name,
        actorRole: user.role.name,
        entity: 'AUTH',
        action: 'Login ke sistem',
        target: user.email,
      },
    });

    const payload = {
      sub: user.id,
      email: user.email,
      companyId: user.companyId,
      role: user.role.name,
    };

    return {
      accessToken: await this.jwt.signAsync(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role.name,
        branchName: user.branchName,
        company: {
          id: user.company.id,
          name: user.company.name,
          npwp: user.company.npwp,
          baseCurrency: user.company.baseCurrency,
          ppnPct: user.company.ppnPct,
        },
        permissions: user.role.rolePermissions.map((rp) => rp.permission.code),
      },
    };
  }
}
