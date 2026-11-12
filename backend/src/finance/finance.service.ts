import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

const dec = (n: number | string) => new Prisma.Decimal(n);

@Injectable()
export class FinanceService {
  constructor(private readonly prisma: PrismaService) {}

  private fmtDate(d: Date) {
    return d.toISOString().slice(0, 10);
  }

  /**
   * Menggabungkan daftar invoice Revenue & Cost perusahaan (FR-REV, FR-CST, BR-06)
   * dalam struktur yang langsung cocok dengan model `Invoice` di Flutter.
   */
  async listInvoices(companyId: string) {
    const [revs, costs] = await Promise.all([
      this.prisma.revenue.findMany({
        where: { companyId },
        include: { customer: true, shipment: true, payments: true },
        orderBy: { invoiceDate: 'desc' },
        take: 30,
      }),
      this.prisma.cost.findMany({
        where: { companyId },
        include: { vendor: true, shipment: true, payments: true },
        orderBy: { invoiceDate: 'desc' },
        take: 20,
      }),
    ]);

    const mappedRevs = revs.map((r) => {
      const dppJt = Math.round(Number(r.amountBase) / 1_000_000);
      const ppnJt = Math.round(Number(r.taxOutput) / 1_000_000);
      const paidRupiah = r.payments.reduce((s, p) => s + Number(p.amountBase), 0);
      const paidJt = Math.round(paidRupiah / 1_000_000);
      return {
        id: r.id,
        no: r.invoiceNo,
        note: `${r.category} · ${this.fmtDate(r.invoiceDate)}`,
        amount: `+Rp ${dppJt} jt`,
        status: r.paymentStatus,
        paid: r.paymentStatus === 'PAID',
        type: 'revenue',
        counterparty: r.customer.name,
        shipmentNo: r.shipment?.shipmentNo ?? null,
        category: r.category,
        invoiceDate: r.invoiceDate.toISOString(),
        dppRupiah: dppJt,
        ppnRupiah: ppnJt,
        paidRupiah: paidJt,
        currency: r.currency,
        exchangeRate: Number(r.exchangeRate),
      };
    });

    const mappedCosts = costs.map((c) => {
      const dppJt = Math.round(Number(c.amountBase) / 1_000_000);
      const ppnJt = Math.round(Number(c.taxInput) / 1_000_000);
      const paidRupiah = c.payments.reduce((s, p) => s + Number(p.amountBase), 0);
      const paidJt = Math.round(paidRupiah / 1_000_000);
      return {
        id: c.id,
        no: c.invoiceNo,
        note: `${c.category} · ${this.fmtDate(c.invoiceDate)}`,
        amount: `-Rp ${dppJt} jt`,
        status: c.paymentStatus,
        paid: c.paymentStatus === 'PAID',
        type: 'cost',
        counterparty: c.vendor.name,
        shipmentNo: c.shipment?.shipmentNo ?? null,
        category: c.category,
        invoiceDate: c.invoiceDate.toISOString(),
        dppRupiah: dppJt,
        ppnRupiah: ppnJt,
        paidRupiah: paidJt,
        currency: c.currency,
        exchangeRate: Number(c.exchangeRate),
      };
    });

    return [...mappedRevs, ...mappedCosts].sort(
      (a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime(),
    );
  }

  async createInvoice(
    companyId: string,
    dto: {
      type: 'revenue' | 'cost';
      invoiceNo?: string;
      counterparty: string;
      shipmentNo?: string | null;
      category: string;
      invoiceDate?: string;
      currency?: string;
      exchangeRate?: number;
      dppJt: number;
      ppnJt?: number;
      paid?: boolean;
    },
  ) {
    const currency = dto.currency || 'IDR';
    const rate = currency === 'IDR' ? 1 : Number(dto.exchangeRate || 15800);
    const amountBaseRupiah = dec(Math.round(dto.dppJt * 1_000_000));
    const amountOrig =
      currency === 'IDR'
        ? amountBaseRupiah
        : dec(Math.round((dto.dppJt * 1_000_000) / rate));
    const taxRupiah = dec(Math.round((dto.ppnJt || 0) * 1_000_000));
    const invDate = dto.invoiceDate ? new Date(dto.invoiceDate) : new Date();
    const status = dto.paid ? 'PAID' : 'UNPAID';

    let shipmentId: string | null = null;
    if (dto.shipmentNo) {
      const shp = await this.prisma.shipment.findFirst({
        where: { companyId, shipmentNo: dto.shipmentNo },
      });
      if (shp) shipmentId = shp.id;
    }

    if (dto.type === 'revenue') {
      let customer = await this.prisma.customer.findFirst({
        where: {
          companyId,
          name: { equals: dto.counterparty.trim(), mode: 'insensitive' },
        },
      });
      if (!customer) {
        customer = await this.prisma.customer.create({
          data: {
            companyId,
            code: `CST-${Date.now() % 1000}`,
            name: dto.counterparty.trim(),
          },
        });
      }

      const invNo =
        dto.invoiceNo?.trim() || `INV/2610/${Math.floor(100 + Math.random() * 900)}`;

      const created = await this.prisma.revenue.create({
        data: {
          companyId,
          shipmentId,
          customerId: customer.id,
          invoiceNo: invNo,
          category: dto.category.trim(),
          invoiceDate: invDate,
          currency,
          exchangeRate: dec(rate),
          amount: amountOrig,
          amountBase: amountBaseRupiah,
          taxOutput: taxRupiah,
          paymentStatus: status,
        },
      });

      if (dto.paid) {
        await this.prisma.payment.create({
          data: {
            companyId,
            revenueId: created.id,
            direction: 'IN',
            amount: amountOrig,
            amountBase: amountBaseRupiah,
            method: 'Transfer Bank',
          },
        });
      }

      await this.prisma.auditLog.create({
        data: {
          companyId,
          actorName: 'Ratna Kusuma',
          actorRole: 'Finance',
          entity: 'REVENUE',
          entityId: created.id,
          action: 'Mencatat invoice pemasukan baru',
          target: `${invNo} · Rp ${dto.dppJt} jt (${customer.name})`,
        },
      });

      return {
        id: created.id,
        no: created.invoiceNo,
        note: `${created.category} · ${this.fmtDate(created.invoiceDate)}`,
        amount: `+Rp ${dto.dppJt} jt`,
        status: created.paymentStatus,
        paid: dto.paid ?? false,
        type: 'revenue',
        counterparty: customer.name,
        shipmentNo: dto.shipmentNo ?? null,
        category: created.category,
        invoiceDate: created.invoiceDate.toISOString(),
        dppRupiah: dto.dppJt,
        ppnRupiah: dto.ppnJt ?? 0,
        paidRupiah: dto.paid ? dto.dppJt : 0,
        currency,
        exchangeRate: rate,
      };
    } else {
      let vendor = await this.prisma.vendor.findFirst({
        where: {
          companyId,
          name: { equals: dto.counterparty.trim(), mode: 'insensitive' },
        },
      });
      if (!vendor) {
        vendor = await this.prisma.vendor.create({
          data: {
            companyId,
            code: `VND-${Date.now() % 1000}`,
            name: dto.counterparty.trim(),
            category: dto.category.trim(),
          },
        });
      }

      const invNo =
        dto.invoiceNo?.trim() || `BILL/2610/${Math.floor(100 + Math.random() * 900)}`;

      const created = await this.prisma.cost.create({
        data: {
          companyId,
          shipmentId,
          vendorId: vendor.id,
          invoiceNo: invNo,
          category: dto.category.trim(),
          invoiceDate: invDate,
          currency,
          exchangeRate: dec(rate),
          amount: amountOrig,
          amountBase: amountBaseRupiah,
          taxInput: taxRupiah,
          paymentStatus: status,
        },
      });

      if (dto.paid) {
        await this.prisma.payment.create({
          data: {
            companyId,
            costId: created.id,
            direction: 'OUT',
            amount: amountOrig,
            amountBase: amountBaseRupiah,
            method: 'Transfer Bank',
          },
        });
      }

      await this.prisma.auditLog.create({
        data: {
          companyId,
          actorName: 'Ratna Kusuma',
          actorRole: 'Finance',
          entity: 'COST',
          entityId: created.id,
          action: 'Mencatat tagihan biaya vendor',
          target: `${invNo} · Rp ${dto.dppJt} jt (${vendor.name})`,
        },
      });

      return {
        id: created.id,
        no: created.invoiceNo,
        note: `${created.category} · ${this.fmtDate(created.invoiceDate)}`,
        amount: `-Rp ${dto.dppJt} jt`,
        status: created.paymentStatus,
        paid: dto.paid ?? false,
        type: 'cost',
        counterparty: vendor.name,
        shipmentNo: dto.shipmentNo ?? null,
        category: created.category,
        invoiceDate: created.invoiceDate.toISOString(),
        dppRupiah: dto.dppJt,
        ppnRupiah: dto.ppnJt ?? 0,
        paidRupiah: dto.paid ? dto.dppJt : 0,
        currency,
        exchangeRate: rate,
      };
    }
  }

  /**
   * Catat pembayaran / cicilan bertahap (PRD BR-06):
   * Akumulasi `payments` menentukan status turunan `UNPAID` / `PARTIAL` / `PAID`.
   */
  async recordPayment(companyId: string, invoiceNo: string, addJt: number) {
    const addRupiah = Math.max(1, addJt) * 1_000_000;

    const rev = await this.prisma.revenue.findFirst({
      where: { companyId, invoiceNo },
      include: { payments: true },
    });

    if (rev) {
      await this.prisma.payment.create({
        data: {
          companyId,
          revenueId: rev.id,
          direction: 'IN',
          amount: dec(addRupiah),
          amountBase: dec(addRupiah),
          method: 'Transfer Bank',
        },
      });

      const paidTotal =
        rev.payments.reduce((s, p) => s + Number(p.amountBase), 0) + addRupiah;
      const full = paidTotal >= Number(rev.amountBase);
      const nextStatus = full ? 'PAID' : 'PARTIAL';

      await this.prisma.revenue.update({
        where: { id: rev.id },
        data: { paymentStatus: nextStatus },
      });

      await this.prisma.auditLog.create({
        data: {
          companyId,
          actorName: 'Ratna Kusuma',
          actorRole: 'Finance',
          entity: 'PAYMENT',
          entityId: rev.id,
          action: full ? 'Melunasi invoice piutang' : 'Mencatat cicilan piutang',
          target: `${invoiceNo} (+Rp ${addJt} jt → ${nextStatus})`,
        },
      });

      return {
        invoiceNo,
        status: nextStatus,
        paid: full,
        paidJt: Math.round(Math.min(paidTotal, Number(rev.amountBase)) / 1_000_000),
      };
    }

    const cost = await this.prisma.cost.findFirst({
      where: { companyId, invoiceNo },
      include: { payments: true },
    });

    if (!cost) {
      throw new NotFoundException(`Invoice ${invoiceNo} tidak ditemukan.`);
    }

    await this.prisma.payment.create({
      data: {
        companyId,
        costId: cost.id,
        direction: 'OUT',
        amount: dec(addRupiah),
        amountBase: dec(addRupiah),
        method: 'Transfer Bank',
      },
    });

    const paidTotal =
      cost.payments.reduce((s, p) => s + Number(p.amountBase), 0) + addRupiah;
    const full = paidTotal >= Number(cost.amountBase);
    const nextStatus = full ? 'PAID' : 'PARTIAL';

    await this.prisma.cost.update({
      where: { id: cost.id },
      data: { paymentStatus: nextStatus },
    });

    await this.prisma.auditLog.create({
      data: {
        companyId,
        actorName: 'Ratna Kusuma',
        actorRole: 'Finance',
        entity: 'PAYMENT',
        entityId: cost.id,
        action: full ? 'Melunasi tagihan vendor' : 'Mencatat cicilan vendor',
        target: `${invoiceNo} (+Rp ${addJt} jt → ${nextStatus})`,
      },
    });

    return {
      invoiceNo,
      status: nextStatus,
      paid: full,
      paidJt: Math.round(Math.min(paidTotal, Number(cost.amountBase)) / 1_000_000),
    };
  }
}
