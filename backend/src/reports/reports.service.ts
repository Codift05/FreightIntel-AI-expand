import { Injectable } from '@nestjs/common';
import * as ExcelJS from 'exceljs';
import PDFDocument = require('pdfkit');
import { PrismaService } from '../prisma/prisma.service';
import { DashboardService } from '../dashboard/dashboard.service';

type Periode = 'daily' | 'monthly' | 'yearly';

const LABEL: Record<Periode, string> = {
  daily: 'Harian',
  monthly: 'Bulanan',
  yearly: 'Tahunan',
};

/**
 * Laporan keuangan (FR-RPT-01..04).
 *
 * Angka diambil dari [DashboardService] yang sama dengan yang dipakai layar
 * Dashboard, supaya laporan dan aplikasi tidak pernah berbeda isi.
 */
@Injectable()
export class ReportsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly dashboard: DashboardService,
  ) {}

  private rp(jt: number): string {
    const neg = jt < 0;
    const v = Math.abs(jt);
    const s = v >= 1000 ? `Rp ${(v / 1000).toFixed(1)} M` : `Rp ${v} jt`;
    return neg ? `-${s}` : s;
  }

  async data(companyId: string, period: Periode) {
    const [company, sum, masuk, keluar, costGroups] = await Promise.all([
      this.prisma.company.findUnique({ where: { id: companyId } }),
      this.dashboard.getSummary(companyId, period),
      // Arus kas nyata dari tabel payments (BR-06), bukan angka contoh.
      this.prisma.payment.aggregate({
        where: { companyId, direction: 'IN' },
        _sum: { amountBase: true },
      }),
      this.prisma.payment.aggregate({
        where: { companyId, direction: 'OUT' },
        _sum: { amountBase: true },
      }),
      this.prisma.cost.groupBy({
        by: ['category'],
        where: { companyId },
        _sum: { amountBase: true },
      }),
    ]);
    const m = sum.metrics;
    const jt = (v: unknown) => Math.round(Number(v ?? 0) / 1_000_000);
    const kasMasukJt = jt(masuk._sum.amountBase);
    const kasKeluarJt = jt(keluar._sum.amountBase);
    const biayaKategori = costGroups
      .map((g) => ({ nama: g.category, jt: jt(g._sum.amountBase) }))
      .filter((g) => g.jt > 0)
      .sort((a, b) => b.jt - a.jt);
    return {
      namaPerusahaan: company?.name ?? 'Perusahaan',
      npwp: company?.npwp ?? '-',
      periodeLabel: LABEL[period],
      dibuatPada: new Date().toLocaleString('id-ID'),
      m,
      trend: sum.trend,
      activeShipmentsCount: sum.activeShipmentsCount,
      barisLabaRugi: [
        ['Pendapatan', m.revenueJt],
        ['Biaya', -m.costJt],
        ['Laba kotor', m.profitJt],
      ] as [string, number][],
      barisPajak: [
        ['PPN keluaran', m.ppnOutputJt],
        ['PPN masukan', m.ppnInputJt],
        ['PPN terutang', m.ppnPayableJt],
      ] as [string, number][],
      barisPosisi: [
        ['Piutang usaha', m.receivablesJt],
        ['Hutang usaha', m.payablesJt],
      ] as [string, number][],
      kasMasukJt,
      kasKeluarJt,
      kasBersihJt: kasMasukJt - kasKeluarJt,
      barisArusKas: [
        ['Kas masuk', kasMasukJt],
        ['Kas keluar', -kasKeluarJt],
        ['Kas bersih', kasMasukJt - kasKeluarJt],
      ] as [string, number][],
      biayaKategori,
    };
  }

  /** Berkas .xlsx dengan 2 lembar: Ringkasan & Tren 6 bulan (FR-RPT-04). */
  async xlsx(companyId: string, period: Periode): Promise<Buffer> {
    const d = await this.data(companyId, period);
    const wb = new ExcelJS.Workbook();
    wb.creator = 'FreightIntel AI';
    wb.created = new Date();

    const ws = wb.addWorksheet('Ringkasan');
    ws.columns = [
      { header: 'Keterangan', key: 'k', width: 28 },
      { header: 'Nilai (juta Rupiah)', key: 'v', width: 22 },
    ];
    ws.getRow(1).font = { bold: true };

    const section = (judul: string, rows: [string, number][]) => {
      ws.addRow([]);
      const r = ws.addRow([judul, '']);
      r.font = { bold: true };
      rows.forEach(([k, v]) => {
        const row = ws.addRow([k, v]);
        row.getCell(2).numFmt = '#,##0;[Red]-#,##0';
      });
    };

    ws.addRow(['Perusahaan', d.namaPerusahaan]);
    ws.addRow(['NPWP', d.npwp]);
    ws.addRow(['Periode', d.periodeLabel]);
    ws.addRow(['Shipment aktif', d.activeShipmentsCount]);
    ws.addRow(['Dibuat pada', d.dibuatPada]);
    section('Laba rugi', d.barisLabaRugi);
    ws.addRow(['Margin (%)', d.m.marginPct]);
    section('Arus kas', d.barisArusKas);
    section('Posisi', d.barisPosisi);
    section('Pajak (BR-12)', d.barisPajak);
    section(
      'Biaya per kategori',
      d.biayaKategori.map((b) => [b.nama, b.jt] as [string, number]),
    );

    const wt = wb.addWorksheet('Tren 6 bulan');
    wt.columns = [
      { header: 'Bulan', key: 'b', width: 12 },
      { header: 'Pendapatan (jt)', key: 'r', width: 18 },
      { header: 'Biaya (jt)', key: 'c', width: 16 },
      { header: 'Laba (jt)', key: 'p', width: 16 },
    ];
    wt.getRow(1).font = { bold: true };
    d.trend.forEach((t: any) =>
      wt.addRow([t.month, t.revJt, t.costJt, t.revJt - t.costJt]),
    );

    return Buffer.from(await wb.xlsx.writeBuffer());
  }

  /** Berkas .pdf siap cetak (FR-RPT-03). */
  async pdf(companyId: string, period: Periode): Promise<Buffer> {
    const d = await this.data(companyId, period);
    const doc = new PDFDocument({ size: 'A4', margin: 48 });
    const chunks: Buffer[] = [];
    doc.on('data', (c: Buffer) => chunks.push(c));
    const done = new Promise<Buffer>((resolve) =>
      doc.on('end', () => resolve(Buffer.concat(chunks))),
    );

    doc.fontSize(18).text('Laporan Keuangan', { continued: false });
    doc.moveDown(0.2);
    doc.fontSize(11).fillColor('#555')
      .text(`${d.namaPerusahaan} · NPWP ${d.npwp}`)
      .text(`Periode ${d.periodeLabel} · ${d.activeShipmentsCount} shipment aktif`)
      .text(`Dibuat ${d.dibuatPada}`);
    doc.moveDown(1);

    const baris = (k: string, v: string, tebal = false) => {
      doc.fillColor(tebal ? '#000' : '#333').fontSize(11);
      const y = doc.y;
      doc.text(k, 48, y, { width: 300 });
      doc.text(v, 348, y, { width: 160, align: 'right' });
      doc.moveDown(0.35);
    };
    const judul = (t: string) => {
      doc.moveDown(0.5);
      doc.fillColor('#000').fontSize(13).text(t);
      doc.moveDown(0.3);
    };

    judul('Laba rugi');
    d.barisLabaRugi.forEach(([k, v], i) =>
      baris(k, this.rp(v), i === d.barisLabaRugi.length - 1),
    );
    baris('Margin', `${d.m.marginPct}%`);

    judul('Arus kas');
    d.barisArusKas.forEach(([k, v], i) =>
      baris(k, this.rp(v), i === d.barisArusKas.length - 1),
    );

    judul('Posisi');
    d.barisPosisi.forEach(([k, v]) => baris(k, this.rp(v)));

    judul('Biaya per kategori');
    d.biayaKategori.forEach((b) => baris(b.nama, this.rp(b.jt)));

    judul('Pajak (BR-12)');
    d.barisPajak.forEach(([k, v]) => baris(k, this.rp(v)));

    judul('Tren 6 bulan');
    d.trend.forEach((t: any) =>
      baris(t.month, `${this.rp(t.revJt)} / ${this.rp(t.costJt)}`),
    );

    doc.moveDown(1);
    doc.fontSize(9).fillColor('#777').text(
      'Dibuat otomatis oleh FreightIntel AI. Laba dihitung dari nilai sebelum pajak (DPP) sesuai BR-03.',
    );
    doc.end();
    return done;
  }
}
