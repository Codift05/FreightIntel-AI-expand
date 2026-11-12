import { Body, Controller, Get, Headers, Patch, Post } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { PrismaService } from '../prisma/prisma.service';
import { RequirePermission } from '../auth/permissions.decorator';

@Controller()
export class AnalyticsController {
  constructor(
    private readonly analytics: AnalyticsService,
    private readonly prisma: PrismaService,
  ) {}

  @RequirePermission('CUSTOMER_LIHAT')
  @Get('customers')
  async customers(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getCustomerAnalytics(companyId);
  }

  @RequirePermission('COST_LIHAT')
  @Get('vendors')
  async vendors(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getVendorAnalytics(companyId);
  }

  @RequirePermission('DASHBOARD_LIHAT')
  @Get('insights')
  async insights(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getInsights(companyId);
  }

  @RequirePermission('DASHBOARD_LIHAT')
  @Post('insights/ask')
  async askAi(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { question: string },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.askAi(companyId, body.question);
  }

  @Get('notifications')
  async notifications(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.listNotifications(companyId);
  }

  @Patch('notifications/read-all')
  async markAllRead(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.markAllNotificationsRead(companyId);
  }

  @RequirePermission('PENGATURAN_LIHAT')
  @Get('settings/overview')
  async settingsOverview(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getSettingsOverview(companyId);
  }

  @RequirePermission('PENGATURAN_UBAH')
  @Patch('settings/company')
  async updateCompany(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: any,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.updateCompany(companyId, body);
  }

  @RequirePermission('PENGATURAN_BUAT')
  @Post('settings/branches')
  async createBranch(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; city: string },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.createBranch(companyId, body);
  }

  @RequirePermission('PENGATURAN_BUAT')
  @Post('settings/users')
  async inviteUser(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; email: string; roleName?: string; branchName?: string },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.inviteUser(companyId, body);
  }

  @RequirePermission('PENGATURAN_BUAT')
  @Post('settings/custom-fields')
  async createCustomField(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; targetModule: string; fieldType: string; isRequired?: boolean },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.createCustomField(companyId, body);
  }
}
