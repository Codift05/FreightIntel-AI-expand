import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ShipmentsService } from '../shipments/shipments.service';

const BULAN = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

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

    // Jendela waktu nyata per periode, bukan faktor skala karangan.
    const now = new Date();
    const win = (mundur: number): [Date, Date] => {
      if (period === 'daily') {
        const a = new Date(now.getFullYear(), now.getMonth(), now.getDate() - mundur);
        const b = new Date(a.getFullYear(), a.getMonth(), a.getDate() + 1);
        return [a, b];
      }
      if (period === 'yearly') {
        const a = new Date(now.getFullYear() - mundur, 0, 1);
        return [a, new Date(a.getFullYear() + 1, 0, 1)];
      }
      const a = new Date(now.getFullYear(), now.getMonth() - mundur, 1);
      return [a, new Date(a.getFullYear(), a.getMonth() + 1, 1)];
    };

    const dalam = (d: Date | null | undefined, [a, b]: [Date, Date]) =>
      !!d && d >= a && d < b;
    const jumlah = (
      list: { amountBase: unknown; invoiceDate: Date | null }[],
      w: [Date, Date],
    ) =>
      list
        .filter((x) => dalam(x.invoiceDate, w))
        .reduce((s, x) => s + Number(x.amountBase), 0);

    const wKini = win(0);
    const wLalu = win(1);
    const revKini = jumlah(revs as never, wKini);
    const costKini = jumlah(costs as never, wKini);
    const revLalu = jumlah(revs as never, wLalu);
    const costLalu = jumlah(costs as never, wLalu);

    /// Pertumbuhan terhadap periode sebelumnya. null bila pembanding nol,
    /// supaya aplikasi menyembunyikan badge alih-alih menampilkan angka palsu.
    const tumbuh = (kini: number, lalu: number): number | null =>
      lalu === 0 ? null : Number((((kini - lalu) / Math.abs(lalu)) * 100).toFixed(1));

    const revJt = Math.round(revKini / 1_000_000);
    const costJt = Math.round(costKini / 1_000_000);
    const profitJt = revJt - costJt;
    const profitKini = revKini - costKini;
    const profitLalu = revLalu - costLalu;
    const arJt = Math.round(arRupiah / 1_000_000);
    const apJt = Math.round(apRupiah / 1_000_000);
    const marginPct =
      revKini === 0
        ? 0
        : Number(((profitKini / revKini) * 100).toFixed(1));

    return {
      period,
      activeShipmentsCount,
      unreadNotifsCount,
      metrics: {
        revenueJt: revJt,
        costJt,
        profitJt,
        profitFullRupiah: Math.round(profitKini),
        marginPct,
        // KPI pertumbuhan (FR-DSH-03). null = tidak ada pembanding.
        revenueGrowthPct: tumbuh(revKini, revLalu),
        profitGrowthPct: tumbuh(profitKini, profitLalu),
        costRatioPct:
          revKini === 0 ? null : Number(((costKini / revKini) * 100).toFixed(1)),
        comparedTo:
          period === 'daily'
            ? 'kemarin'
            : period === 'yearly'
              ? 'tahun lalu'
              : 'bulan lalu',
        receivablesJt: arJt,
        payablesJt: apJt,
        ppnOutputJt: Math.round(ppnOutputRupiah / 1_000_000),
        ppnInputJt: Math.round(ppnInputRupiah / 1_000_000),
        ppnPayableJt: Math.round((ppnOutputRupiah - ppnInputRupiah) / 1_000_000),
      },
      // Tren 6 bulan dihitung dari invoiceDate sungguhan. Bulan tanpa
      // transaksi bernilai 0 - itu keadaan sebenarnya, bukan diisi karangan.
      trend: Array.from({ length: 6 }, (_, i) => {
        const a = new Date(now.getFullYear(), now.getMonth() - (5 - i), 1);
        const w: [Date, Date] = [a, new Date(a.getFullYear(), a.getMonth() + 1, 1)];
        return {
          month: BULAN[a.getMonth()],
          revJt: Math.round(jumlah(revs as never, w) / 1_000_000),
          costJt: Math.round(jumlah(costs as never, w) / 1_000_000),
        };
      }),
      featuredShipment: latestShipments[0] ?? null,
    };
  }
}
