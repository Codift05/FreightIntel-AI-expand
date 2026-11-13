import { Controller, Get, Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ShipmentsModule } from './shipments/shipments.module';
import { FinanceModule } from './finance/finance.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { ReportsModule } from './reports/reports.module';
import { PrismaService } from './prisma/prisma.service';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { PermissionsGuard } from './auth/permissions.guard';
import { Public } from './auth/public.decorator';

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get()
  async check() {
    const companies = await this.prisma.company.count();
    const shipments = await this.prisma.shipment.count();
    const revenues = await this.prisma.revenue.count();
    const costs = await this.prisma.cost.count();
    return {
      status: 'ok',
      service: 'FreightIntel AI Backend (NestJS + Prisma + PostgreSQL)',
      database: 'connected',
      counts: { companies, shipments, revenues, costs },
    };
  }
}

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    ShipmentsModule,
    FinanceModule,
    DashboardModule,
    AnalyticsModule,
    ReportsModule,
  ],
  controllers: [HealthController],
  // Guard global, dijalankan berurutan:
  // 1) JwtAuthGuard  - wajib token kecuali rute @Public()
  // 2) PermissionsGuard - cek izin peran bila rute memakai @RequirePermission()
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: PermissionsGuard },
  ],
})
export class AppModule {}
