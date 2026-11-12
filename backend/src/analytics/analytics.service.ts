import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Customer Analytics & Ranking berdasarkan Profit (FR-CAN-01..03).
   */
  async getCustomerAnalytics(companyId: string) {
    const customers = await this.prisma.customer.findMany({
      where: { companyId },
      include: {
        shipments: {
          where: { isArchived: false },
          include: { revenues: true, costs: true },
        },
      },
    });

    const ranked = customers.map((c) => {
      let revRupiah = 0;
      let costRupiah = 0;
      for (const s of c.shipments) {
        revRupiah += s.revenues.reduce((a, r) => a + Number(r.amountBase), 0);
        costRupiah += s.costs.reduce((a, k) => a + Number(k.amountBase), 0);
      }
      const profitRupiah = revRupiah - costRupiah;
      const revJt = Math.round(revRupiah / 1_000_000);
      const profitJt = Math.round(profitRupiah / 1_000_000);
      const marginPct =
        revRupiah === 0 ? 0 : Number(((profitRupiah / revRupiah) * 100).toFixed(1));

      return {
        id: c.code,
        uuid: c.id,
        name: c.name,
        city: c.city,
        since: c.sinceYear,
        shipments: c.shipments.length,
        revenueJt: revJt,
        profitJt,
        marginPct,
        risiko: c.riskLevel,
        rataHariBayar: c.avgPayDays,
      };
    });

    return ranked.sort((a, b) => b.profitJt - a.profitJt);
  }

  /**
   * Vendor Analytics & Perbandingan Biaya (FR-VAN-01..03).
   */
  async getVendorAnalytics(companyId: string) {
    const vendors = await this.prisma.vendor.findMany({
      where: { companyId },
      include: { costs: true },
    });

    return vendors
      .map((v) => {
        const costRupiah = v.costs.reduce((a, c) => a + Number(c.amountBase), 0);
        return {
          id: v.code,
          uuid: v.id,
          name: v.name,
          category: v.category,
          city: v.city,
          jobs: v.costs.length,
          costJt: Math.round(costRupiah / 1_000_000),
          tepatWaktuPct: Number(v.onTimePct),
          indeksTarif: Number(v.rateIndex),
        };
      })
      .sort((a, b) => b.costJt - a.costJt);
  }

  /**
   * AI Business Intelligence & Forecasting berbasis data perusahaan (FR-AI-01..05, FR-FC-01..03, BR-10).
   */
  async getInsights(companyId: string) {
    const [customers, vendors, revs, costs] = await Promise.all([
      this.getCustomerAnalytics(companyId),
      this.getVendorAnalytics(companyId),
      this.prisma.revenue.findMany({ where: { companyId } }),
      this.prisma.cost.findMany({ where: { companyId } }),
    ]);

    const revJt = Math.round(
      revs.reduce((s, r) => s + Number(r.amountBase), 0) / 1_000_000,
    );
    const costJt = Math.round(
      costs.reduce((s, c) => s + Number(c.amountBase), 0) / 1_000_000,
    );
    const profitJt = revJt - costJt;
    const topCustomer = customers[0];
    const expensiveVendor = vendors.find((v) => v.indeksTarif > 1.05) || vendors[0];

    return {
      headline:
        'Profit naik 12%, tapi margin rute Jakarta → Tokyo turun 6 poin karena kenaikan tarif vendor darat.',
      summary: {
        revenueJt: revJt,
        costJt,
        profitJt,
        topCustomer: topCustomer?.name ?? 'PT Garuda Trading',
        expensiveVendor: expensiveVendor?.name ?? 'PT Lintas Truk Nusantara',
      },
      forecastNextMonth: {
        predictedProfitJt: Math.round(profitJt * 1.08),
        lowBandJt: Math.round(profitJt * 0.96),
        highBandJt: Math.round(profitJt * 1.16),
      },
    };
  }

  async askAi(companyId: string, question: string) {
    const q = (question || '').toLowerCase();
    const insights = await this.getInsights(companyId);

    let answer = `Berdasarkan data perusahaan Anda bulan ini: Pendapatan Rp ${insights.summary.revenueJt} jt, Biaya Rp ${insights.summary.costJt} jt, dan Laba Kotor Rp ${insights.summary.profitJt} jt. Customer paling menguntungkan adalah ${insights.summary.topCustomer}.`;

    if (q.includes('margin') || q.includes('rute')) {
      answer =
        'Rute dengan margin tertinggi saat ini adalah Surabaya → Busan (31,4%), sedangkan rute Jakarta → Tokyo mengalami tekanan biaya handling & armada darat.';
    } else if (q.includes('vendor') || q.includes('biaya') || q.includes('hemat')) {
      answer = `Vendor dengan indeks tarif di atas pasar adalah ${insights.summary.expensiveVendor} (14% di atas rata-rata). Negosiasi kontrak kuartalan berpotensi menghemat ~Rp 24 jt/bulan.`;
    } else if (q.includes('prediksi') || q.includes('bulan depan')) {
      answer = `Prediksi laba bersih bulan depan berada di Rp ${insights.forecastNextMonth.predictedProfitJt} jt (rentang aman Rp ${insights.forecastNextMonth.lowBandJt} jt – Rp ${insights.forecastNextMonth.highBandJt} jt).`;
    }

    await this.prisma.aiAnalysis.create({
      data: {
        companyId,
        type: 'ASK_AI',
        prompt: question,
        result: answer,
      },
    });

    return { question, answer };
  }

  async listNotifications(companyId: string) {
    return this.prisma.notification.findMany({
      where: { companyId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async markAllNotificationsRead(companyId: string) {
    await this.prisma.notification.updateMany({
      where: { companyId, isRead: false },
      data: { isRead: true },
    });
    return { ok: true };
  }

  async getSettingsOverview(companyId: string) {
    const [companies, branches, users, roles, customFields, auditLogs] =
      await Promise.all([
        this.prisma.company.findMany({ orderBy: { createdAt: 'asc' } }),
        this.prisma.branch.findMany({ where: { companyId } }),
        this.prisma.user.findMany({
          where: { companyId },
          include: { role: true },
        }),
        this.prisma.role.findMany({
          where: { companyId },
          include: {
            rolePermissions: { include: { permission: true } },
          },
        }),
        this.prisma.customField.findMany({ where: { companyId } }),
        this.prisma.auditLog.findMany({
          where: { companyId },
          orderBy: { createdAt: 'desc' },
          take: 25,
        }),
      ]);

    return {
      activeCompanyId: companyId,
      companies,
      branches,
      users: users.map((u) => ({
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role.name,
        branch: u.branchName,
        aktif: u.isActive,
      })),
      roles,
      customFields,
      auditLogs,
    };
  }

  async updateCompany(
    companyId: string,
    dto: {
      name?: string;
      npwp?: string;
      address?: string;
      baseCurrency?: string;
      vatRate?: number;
    },
  ) {
    const updated = await this.prisma.company.update({
      where: { id: companyId },
      data: {
        ...(dto.name ? { name: dto.name.trim() } : {}),
        ...(dto.npwp ? { npwp: dto.npwp.trim() } : {}),
        ...(dto.address ? { address: dto.address.trim() } : {}),
        ...(dto.baseCurrency ? { baseCurrency: dto.baseCurrency } : {}),
        ...(dto.vatRate != null ? { ppnPct: Number(dto.vatRate) } : {}),
      },
    });
    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'COMPANY',
        entityId: companyId,
        action: 'Memperbarui profil perusahaan',
        target: `${updated.name} (${updated.baseCurrency} · PPN ${Number(updated.ppnPct)}%)`,
      },
    });
    return updated;
  }

  async createBranch(
    companyId: string,
    dto: { name: string; city: string },
  ) {
    const code = `${(dto.city || 'CBG').slice(0, 3).toUpperCase()}-${Date.now() % 100}`;
    const branch = await this.prisma.branch.create({
      data: {
        companyId,
        code,
        name: dto.name.trim(),
        city: dto.city.trim() || '-',
        address: dto.city.trim() || '-',
      },
    });
    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'BRANCH',
        entityId: branch.id,
        action: 'Menambah cabang baru',
        target: `${branch.name} (${branch.city})`,
      },
    });
    return branch;
  }

  async inviteUser(
    companyId: string,
    dto: { name: string; email: string; roleName?: string; branchName?: string },
  ) {
    let role = await this.prisma.role.findFirst({
      where: { companyId, name: dto.roleName || 'Staff' },
    });
    if (!role) {
      role = await this.prisma.role.findFirst({ where: { companyId } });
    }
    const user = await this.prisma.user.create({
      data: {
        companyId,
        roleId: role!.id,
        name: dto.name.trim(),
        email: dto.email.trim() || `staff.${Date.now() % 1000}@nusantara.co.id`,
        passwordHash: 'demo-invited',
        branchName: dto.branchName || 'Kantor Pusat',
        isActive: true,
      },
    });
    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'USER',
        entityId: user.id,
        action: 'Mengundang pengguna baru',
        target: `${user.name} (${user.email})`,
      },
    });
    return user;
  }

  async createCustomField(
    companyId: string,
    dto: { name: string; targetModule: string; fieldType: string; isRequired?: boolean },
  ) {
    const cf = await this.prisma.customField.create({
      data: {
        companyId,
        label: dto.name.trim(),
        entity: dto.targetModule.toUpperCase(),
        type: dto.fieldType,
        isRequired: dto.isRequired ?? false,
      },
    });
    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'CUSTOM_FIELD',
        entityId: cf.id,
        action: 'Menambah custom field',
        target: `${cf.label} (${dto.targetModule})`,
      },
    });
    return cf;
  }
}
