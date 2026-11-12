import { Controller, Get, Headers, Query } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { PrismaService } from '../prisma/prisma.service';

@Controller('dashboard')
export class DashboardController {
  constructor(
    private readonly dashboard: DashboardService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  async getSummary(
    @Headers('x-company-id') companyHeader?: string,
    @Query('period') period?: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.dashboard.getSummary(companyId, period || 'monthly');
  }
}
