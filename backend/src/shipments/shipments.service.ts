import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ShipmentsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Menghitung P&L per shipment sesuai PRD BR-01..04:
   * - Total Revenue = Σ (item revenue shipment, nilai DPP / amountBase)
   * - Total Cost    = Σ (item cost shipment, nilai DPP / amountBase)
   * - Gross Profit  = Total Revenue − Total Cost
   * - Margin (%)    = Revenue == 0 ? 0 : (Gross Profit ÷ Total Revenue) × 100
   */
  private mapShipmentWithPnl(s: any) {
    const revRupiah = (s.revenues || []).reduce(
      (acc: number, r: any) => acc + Number(r.amountBase),
      0,
    );
    const costRupiah = (s.costs || []).reduce(
      (acc: number, c: any) => acc + Number(c.amountBase),
      0,
    );
    const profitRupiah = revRupiah - costRupiah;
    const revJt = Math.round(revRupiah / 1_000_000);
    const costJt = Math.round(costRupiah / 1_000_000);
    const profitJt = revJt - costJt;
    const marginPct = revRupiah === 0 ? 0 : Number(((profitRupiah / revRupiah) * 100).toFixed(1));

    return {
      id: s.shipmentNo,
      uuid: s.id,
      client: s.customer?.name ?? 'PT Garuda Trading',
      route: `${s.origin} → ${s.destination}`,
      origin: s.origin,
      destination: s.destination,
      type: s.type,
      status: s.status,
      arsip: s.isArchived,
      container: s.container,
      etd: s.etd,
      eta: s.eta,
      revenueJt: revJt,
      costJt,
      profitJt,
      marginPct,
      revenue: `Rp ${revJt} jt`,
      profit: `${profitJt < 0 ? '-' : ''}Rp ${Math.abs(profitJt)} jt`,
      profitUp: profitJt >= 0,
    };
  }

  async findAll(
    companyId: string,
    opts: { page?: number; pageSize?: number; status?: string; search?: string; includeArchived?: boolean } = {},
  ) {
    const page = Math.max(0, Number(opts.page ?? 0));
    const pageSize = Math.min(50, Math.max(1, Number(opts.pageSize ?? 20)));

    const where: any = {
      companyId,
      ...(opts.includeArchived ? {} : { isArchived: false }),
    };

    if (opts.status && opts.status !== 'Semua') {
      where.status = opts.status;
    }

    if (opts.search && opts.search.trim().length > 0) {
      const q = opts.search.trim();
      where.OR = [
        { shipmentNo: { contains: q, mode: 'insensitive' } },
        { origin: { contains: q, mode: 'insensitive' } },
        { destination: { contains: q, mode: 'insensitive' } },
        { customer: { name: { contains: q, mode: 'insensitive' } } },
      ];
    }

    const rows = await this.prisma.shipment.findMany({
      where,
      include: {
        customer: true,
        revenues: true,
        costs: true,
      },
      orderBy: { createdAt: 'desc' },
      skip: page * pageSize,
      take: pageSize,
    });

    return rows.map((s) => this.mapShipmentWithPnl(s));
  }

  async findOnePnl(companyId: string, shipmentNoOrId: string) {
    const s = await this.prisma.shipment.findFirst({
      where: {
        companyId,
        OR: [
          { shipmentNo: shipmentNoOrId },
          ...(shipmentNoOrId.length === 36 ? [{ id: shipmentNoOrId }] : []),
        ],
      },
      include: {
        customer: true,
        revenues: { include: { customer: true, payments: true } },
        costs: { include: { vendor: true, payments: true } },
      },
    });

    if (!s) throw new NotFoundException(`Shipment ${shipmentNoOrId} tidak ditemukan.`);

    const summary = this.mapShipmentWithPnl(s);
    return {
      ...summary,
      revenues: s.revenues.map((r) => ({
        id: r.id,
        invoiceNo: r.invoiceNo,
        category: r.category,
        customer: r.customer.name,
        currency: r.currency,
        amountJt: Math.round(Number(r.amountBase) / 1_000_000),
        taxOutputJt: Math.round(Number(r.taxOutput) / 1_000_000),
        paymentStatus: r.paymentStatus,
      })),
      costs: s.costs.map((c) => ({
        id: c.id,
        invoiceNo: c.invoiceNo,
        category: c.category,
        vendor: c.vendor.name,
        currency: c.currency,
        amountJt: Math.round(Number(c.amountBase) / 1_000_000),
        taxInputJt: Math.round(Number(c.taxInput) / 1_000_000),
        paymentStatus: c.paymentStatus,
      })),
    };
  }

  async create(
    companyId: string,
    dto: {
      customerName: string;
      type: string;
      origin: string;
      destination: string;
      container?: string;
      etd?: string;
      eta?: string;
    },
  ) {
    let customer = await this.prisma.customer.findFirst({
      where: {
        companyId,
        name: { equals: dto.customerName.trim(), mode: 'insensitive' },
      },
    });

    if (!customer) {
      customer = await this.prisma.customer.create({
        data: {
          companyId,
          code: `CST-${Date.now() % 1000}`,
          name: dto.customerName.trim(),
          city: dto.origin.trim(),
        },
      });
    }

    const shipmentNo = `FI-2610-${Math.floor(1000 + Math.random() * 9000)}`;
    const created = await this.prisma.shipment.create({
      data: {
        companyId,
        customerId: customer.id,
        shipmentNo,
        type: dto.type,
        origin: dto.origin.trim(),
        destination: dto.destination.trim(),
        container: dto.container || '1 x 40ft HC',
        etd: dto.etd || '12 Okt 2026',
        eta: dto.eta || '28 Okt 2026',
        status: 'Booking',
      },
      include: { customer: true, revenues: true, costs: true },
    });

    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'SHIPMENT',
        entityId: created.id,
        action: 'Membuat shipment baru',
        target: `${created.shipmentNo} (${created.origin} → ${created.destination})`,
      },
    });

    return this.mapShipmentWithPnl(created);
  }

  async update(
    companyId: string,
    shipmentNoOrId: string,
    dto: {
      client?: string;
      origin?: string;
      destination?: string;
      route?: string;
      type?: string;
      status?: string;
      arsip?: boolean;
      container?: string;
      etd?: string;
      eta?: string;
    },
  ) {
    const existing = await this.prisma.shipment.findFirst({
      where: {
        companyId,
        OR: [
          { shipmentNo: shipmentNoOrId },
          ...(shipmentNoOrId.length === 36 ? [{ id: shipmentNoOrId }] : []),
        ],
      },
    });

    if (!existing) throw new NotFoundException(`Shipment ${shipmentNoOrId} tidak ditemukan.`);

    let origin = dto.origin ?? existing.origin;
    let destination = dto.destination ?? existing.destination;
    if (dto.route && dto.route.includes('→')) {
      const parts = dto.route.split('→');
      origin = parts[0].trim();
      destination = (parts[1] || '').trim();
    }

    let customerId = existing.customerId;
    if (dto.client) {
      let cust = await this.prisma.customer.findFirst({
        where: { companyId, name: { equals: dto.client.trim(), mode: 'insensitive' } },
      });
      if (!cust) {
        cust = await this.prisma.customer.create({
          data: {
            companyId,
            code: `CST-${Date.now() % 1000}`,
            name: dto.client.trim(),
          },
        });
      }
      customerId = cust.id;
    }

    const updated = await this.prisma.shipment.update({
      where: { id: existing.id },
      data: {
        customerId,
        origin,
        destination,
        type: dto.type ?? existing.type,
        status: dto.status ?? existing.status,
        isArchived: dto.arsip ?? existing.isArchived,
        container: dto.container ?? existing.container,
        etd: dto.etd ?? existing.etd,
        eta: dto.eta ?? existing.eta,
      },
      include: { customer: true, revenues: true, costs: true },
    });

    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'SHIPMENT',
        entityId: updated.id,
        action: dto.arsip
          ? 'Mengarsipkan shipment (BR-08)'
          : `Memperbarui shipment (${updated.status})`,
        target: updated.shipmentNo,
      },
    });

    return this.mapShipmentWithPnl(updated);
  }
}
