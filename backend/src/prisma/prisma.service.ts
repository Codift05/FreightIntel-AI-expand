import { Injectable, OnModuleInit, OnModuleDestroy, ForbiddenException } from '@nestjs/common';
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
    // Tidak ada fallback diam-diam ke perusahaan pertama. Sebelumnya baris ini
    // membuat permintaan tanpa konteks tetap membaca data perusahaan nyata,
    // sehingga kebocoran tidak terlihat. Konteks perusahaan kini selalu diisi
    // JwtAuthGuard dari dalam token; bila kosong berarti ada yang salah.
    throw new ForbiddenException(
      'Konteks perusahaan tidak ditemukan pada token. Silakan masuk ulang.',
    );
  }
}
