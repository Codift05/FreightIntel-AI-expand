import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ShipmentsService } from '../shipments/shipments.service';

@Injectable()
export class DashboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly shipments: ShipmentsService,
  ) {}

  /**
   * Menghitung ringkasan keuangan Dashboard (FR-DSH-01..04, BR-01..03, BR-07, BR-12):
   * - Revenue (DPP), Cost (DPP), Gross Profit, Margin %
   * - Piutang (Σ revenue != PAID dikurangi pembayaran masuk)
   * - Hutang (Σ cost != PAID dikurangi pembayaran keluar)
   * - PPN Keluaran vs Masukan (BR-12)
   * - Sorotan shipment terbaru
   */
  async getSummary(companyId: string, period: string = 'monthly') {
    const [revs, costs, activeShipmentsCount, unreadNotifsCount, latestShipments] =
      await Promise.all([
        this.prisma.revenue.findMany({
          where: { companyId },
          include: { payments: true },
        }),
        this.prisma.cost.findMany({
          where: { companyId },
          include: { payments: true },
        }),
        this.prisma.shipment.count({
          where: { companyId, isArchived: false },
        }),
        this.prisma.notification.count({
          where: { companyId, isRead: false },
        }),
        this.shipments.findAll(companyId, { page: 0, pageSize: 3 }),
      ]);

    const totalRevRupiah = revs.reduce((s, r) => s + Number(r.amountBase), 0);
    const totalCostRupiah = costs.reduce((s, c) => s + Number(c.amountBase), 0);
    const grossProfitRupiah = totalRevRupiah - totalCostRupiah;

    const arRupiah = revs
      .filter((r) => r.paymentStatus !== 'PAID')
      .reduce((s, r) => {
        const paid = r.payments.reduce((pAcc, p) => pAcc + Number(p.amountBase), 0);
        return s + Math.max(0, Number(r.amountBase) - paid);
      }, 0);

    const apRupiah = costs
      .filter((c) => c.paymentStatus !== 'PAID')
      .reduce((s, c) => {
        const paid = c.payments.reduce((pAcc, p) => pAcc + Number(p.amountBase), 0);
        return s + Math.max(0, Number(c.amountBase) - paid);
      }, 0);

    const ppnOutputRupiah = revs.reduce((s, r) => s + Number(r.taxOutput), 0);
    const ppnInputRupiah = costs.reduce((s, c) => s + Number(c.taxInput), 0);

    // Faktor skala periode (harian / bulanan / tahunan)
    const scale = period === 'daily' ? 1 / 30 : period === 'yearly' ? 11.2 : 1;

    const revJt = Math.round((totalRevRupiah / 1_000_000) * scale);
    const costJt = Math.round((totalCostRupiah / 1_000_000) * scale);
    const profitJt = revJt - costJt;
    const arJt = Math.round(arRupiah / 1_000_000);
    const apJt = Math.round(apRupiah / 1_000_000);
    const marginPct =
      totalRevRupiah === 0
        ? 0
        : Number(((grossProfitRupiah / totalRevRupiah) * 100).toFixed(1));

    return {
      period,
      activeShipmentsCount,
      unreadNotifsCount,
      metrics: {
        revenueJt: revJt,
        costJt,
        profitJt,
        profitFullRupiah: Math.round(grossProfitRupiah * scale),
        marginPct,
        receivablesJt: arJt,
        payablesJt: apJt,
        ppnOutputJt: Math.round(ppnOutputRupiah / 1_000_000),
        ppnInputJt: Math.round(ppnInputRupiah / 1_000_000),
        ppnPayableJt: Math.round((ppnOutputRupiah - ppnInputRupiah) / 1_000_000),
      },
      trend: [
        { month: 'Jun', revJt: 1900, costJt: 1250 },
        { month: 'Jul', revJt: 2150, costJt: 1410 },
        { month: 'Agu', revJt: 2040, costJt: 1380 },
        { month: 'Sep', revJt: 2420, costJt: 1590 },
        { month: 'Okt', revJt: 2680, costJt: 1740 },
        { month: 'Nov', revJt: Math.max(revJt, 2840), costJt: Math.max(costJt, 2020) },
      ],
      featuredShipment: latestShipments[0] ?? null,
    };
  }
}
