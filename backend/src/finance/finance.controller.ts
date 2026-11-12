import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { FinanceService } from './finance.service';
import { PrismaService } from '../prisma/prisma.service';

@Controller('finance')
export class FinanceController {
  constructor(
    private readonly finance: FinanceService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('invoices')
  async list(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.listInvoices(companyId);
  }

  @Post('invoices')
  async create(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: any,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.createInvoice(companyId, body);
  }

  @Post('payments')
  async recordPayment(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { invoiceNo: string; addJt: number },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.finance.recordPayment(companyId, body.invoiceNo, Number(body.addJt));
  }
}
