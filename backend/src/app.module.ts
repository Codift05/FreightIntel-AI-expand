import { Controller, Get, Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ShipmentsModule } from './shipments/shipments.module';
import { FinanceModule } from './finance/finance.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { PrismaService } from './prisma/prisma.service';

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

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
  ],
  controllers: [HealthController],
})
export class AppModule {}
