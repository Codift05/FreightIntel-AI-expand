import { Body, Controller, Get, Headers, Patch, Post } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { PrismaService } from '../prisma/prisma.service';

@Controller()
export class AnalyticsController {
  constructor(
    private readonly analytics: AnalyticsService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('customers')
  async customers(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getCustomerAnalytics(companyId);
  }

  @Get('vendors')
  async vendors(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getVendorAnalytics(companyId);
  }

  @Get('insights')
  async insights(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getInsights(companyId);
  }

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

  @Get('settings/overview')
  async settingsOverview(@Headers('x-company-id') companyHeader?: string) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.getSettingsOverview(companyId);
  }

  @Patch('settings/company')
  async updateCompany(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: any,
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.updateCompany(companyId, body);
  }

  @Post('settings/branches')
  async createBranch(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; city: string },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.createBranch(companyId, body);
  }

  @Post('settings/users')
  async inviteUser(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; email: string; roleName?: string; branchName?: string },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.inviteUser(companyId, body);
  }

  @Post('settings/custom-fields')
  async createCustomField(
    @Headers('x-company-id') companyHeader: string | undefined,
    @Body() body: { name: string; targetModule: string; fieldType: string; isRequired?: boolean },
  ) {
    const companyId = await this.prisma.resolveCompanyId(companyHeader);
    return this.analytics.createCustomField(companyId, body);
  }
}
