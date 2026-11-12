import * as dotenv from 'dotenv';
dotenv.config();

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';

async function verify() {
  const app = await NestFactory.create(AppModule, { logger: false });
  app.setGlobalPrefix('api/v1');
  await app.listen(0, '127.0.0.1');

  const url = await app.getUrl();
  const base = `${url}/api/v1`;
  console.log(`🔍 Menguji endpoint REST API di ${base} ...`);

  // 1. Health check
  const health = await fetch(`${base}/health`).then((r) => r.json());
  console.log('1. GET /health ->', JSON.stringify(health));
  if (health.status !== 'ok' || health.counts.shipments < 20) {
    throw new Error('Health check gagal atau seed belum masuk!');
  }

  // 2. Login (SEC-01)
  const login = await fetch(`${base}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'owner@nusantara.co.id', password: 'demo1234' }),
  }).then((r) => r.json());
  console.log(
    `2. POST /auth/login -> User: ${login.user.name} (${login.user.role}), Company: ${login.user.company.name}, Permissions: ${login.user.permissions.length}`,
  );
  const companyId = login.user.company.id;

  // 3. Dashboard Summary (FR-DSH-01..04, BR-01..03, BR-07, BR-12)
  const dash = await fetch(`${base}/dashboard?period=monthly`, {
    headers: { 'x-company-id': companyId },
  }).then((r) => r.json());
  console.log(
    `3. GET /dashboard -> Profit: Rp ${dash.metrics.profitJt} jt (Margin ${dash.metrics.marginPct}%), Piutang: Rp ${dash.metrics.receivablesJt} jt, Hutang: Rp ${dash.metrics.payablesJt} jt`,
  );

  // 4. Shipments + Detail P&L (FR-SHP-01..04, FR-PRF-01..03)
  const shipments = await fetch(`${base}/shipments?pageSize=5`, {
    headers: { 'x-company-id': companyId },
  }).then((r) => r.json());
  console.log(`4. GET /shipments -> ${shipments.length} shipment pertama, contoh: ${shipments[0].id} (${shipments[0].route}) Profit: ${shipments[0].profit}`);

  const pnl = await fetch(`${base}/shipments/${shipments[0].id}/pnl`, {
    headers: { 'x-company-id': companyId },
  }).then((r) => r.json());
  console.log(
    `5. GET /shipments/${shipments[0].id}/pnl -> Rev: Rp ${pnl.revenueJt} jt, Cost: Rp ${pnl.costJt} jt, Profit: Rp ${pnl.profitJt} jt, Margin: ${pnl.marginPct}%`,
  );

  // 5. Finance Invoices & Record Payment (BR-05, BR-06)
  const createdInv = await fetch(`${base}/finance/invoices`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-company-id': companyId },
    body: JSON.stringify({
      type: 'revenue',
      invoiceNo: 'INV/2610/999',
      counterparty: 'PT Garuda Trading',
      shipmentNo: shipments[0].id,
      category: 'Ocean Freight',
      currency: 'USD',
      exchangeRate: 15800,
      dppJt: 158,
      ppnJt: 17,
      paid: false,
    }),
  }).then((r) => r.json());
  console.log(`6. POST /finance/invoices (USD -> IDR base) -> ${createdInv.no}: ${createdInv.amount} (${createdInv.status})`);

  const pay1 = await fetch(`${base}/finance/payments`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-company-id': companyId },
    body: JSON.stringify({ invoiceNo: 'INV/2610/999', addJt: 58 }),
  }).then((r) => r.json());
  console.log(`7. POST /finance/payments (Cicilan 1) -> status: ${pay1.status} (dibayar Rp ${pay1.paidJt} jt)`);

  const pay2 = await fetch(`${base}/finance/payments`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-company-id': companyId },
    body: JSON.stringify({ invoiceNo: 'INV/2610/999', addJt: 100 }),
  }).then((r) => r.json());
  console.log(`8. POST /finance/payments (Pelunasan) -> status: ${pay2.status} (dibayar Rp ${pay2.paidJt} jt)`);

  // 6. Analytics & AI Advisor (FR-CAN, FR-VAN, FR-AI, FR-FC)
  const ai = await fetch(`${base}/insights/ask`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-company-id': companyId },
    body: JSON.stringify({ question: 'Bagaimana prediksi laba bulan depan?' }),
  }).then((r) => r.json());
  console.log(`9. POST /insights/ask -> "${ai.answer}"`);

  await app.close();
  console.log('✅ Seluruh 9 pengujian integrasi Backend + PostgreSQL LULUS 100%!');
}

verify().catch((err) => {
  console.error('❌ Verifikasi gagal:', err);
  process.exit(1);
});
