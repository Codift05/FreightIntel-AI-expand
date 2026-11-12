import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Resolves active tenant `companyId` from header `x-company-id` or falls back
   * to the primary seeded company (BR-10 tenant isolation).
   */
  async resolveCompanyId(headerCompanyId?: string): Promise<string> {
    if (headerCompanyId) {
      const exists = await this.company.findUnique({ where: { id: headerCompanyId } });
      if (exists) return exists.id;
    }
    const first = await this.company.findFirst({ orderBy: { createdAt: 'asc' } });
    if (!first) throw new Error('Belum ada data perusahaan di database.');
    return first.id;
  }
}
