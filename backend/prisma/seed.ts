import { PrismaClient, Prisma } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();
const dec = (n: number | string) => new Prisma.Decimal(n);

async function main() {
  console.log('🌱 Seeding FreightIntel AI PostgreSQL database...');

  // Bersihkan data lama secara berurutan (idempotent)
  await prisma.auditLog.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.aiAnalysis.deleteMany();
  await prisma.report.deleteMany();
  await prisma.customFieldValue.deleteMany();
  await prisma.customField.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.revenue.deleteMany();
  await prisma.cost.deleteMany();
  await prisma.shipment.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.vendor.deleteMany();
  await prisma.user.deleteMany();
  await prisma.rolePermission.deleteMany();
  await prisma.permission.deleteMany();
  await prisma.role.deleteMany();
  await prisma.branch.deleteMany();
  await prisma.company.deleteMany();

  // 1. Perusahaan (FR-CMP-01..04)
  const cmp1 = await prisma.company.create({
    data: {
      name: 'PT Samudra Nusantara Logistik',
      npwp: '01.345.678.9-042.000',
      address: 'Jl. Yos Sudarso Kav. 85, Tanjung Priok',
      city: 'Jakarta Utara',
      baseCurrency: 'IDR',
      ppnPct: 11,
      taxSetting: { ppnPct: 11, separateOutputInput: true },
    },
  });

  await prisma.company.create({
    data: {
      name: 'PT Pelabuhan Mandiri Cargo',
      npwp: '02.987.654.3-611.000',
      address: 'Jl. Perak Timur No. 118, Tanjung Perak',
      city: 'Surabaya',
      baseCurrency: 'IDR',
      ppnPct: 11,
      taxSetting: { ppnPct: 11, separateOutputInput: true },
    },
  });

  // 2. Cabang (FR-CMP-02)
  await prisma.branch.createMany({
    data: [
      {
        companyId: cmp1.id,
        code: 'JKT-HQ',
        name: 'Kantor Pusat Tanjung Priok',
        city: 'Jakarta',
        address: 'Jl. Yos Sudarso Kav. 85',
        isHead: true,
      },
      {
        companyId: cmp1.id,
        code: 'SUB-01',
        name: 'Cabang Tanjung Perak',
        city: 'Surabaya',
        address: 'Jl. Perak Barat No. 42',
        isHead: false,
      },
      {
        companyId: cmp1.id,
        code: 'MES-01',
        name: 'Cabang Pelabuhan Belawan',
        city: 'Medan',
        address: 'Jl. Sumatera No. 11, Belawan',
        isHead: false,
      },
    ],
  });

  // 3. Permissions & 6 Peran Bawaan (FR-USR-02..04)
  const modules = ['Dashboard', 'Shipment', 'Revenue', 'Cost', 'Laporan', 'Customer', 'Pengaturan'];
  const actions = ['Lihat', 'Buat', 'Ubah', 'Hapus'];
  const perms: { id: string; code: string; module: string; action: string }[] = [];

  for (const m of modules) {
    for (const a of actions) {
      const code = `${m.toUpperCase()}_${a.toUpperCase()}`;
      const p = await prisma.permission.create({
        data: { code, module: m, action: a },
      });
      perms.push(p);
    }
  }

  const roleNames = ['Super Admin', 'Owner', 'Finance', 'Operasional', 'Sales', 'Staff'];
  const roleMap: Record<string, string> = {};

  for (const rName of roleNames) {
    const role = await prisma.role.create({
      data: { companyId: cmp1.id, name: rName, isSystem: true },
    });
    roleMap[rName] = role.id;

    // Pasang matriks izin sesuai PRD §2
    const allowed = perms.filter((p) => {
      if (rName === 'Super Admin' || rName === 'Owner') return true;
      if (rName === 'Finance') return ['Dashboard', 'Revenue', 'Cost', 'Laporan'].includes(p.module) || p.action === 'Lihat';
      if (rName === 'Operasional') return ['Dashboard', 'Shipment'].includes(p.module);
      if (rName === 'Sales') return ['Dashboard', 'Customer', 'Revenue'].includes(p.module) && p.action !== 'Hapus';
      return p.action === 'Lihat' && ['Dashboard', 'Shipment'].includes(p.module);
    });

    await prisma.rolePermission.createMany({
      data: allowed.map((p) => ({ roleId: role.id, permissionId: p.id })),
    });
  }

  // 4. Pengguna (FR-USR-01, SEC-01 bcrypt)
  const passwordHash = await bcrypt.hash('demo1234', 10);
  const ownerUser = await prisma.user.create({
    data: {
      companyId: cmp1.id,
      roleId: roleMap['Owner'],
      branchName: 'Jakarta',
      name: 'Hendra Wijaya',
      email: 'owner@nusantara.co.id',
      passwordHash,
      isActive: true,
    },
  });

  await prisma.user.createMany({
    data: [
      {
        companyId: cmp1.id,
        roleId: roleMap['Finance'],
        branchName: 'Jakarta',
        name: 'Ratna Kusuma',
        email: 'ratna.finance@nusantara.co.id',
        passwordHash,
        isActive: true,
      },
      {
        companyId: cmp1.id,
        roleId: roleMap['Operasional'],
        branchName: 'Surabaya',
        name: 'Budi Santoso',
        email: 'budi.ops@nusantara.co.id',
        passwordHash,
        isActive: true,
      },
      {
        companyId: cmp1.id,
        roleId: roleMap['Sales'],
        branchName: 'Jakarta',
        name: 'Siti Rahma',
        email: 'siti.sales@nusantara.co.id',
        passwordHash,
        isActive: true,
      },
      {
        companyId: cmp1.id,
        roleId: roleMap['Staff'],
        branchName: 'Medan',
        name: 'Andi Pratama',
        email: 'andi.staff@nusantara.co.id',
        passwordHash,
        isActive: true,
      },
    ],
  });

  // 5. Customer (FR-CAN-01..03)
  const customerDefs = [
    { code: 'CST-01', name: 'PT Garuda Trading', city: 'Jakarta', riskLevel: 'Rendah', avgPayDays: 14, sinceYear: '2021' },
    { code: 'CST-02', name: 'PT Astra Export', city: 'Bekasi', riskLevel: 'Rendah', avgPayDays: 18, sinceYear: '2020' },
    { code: 'CST-03', name: 'CV Mitra Laut', city: 'Surabaya', riskLevel: 'Sedang', avgPayDays: 29, sinceYear: '2022' },
    { code: 'CST-04', name: 'PT Indo Pangan Makmur', city: 'Semarang', riskLevel: 'Rendah', avgPayDays: 16, sinceYear: '2023' },
    { code: 'CST-05', name: 'PT Krakatau Baja Niaga', city: 'Cilegon', riskLevel: 'Tinggi', avgPayDays: 44, sinceYear: '2022' },
  ];

  const customers: any[] = [];
  for (const c of customerDefs) {
    customers.push(
      await prisma.customer.create({
        data: { companyId: cmp1.id, ...c, npwp: '01.222.333.4-055.000' },
      }),
    );
  }

  // 6. Vendor (FR-VAN-01..03)
  const vendorDefs = [
    { code: 'VND-01', name: 'Meratus Line', category: 'Pelayaran', city: 'Surabaya', onTimePct: dec(94), rateIndex: dec(0.96) },
    { code: 'VND-02', name: 'Samudera Shipping', category: 'Pelayaran', city: 'Jakarta', onTimePct: dec(92), rateIndex: dec(1.01) },
    { code: 'VND-03', name: 'PT Lintas Truk Nusantara', category: 'Armada Darat', city: 'Jakarta', onTimePct: dec(86), rateIndex: dec(1.14) },
    { code: 'VND-04', name: 'Garuda Cargo', category: 'Maskapai', city: 'Tangerang', onTimePct: dec(96), rateIndex: dec(1.03) },
    { code: 'VND-05', name: 'PPJK Bea Cepat', category: 'Kepabeanan', city: 'Jakarta', onTimePct: dec(91), rateIndex: dec(0.98) },
  ];

  const vendors: any[] = [];
  for (const v of vendorDefs) {
    vendors.push(
      await prisma.vendor.create({
        data: { companyId: cmp1.id, ...v },
      }),
    );
  }

  // 7. Shipments + Revenues + Costs + Payments (FR-SHP, FR-REV, FR-CST, BR-01..08)
  const routes = [
    ['Jakarta', 'Rotterdam'],
    ['Singapore', 'Surabaya'],
    ['Jakarta', 'Tokyo'],
    ['Hamburg', 'Jakarta'],
    ['Shanghai', 'Belawan'],
    ['Surabaya', 'Busan'],
  ];
  const modes = ['Ocean Freight', 'Air Freight', 'Trucking', 'Handling'];
  const statuses = ['Booking', 'In Transit', 'Arrived', 'Customs', 'Delivered', 'Completed'];

  for (let i = 0; i < 20; i++) {
    const r = routes[i % routes.length];
    const cust = customers[i % customers.length];
    const vend = vendors[i % vendors.length];
    const up = i % 4 !== 2;
    const revJt = 80 + ((i * 23) % 240);
    const profJt = up ? 20 + ((i * 11) % 120) : -(30 + ((i * 7) % 40));
    const costJt = revJt - profJt;
    const shipmentNo = `FI-2610-${(1000 + i * 137).toString(16).toUpperCase().padStart(4, '0')}`;

    // Sebar data ke 6 bulan terakhir supaya tren & pertumbuhan punya
    // pembanding nyata. Sebelumnya semua bertanggal Oktober, sehingga grafik
    // 6 bulan punya 5 bulan kosong dan margin bulan berjalan jadi 100%.
    const bulanIdx = 5 + (i % 6); // 5=Jun ... 10=Nov (2026)
    const BLN = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    const tgl = (i % 24) + 1;
    const kodeBulan = `26${String(bulanIdx + 1).padStart(2, '0')}`;

    const shp = await prisma.shipment.create({
      data: {
        companyId: cmp1.id,
        customerId: cust.id,
        shipmentNo,
        type: modes[i % modes.length],
        origin: r[0],
        destination: r[1],
        container: i % 2 === 0 ? '1 x 40ft HC' : '2 x 20ft GP',
        etd: `${tgl} ${BLN[bulanIdx]} 2026`,
        eta: `${Math.min(tgl + 16, 28)} ${BLN[bulanIdx]} 2026`,
        status: statuses[i % statuses.length],
        isArchived: false,
      },
    });

    // Revenue (DPP dalam juta Rupiah -> disimpan sebagai nilai penuh Rupiah DECIMAL BR-04)
    const revAmount = dec(revJt * 1_000_000);
    const revTax = dec(Math.round(revJt * 0.11 * 1_000_000));
    const revPaid = i % 3 !== 2;

    const rev = await prisma.revenue.create({
      data: {
        companyId: cmp1.id,
        shipmentId: shp.id,
        customerId: cust.id,
        invoiceNo: `INV/${kodeBulan}/${String(100 + i).padStart(3, '0')}`,
        category: modes[i % modes.length],
        invoiceDate: new Date(2026, bulanIdx, tgl),
        currency: 'IDR',
        exchangeRate: dec(1),
        amount: revAmount,
        amountBase: revAmount,
        taxOutput: revTax,
        paymentStatus: revPaid ? 'PAID' : i % 5 === 0 ? 'PARTIAL' : 'UNPAID',
      },
    });

    if (revPaid) {
      await prisma.payment.create({
        data: {
          companyId: cmp1.id,
          revenueId: rev.id,
          direction: 'IN',
          amount: revAmount,
          amountBase: revAmount,
          method: 'Transfer Bank Mandiri',
          paidAt: new Date(2026, bulanIdx, Math.min(tgl + 5, 28)),
        },
      });
    } else if (i % 5 === 0) {
      const half = dec(Math.round((revJt / 2) * 1_000_000));
      await prisma.payment.create({
        data: {
          companyId: cmp1.id,
          revenueId: rev.id,
          direction: 'IN',
          amount: half,
          amountBase: half,
          method: 'Transfer BCA',
        },
      });
    }

    // Cost (DPP dalam Rupiah DECIMAL BR-04)
    const costAmount = dec(costJt * 1_000_000);
    const costTax = dec(Math.round(costJt * 0.11 * 1_000_000));
    const costPaid = i % 2 === 0;

    const cst = await prisma.cost.create({
      data: {
        companyId: cmp1.id,
        shipmentId: shp.id,
        vendorId: vend.id,
        invoiceNo: `BILL/${kodeBulan}/${String(200 + i).padStart(3, '0')}`,
        category: vend.category,
        invoiceDate: new Date(2026, bulanIdx, Math.min(tgl + 2, 28)),
        currency: 'IDR',
        exchangeRate: dec(1),
        amount: costAmount,
        amountBase: costAmount,
        taxInput: costTax,
        paymentStatus: costPaid ? 'PAID' : 'UNPAID',
      },
    });

    if (costPaid) {
      await prisma.payment.create({
        data: {
          companyId: cmp1.id,
          costId: cst.id,
          direction: 'OUT',
          amount: costAmount,
          amountBase: costAmount,
          method: 'Transfer Bank Mandiri',
          paidAt: new Date(2026, bulanIdx, Math.min(tgl + 5, 28)),
        },
      });
    }
  }

  // 8. Custom Fields (FR-CF-01..04)
  await prisma.customField.createMany({
    data: [
      { companyId: cmp1.id, entity: 'Shipment', label: 'Nomor B/L (Bill of Lading)', type: 'Text', isRequired: true },
      { companyId: cmp1.id, entity: 'Shipment', label: 'Incoterm', type: 'Dropdown', isRequired: true, options: ['FOB', 'CIF', 'EXW', 'DDP'] },
      { companyId: cmp1.id, entity: 'Shipment', label: 'Nama Kapal / Vessel', type: 'Text', isRequired: false },
      { companyId: cmp1.id, entity: 'Shipment', label: 'Kode HS (HS Code)', type: 'Text', isRequired: false },
      { companyId: cmp1.id, entity: 'Revenue', label: 'Nomor Faktur Pajak', type: 'Text', isRequired: true },
      { companyId: cmp1.id, entity: 'Cost', label: 'Nomor DO (Delivery Order)', type: 'Text', isRequired: false },
    ],
  });

  // 9. Notifikasi (FR-NOT-01..05)
  await prisma.notification.createMany({
    data: [
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        type: 'AR_DUE',
        title: 'Invoice jatuh tempo',
        body: 'Piutang INV/2610/009 (Rp 76 jt · PT Garuda Trading) jatuh tempo 3 hari lagi.',
        isRead: false,
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        type: 'AP_DUE',
        title: 'Hutang vendor jatuh tempo',
        body: 'Tagihan Meratus Line untuk FI-2610-03E8 mendekati tenggat pembayaran.',
        isRead: false,
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        type: 'LOW_CASH',
        title: 'Peringatan kas operasional',
        body: 'Cadangan kas cabang Surabaya mendekati batas minimum minggu ini.',
        isRead: false,
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        type: 'SHIPMENT_DELAY',
        title: 'Shipment tertahan (delay)',
        body: 'FI-2610-04FA tertahan di pemeriksaan Customs pelabuhan tujuan.',
        isRead: false,
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        type: 'PAYMENT_IN',
        title: 'Pembayaran masuk',
        body: 'INV/2610/017 telah dilunasi penuh (Rp 298 jt).',
        isRead: true,
      },
    ],
  });

  // 10. Audit Logs (FR-USR-06, BR-09)
  await prisma.auditLog.createMany({
    data: [
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        actorName: 'Hendra Wijaya',
        actorRole: 'Owner',
        entity: 'AUTH',
        action: 'Login ke sistem',
        target: 'Perangkat Android (Tanjung Priok)',
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        actorName: 'Ratna Kusuma',
        actorRole: 'Finance',
        entity: 'PAYMENT',
        action: 'Mencatat pelunasan piutang',
        target: 'INV/2610/017 · Rp 298 jt',
      },
      {
        companyId: cmp1.id,
        userId: ownerUser.id,
        actorName: 'Budi Santoso',
        actorRole: 'Operasional',
        entity: 'SHIPMENT',
        action: 'Mengubah status shipment ke In Transit',
        target: 'FI-2610-03E8 (Jakarta → Rotterdam)',
      },
    ],
  });

  console.log('✅ Seed selesai! Perusahaan utama ID:', cmp1.id);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
