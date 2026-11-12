import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Public } from './public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly prisma: PrismaService,
  ) {}

  @Public()
  @Post('login')
  async login(@Body() body: { email?: string; password?: string }) {
    const email = body.email || 'owner@nusantara.co.id';
    return this.auth.login(email, body.password || 'demo1234');
  }

  @Get('me')
  async me(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    const user = await this.prisma.user.findFirst({
      where: { companyId },
      include: { role: true, company: true },
    });
    return user;
  }
}
