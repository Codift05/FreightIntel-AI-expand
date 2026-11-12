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
}
