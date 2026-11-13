import { Body, Controller, Get, Headers, Param, Patch, Post, Query } from '@nestjs/common';
import { ShipmentsService } from './shipments.service';
import { PrismaService } from '../prisma/prisma.service';
import { RequirePermission } from '../auth/permissions.decorator';

@Controller('shipments')
export class ShipmentsController {
  constructor(
    private readonly shipments: ShipmentsService,
    private readonly prisma: PrismaService,
  ) {}

  @RequirePermission('SHIPMENT_LIHAT')
  @Get()
  async list(
    @Headers('x-company-id') companyHeader?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.shipments.findAll(companyId, {
      page: page ? Number(page) : 0,
      pageSize: pageSize ? Number(pageSize) : 20,
      status,
      search,
    });
  }

  @RequirePermission('SHIPMENT_LIHAT')
  @Get(':id/pnl')
  async getPnl(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Param('id') id: string,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.shipments.findOnePnl(companyId, id);
  }

  @RequirePermission('SHIPMENT_BUAT')
  @Post()
  async create(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body()
    body: {
      customerName: string;
      type: string;
      origin: string;
      destination: string;
      container?: string;
      etd?: string;
      eta?: string;
    },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.shipments.create(companyId, body);
  }

  @RequirePermission('SHIPMENT_UBAH')
  @Patch(':id')
  async update(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.shipments.update(companyId, id, body);
  }
}
