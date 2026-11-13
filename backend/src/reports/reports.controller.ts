import { Controller, Get, Headers, Query, Res } from '@nestjs/common';
import type { Response } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { ReportsService } from './reports.service';
import { RequirePermission } from '../auth/permissions.decorator';

type Periode = 'daily' | 'monthly' | 'yearly';

function normalisasi(p?: string): Periode {
  return p === 'daily' || p === 'yearly' ? p : 'monthly';
}

@Controller('reports')
export class ReportsController {
  constructor(
    private readonly reports: ReportsService,
    private readonly prisma: PrismaService,
  ) {}

  /** Angka laporan dalam JSON, dipakai layar Laporan di aplikasi. */
  @RequirePermission('LAPORAN_LIHAT')
  @Get()
  async summary(
    @Headers('x-company-id') companyHeader?: string,
    @Query('period') period?: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.reports.data(companyId, normalisasi(period));
  }

  @RequirePermission('LAPORAN_LIHAT')
  @Get('export.xlsx')
  async xlsx(
    @Res() res: Response,
    @Headers('x-company-id') companyHeader?: string,
    @Query('period') period?: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    const p = normalisasi(period);
    const buf = await this.reports.xlsx(companyId, p);
    res
      .header(
        'Content-Type',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      )
      .header(
        'Content-Disposition',
        `attachment; filename="Laporan-FreightIntel-${p}.xlsx"`,
      )
      .send(buf);
  }

  @RequirePermission('LAPORAN_LIHAT')
  @Get('export.pdf')
  async pdf(
    @Res() res: Response,
    @Headers('x-company-id') companyHeader?: string,
    @Query('period') period?: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    const p = normalisasi(period);
    const buf = await this.reports.pdf(companyId, p);
    res
      .header('Content-Type', 'application/pdf')
      .header(
        'Content-Disposition',
        `attachment; filename="Laporan-FreightIntel-${p}.pdf"`,
      )
      .send(buf);
  }
}
