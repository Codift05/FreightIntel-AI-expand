# FreightIntel AI — Backend (NestJS + Prisma + PostgreSQL)

> Dokumen arsitektur & operasional backend (`backend/`). Sesuai **RULE 0** di [`../AGENTS.md`](../AGENTS.md), perbarui dokumen ini setiap kali ada perubahan skema, endpoint, atau aturan bisnis di backend.

## 1. Isolasi & Keamanan Infrastruktur Lokal
Backend dan database dirancang **100% terisolasi** agar tidak pernah mengganggu container/port proyek lain di mesin ini (`biotrace-*`, `prima-hsse-*`, dll.):
- **Docker Container:** `freightintel-postgres` (`postgres:16-alpine`)
- **Docker Network:** `freightintel-net` (bridge terpisah)
- **Port PostgreSQL Host:** `127.0.0.1:5439 -> 5432` (tidak menyentuh `5432`, `55432`, `55433`)
- **Penyimpanan Data DB:** Docker named volume `freightintel-pgdata` (terisolasi dari proyek lain)
- **Port REST API NestJS:** `4100` (`http://localhost:4100/api/v1`, atau `http://10.0.2.2:4100/api/v1` dari Android Emulator `emulator-5554`)

## 2. Struktur Folder (`backend/`)
```
backend/
  docker-compose.yml         # PostgreSQL 16 terisolasi (port 5439)
  prisma/
    schema.prisma            # 18 tabel ERD PRD §8.2 (uang = Numeric(18,2) BR-04)
    seed.ts                  # Seeder idempotent (perusahaan, cabang, 6 peran RBAC,
                             # user bcrypt, 20 shipment, invoice, cicilan, notifikasi)
  src/
    main.ts                  # Bootstrap NestJS di port 4100, prefix /api/v1 + CORS
    app.module.ts            # Root module + GET /api/v1/health
    prisma/                  # PrismaService + resolusi tenant company_id (BR-10)
    auth/                    # POST /api/v1/auth/login (JWT + bcrypt), GET /api/v1/auth/me
    shipments/               # CRUD shipment + kalkulasi P&L otomatis (BR-01..03, BR-08)
    finance/                 # Invoice Revenue/Cost + multi-currency (BR-05) + cicilan (BR-06)
    dashboard/               # Ringkasan per periode, arus kas, piutang/hutang, tren (FR-DSH)
    analytics/               # Customer/Vendor analytics, AI Advisor, Notifikasi, Pengaturan
  test/
    verify-api.ts            # Pengujian integrasi otomatis seluruh endpoint REST + DB
```

## 3. Daftar Endpoint REST API (`/api/v1`)
| Metode | Endpoint | Fungsi & Aturan Bisnis PRD |
|---|---|---|
| `GET` | `/api/v1/health` | Status koneksi database & jumlah record utama |
| `POST` | `/api/v1/auth/login` | Login (`bcrypt` + `JWT`), mengembalikan profil user, perusahaan, dan daftar kode izin RBAC (`SEC-01`, `FR-USR-02..04`) |
| `GET` | `/api/v1/auth/me` | Profil pengguna & perusahaan aktif |
| `GET` | `/api/v1/dashboard?period=daily\|monthly\|yearly` | Ringkasan Revenue, Cost, Gross Profit, Margin, Piutang (`BR-07`), Hutang (`BR-07`), PPN Keluaran/Masukan (`BR-12`), tren 6 bulan, dan sorotan shipment (`FR-DSH-01..04`) |
| `GET` | `/api/v1/shipments` | Daftar shipment berpaginasi + filter status + pencarian + P&L otomatis (`FR-SHP-03`, `BR-01..03`) |
| `GET` | `/api/v1/shipments/:id/pnl` | Rincian laba-rugi shipment beserta daftar item revenue & cost (`FR-SHP-04`, `FR-PRF-01..03`) |
| `POST` | `/api/v1/shipments` | Buat shipment baru (nomor unik otomatis, kontainer, ETD/ETA, audit log `FR-SHP-01..02`) |
| `PATCH` | `/api/v1/shipments/:id` | Ubah data/status siklus shipment atau arsipkan tanpa hapus transaksi (`FR-SHP-05..06`, `BR-08`) |
| `GET` | `/api/v1/finance/invoices` | Daftar gabungan invoice pemasukan (`Revenue`) & biaya (`Cost`) beserta status pembayaran |
| `POST` | `/api/v1/finance/invoices` | Catat invoice baru dengan dukungan multi-mata uang (`IDR`/`USD`/`SGD`) + kurs ke IDR base (`BR-05`) & pemisahan DPP/PPN (`BR-03`, `BR-12`) |
| `POST` | `/api/v1/finance/payments` | Catat pembayaran/cicilan bertahap; otomatis memperbarui status `UNPAID` → `PARTIAL` → `PAID` (`BR-06`) & mencatat audit trail (`BR-09`) |
| `GET` | `/api/v1/customers` | Peringkat profitabilitas, pendapatan, margin, dan risiko bayar customer (`FR-CAN-01..03`) |
| `GET` | `/api/v1/vendors` | Analisis biaya, ketepatan waktu, dan indeks tarif vendor vs pasar (`FR-VAN-01..03`) |
| `GET` | `/api/v1/insights` | Temuan AI Business Intelligence & pita prediksi laba bulan depan (`FR-AI-01..04`, `FR-FC-01..02`) |
| `POST` | `/api/v1/insights/ask` | Tanya AI berbasis data perusahaan terisolasi (`FR-AI-01`, `FR-AI-05`, `BR-10`) |
| `GET` | `/api/v1/notifications` | Daftar notifikasi in-app (`FR-NOT-01..05`) |
| `PATCH` | `/api/v1/notifications/read-all` | Tandai semua notifikasi sudah dibaca |
| `GET` | `/api/v1/settings/overview` | Data perusahaan, cabang, pengguna, peran RBAC, custom field, dan audit log |
| `PATCH` | `/api/v1/settings/company` | Perbarui identitas, mata uang utama, dan tarif PPN perusahaan aktif + audit log (`FR-CMP-03..04`) |
| `POST` | `/api/v1/settings/branches` | Tambah cabang perusahaan baru + audit log (`FR-CMP-02`) |
| `POST` | `/api/v1/settings/users` | Undang pengguna baru ke perusahaan aktif + audit log (`FR-USR-01`) |
| `POST` | `/api/v1/settings/custom-fields` | Tambah custom field dinamis per modul + audit log (`FR-CF-01..04`) |

## 4. Cara Menjalankan & Menguji
```bash
# 1. Jalankan container PostgreSQL terisolasi (port 5439)
docker compose -f backend/docker-compose.yml up -d

# 2. Push skema Prisma & isi data awal (seed)
npm --prefix backend run prisma:push
npm --prefix backend run prisma:seed

# 3. Jalankan pengujian integrasi otomatis (9 skenario end-to-end)
npm --prefix backend test

# 4. Jalankan server API di port 4100
npm --prefix backend run start:dev
```

## 5. Celah terbuka (temuan audit 13 Nov 2026)

### 5.1 Seluruh endpoint tidak terproteksi — ✅ DITUTUP 13 Nov 2026
`POST /auth/login` **sudah** menerbitkan JWT sungguhan
(`jwt.signAsync`, `auth.service.ts:57`), dan aplikasi **sudah** mengirim
`Authorization: Bearer <token>` + `x-company-id` di setiap permintaan
(`api_client.dart`). Tetapi backend **tidak pernah memeriksanya**:
`grep -rn "@UseGuards" backend/src` -> **0 hasil**.

Terbukti, tanpa token sama sekali:
```
GET /api/v1/dashboard        -> HTTP 200
GET /api/v1/finance/invoices -> HTTP 200
GET /api/v1/settings/overview-> HTTP 200
```
Diperparah `PrismaService.resolveCompanyId()`: bila header `x-company-id`
tidak ada, ia **jatuh ke perusahaan pertama** (`findFirst`), bukan menolak.
Jadi siapa pun yang bisa menjangkau server membaca seluruh data keuangan
perusahaan pertama tanpa autentikasi apa pun.

Ini melanggar FR-USR-03 (RBAC dicek di server) dan FR-CMP-05 (isolasi data).
**Wajib ditutup sebelum backend dipublikasikan ke VPS/internet**, karena saat
itulah celah ini berubah dari risiko lokal menjadi kebocoran data nyata.

Sisi klien sudah siap: token dan header perusahaan sudah dikirim, jadi
menambahkan guard + mengambil `companyId` dari token (bukan dari header yang
bisa dipalsukan) tidak perlu mengubah aplikasi.

**Perbaikan yang diterapkan:**
- `src/auth/jwt-auth.guard.ts` (baru) — `JwtAuthGuard` memverifikasi
  `Authorization: Bearer`, lalu **menimpa** `x-company-id` dengan `companyId`
  dari dalam token. Header klien tidak lagi dipercaya, dan seluruh controller
  yang membaca header itu tidak perlu diubah sama sekali.
- `src/auth/public.decorator.ts` (baru) — `@Public()` untuk rute terbuka.
- `app.module.ts` — guard dipasang global lewat `APP_GUARD`. Hanya
  `POST /auth/login` dan `GET /health` yang `@Public()`.
- `prisma.service.ts` — `resolveCompanyId()` **tidak lagi** jatuh ke
  perusahaan pertama bila konteks kosong; sekarang melempar
  `ForbiddenException`. Fallback diam itulah yang membuat kebocoran tak
  terlihat.
- `test/verify-api.ts` — seluruh permintaan kini membawa token.

**Hasil uji:**
```
TANPA token: /dashboard /finance/invoices /settings/overview
             /shipments /customers        -> HTTP 401
PUBLIK     : /health                      -> HTTP 200
DENGAN token: /dashboard                  -> HTTP 200
x-company-id dipalsukan ke perusahaan lain -> diabaikan, tetap profitJt=1254
Suite integrasi                            -> 9/9 LULUS
Aplikasi di emulator                       -> tetap menampilkan data server
```

**Belum tercakup (lanjutan):** pengecekan izin per-peran per-modul
(FR-USR-04) belum ada — token yang sah saat ini boleh mengakses semua
modul. Super Admin lintas-perusahaan (FR-USR-07) juga belum.

### 5.2 Belum ada endpoint laporan
`FR-RPT-03/04` (export PDF & Excel) adalah **MUST** di PRD, tetapi tidak ada
rute `/reports`. Layar Laporan di aplikasi masih menampilkan pesan jujur bahwa
fitur ini aktif setelah backend siap.

### 5.3 OCR invoice belum ada di backend
`FR-OCR` masih simulasi di sisi aplikasi; belum ada endpoint unggah/ekstraksi.
