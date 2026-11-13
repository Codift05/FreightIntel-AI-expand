import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { FinanceService } from './finance.service';
import { PrismaService } from '../prisma/prisma.service';
import { RequirePermission } from '../auth/permissions.decorator';

@Controller('finance')
export class FinanceController {
  constructor(
    private readonly finance: FinanceService,
    private readonly prisma: PrismaService,
  ) {}

  @RequirePermission('REVENUE_LIHAT', 'COST_LIHAT')
  @Get('invoices')
  async list(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.listInvoices(companyId);
  }

  @RequirePermission('REVENUE_BUAT', 'COST_BUAT')
  @Post('invoices')
  async create(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: any,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.createInvoice(companyId, body);
  }

  @RequirePermission('REVENUE_UBAH', 'COST_UBAH')
  @Post('payments')
  async recordPayment(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { invoiceNo: string; addJt: number },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.recordPayment(companyId, body.invoiceNo, Number(body.addJt));
  }
}
