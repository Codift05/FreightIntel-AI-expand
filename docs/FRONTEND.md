# FreightIntel AI — Frontend (Flutter)

> Living doc of the mobile frontend. **Update this on every frontend change**
> (see [`../AGENTS.md`](../AGENTS.md) RULE 0). Backend not built; all data is demo.

## Mulai dari sini (serah terima)

Baca `../AGENTS.md` lebih dulu: di sana ada aturan, jebakan teknis, dan
invarian desain. Dokumen ini isinya **keadaan frontend**.

### 1. Status bundling font Onest (terverifikasi offline)
**Bundling font Onest sudah diperbaiki dan terverifikasi tanpa internet.**
Kelima bobot (`Onest-Regular.ttf`, `Onest-Medium.ttf`, `Onest-SemiBold.ttf`,
`Onest-Bold.ttf`, `Onest-ExtraBold.ttf`) terdaftar di `flutter: assets:`
(agar masuk `AssetManifest.bin` yang dibaca `google_fonts`) sekaligus di
`flutter: fonts:`. `GoogleFonts.config.allowRuntimeFetching = false` dikunci di
`lib/main.dart` dan diuji otomatis lewat `test/font_bundle_test.dart`.

### 2. Keadaan sebenarnya
Semua modul PRD sudah punya layar (lihat tabel di bawah). Yang **tidak** ada:
backend, data nyata, persistensi. Semua repository `*_repository.dart` adalah
demo in-memory; perubahan hilang saat app ditutup. Beberapa fitur sengaja
berupa simulasi yang menjelaskan dirinya sendiri (Scan invoice, export laporan,
chat Tanya AI) — itu keputusan sadar, bukan pekerjaan setengah jadi. Jangan
"memperbaiki"-nya dengan membuatnya seolah berfungsi.

### 3. Lanjutan yang masuk akal
1. Mulai backend NestJS + PostgreSQL sesuai PRD, lalu ganti isi tiap
   repository satu per satu. Urutan aman: Shipment -> Revenue/Cost -> Dashboard.
2. Saat backend masuk: uang = DECIMAL (BR-04), isolasi `company_id`
   (FR-CMP-05), RBAC dicek di server (FR-USR-03).

## Stack
- **Flutter / Dart**, Material 3.
- Fonts: `google_fonts` (Onest, SF-like). Icons: `iconsax_plus` (Bold = filled,
  Linear = outline). Motion: `flutter_animate`. Loading: `skeletonizer`.
- No state-management lib yet; screens use `StatefulWidget` + in-memory repos.

## Run
- Emulator: AVD `expo_review` (Pixel 6 skin → device frame),
  `flutter run -d emulator-5554`.
- HP uji: OPPO A9 2020 / CPH1937, `flutter run -d c7a35bc8`. **Tidak ada
  internet di HP ini** — apa pun yang ambil sumber daya dari jaringan saat
  runtime akan gagal.
- Web (paling cepat untuk cek visual): `flutter run -d chrome`.
- Hot reload = `kill -USR1 <pid flutter run>`. Hot restart = `kill -USR2`.
  Restart wajib setelah mengubah field pada `const` class (reload akan ditolak
  dengan "Const class cannot remove fields" — itu batasan hot reload, bukan
  bug kode).
- **Aset baru/ditimpa dan perubahan `pubspec.yaml` butuh build ulang penuh**,
  bukan reload/restart.
- Tutup `flutter run -d chrome` sebelum build Android (RAM 14 GB, pernah OOM).

## Folder map (`app/lib`)
```
core/
  theme/app_theme.dart     # tokens: AppColors, AppRadii, AppShadows, numStyle,
                           # labelStyle (sentence case), kEaseOut curve, theme
  illustrations.dart       # Illus.* asset paths + Illus.mode(type) mapping
  widgets/
    app_card.dart          # AppCard, HighlightCard (profit hero), StatTile
                           # (label + value + delta chip + Sparkline)
    app_bottom_nav.dart    # floating capsule nav, 4 tabs, active = filled icon
                           # + green label + underline (icon weight, not a blob)
    mode_icon.dart         # ModeIcon: glyph moda (ship/airplane/box/truck)
    pressable.dart         # scale-on-press + Semantics wrapper (all tappables)
    screen_header.dart     # ScreenHeader (back+judul+aksi), HeaderAction,
                           # DemoNote — dipakai semua layar yang di-push
    empty_state.dart       # illustration + title + message
    sparkline.dart         # mini trend line w/ grow animation
    logo_mark.dart         # route logo + Wordmark "FreightIntel AI"
features/
  auth/login_screen.dart           # hero illustration + wordmark + demo login
  home/home_shell.dart             # Scaffold: IndexedStack + AppBottomNav, extendBody
  dashboard/dashboard_screen.dart  # greeting+avatar, period chips, profit hero
                                   # (ring + route pattern), 4 stat tiles, bar chart
  shipments/
    shipments_screen.dart          # list (skeleton→data, pagination, empty),
                                   # mode thumbnail + status chip, FAB "+" create
    shipment_detail_screen.dart    # header, P&L, status timeline, revenue/cost
                                   # breakdown, custom fields
    create_shipment_screen.dart    # form: customer/type/origin/dest → new Shipment
    edit_shipment_screen.dart      # ubah data, pindah status, arsipkan
    shipment_repository.dart       # Shipment model, demo data, pagination, cache
    status_chip.dart               # StatusChip + statusColors()
  finance/finance_screen.dart      # saldo + dock aksi + pintasan (Laporan,
                                   # Customer, Vendor, Scan invoice) + invoice
  finance/finance_repository.dart  # Invoice demo data
  finance/invoice_ocr_screen.dart  # Scan invoice: pilih sumber → baca →
                                   # hasil bisa dikoreksi → simpan transaksi
  reports/report_screen.dart       # Laporan bulanan/tahunan: laba rugi,
                                   # arus kas, biaya per kategori, export
  customers/customers_screen.dart  # Peringkat customer + cari + urut
  customers/customer_detail_screen.dart # KPI, tren, shipment terakhir
  customers/customer_repository.dart
  vendors/vendors_screen.dart      # Daftar + mode perbandingan biaya
  vendors/vendor_detail_screen.dart     # KPI, tren biaya, rincian kategori
  vendors/vendor_repository.dart
  settings/settings_screen.dart    # Hub: perusahaan, pengguna, data, keluar
  settings/company_screen.dart     # Profil, logo, mata uang, PPN
  settings/branches_screen.dart    # Daftar + tambah cabang
  settings/users_screen.dart       # Daftar, filter, undang, ubah peran
  settings/role_permissions_screen.dart # Matriks 6 peran x 7 modul x 4 aksi
  settings/activity_log_screen.dart     # Log login & perubahan, per tanggal
  settings/custom_fields_screen.dart    # Kelola custom field per modul
  settings/settings_repository.dart     # Demo in-memory semua di atas
  insight/insight_screen.dart      # Insight AI: kartu temuan gelap, Penyebab,
                                   # Rekomendasi, Prediksi, bar Tanya AI
  insight/ask_ai_screen.dart       # Chat Tanya AI: bubble, saran pertanyaan,
                                   # indikator mengetik, jawaban contoh
```

## Design system (quick)
- **Palet (ikut `docs/Reference Design.png`)**: bg `#EFF1F3` (abu dingin),
  surface putih, line `#E8EAED`; teks ink `#141414` (near-black, 18,4:1),
  inkSoft `#5B6066`, muted `#6B7280`, onDark `#9CA3AF` (label di kartu gelap);
  **aksen interaktif lime `#D3F85A`** (tombol utama, teks di atasnya = ink);
  hijau `#17A55B` + greenBright `#3FD98A` = **data positif** (bukan aksen UI),
  loss `#E0523D` = negatif; inkDeep `#141414` = kartu hero gelap.
- Pola kartu: **hero = kartu gelap** (label abu kecil → nilai besar putih +
  toggle mata → delta pill berwarna → meta abu). Sisanya **kartu putih** di bg
  abu. **StatTile**: label abu → angka besar → delta berwarna + keterangan
  (tanpa ikon/sparkline). Segmented periode: tanpa track, **pill aktif gelap**.
- Radii: card 24, tile 20, input 14, pill 999. Shadow: soft elevation only.
- Type: `numStyle` (tabular, bold, for money/KPI), `labelStyle` (13px w600,
  sentence case — NOT eyebrow caps). Entrance easing `kEaseOut`.
- Illustrations: flat-vector, playful, brand palette, from `assets/illustrations/`
  (Gemini-generated; source raws in `/Asset Generate`, do not delete). Objects
  have no faces; only people (avatar) do.

## Screens: built vs TODO (PRD map)
**Semua modul PRD sudah punya layar frontend (demo data).**

| Modul | Layar | Kode PRD |
|---|---|---|
| Auth | Login | — |
| Dashboard | Dashboard (periode, tren, sorotan) | FR-DSH-01..04 |
| Shipment | Daftar + filter/cari, Detail + P&L, Buat, **Ubah/arsip** | FR-SHP-01..06, FR-PRF |
| Revenue / Cost | Finance, Catat transaksi, Catat pembayaran | FR-REV, FR-CST, BR-06 |
| Laporan | **Laporan keuangan + export** | FR-RPT-01..05 |
| Customer | **Daftar berperingkat + Detail** | FR-CAN-01..03 |
| Vendor | **Daftar + perbandingan + Detail** | FR-VAN-01..03 |
| AI | Insight (temuan, penyebab, rekomendasi, prediksi), chat Tanya AI | FR-AI-01..04, FR-FC |
| OCR | **Scan invoice** | FR-OCR-01..04 |
| Notifikasi | Pusat notifikasi | FR-NOT-05 |
| Perusahaan | **Pengaturan, Profil, Cabang, Pindah perusahaan** | FR-CMP-01..06 |
| Pengguna | **Pengguna, Peran & izin, Log aktivitas** | FR-USR-01..06 |
| Custom field | **Kelola custom field** | FR-CF-01..04 |

Yang tersisa bukan layar baru, melainkan **sambungan ke backend**: data nyata,
isolasi `company_id` di server (FR-CMP-05), RBAC dicek server (FR-USR-03),
AI benar-benar membaca data (FR-AI-05), OCR benar-benar membaca berkas, dan
export PDF/Excel benar-benar menghasilkan file.

## Known debt / audit items
- Semua data masih in-memory (demo): shipment, transaksi, pembayaran, pengaturan,
  pengguna, izin, custom field, cabang, dan status/arsip hilang saat aplikasi
  ditutup — menunggu penyambungan ke backend NestJS + PostgreSQL.
- Insight: analisis & jawaban chat berbasis pencocokan kata kunci data demo.
  Riwayat chat hilang saat layar ditutup.
- Scan invoice mensimulasikan ekstraksi berkas (hasil bisa dikoreksi & disimpan).
- Export PDF/Excel belum menghasilkan file fisik; sheet menjelaskan alasannya.
- Pindah perusahaan baru mengganti konteks label; data modul belum difilter dari server.

## Done (recent audit fixes)
- Seluruh 12 modul PRD (24 layar) lengkap dengan **0 `shortcut:` debt**: `CreateShipmentScreen` & `EditShipmentScreen` kini mencakup Kontainer + Jadwal ETD/ETA (`FR-SHP-01`), `RecordTransactionScreen` mendukung multi-mata uang (`IDR`/`USD`/`SGD`) + kurs ke IDR base (`BR-05`) & `No. Invoice` + pre-select shipment dari Detail, dan `NotificationScreen` mencakup keempat pengingat (`FR-NOT-01..05` termasuk kas rendah) + tombol `Baca semua`.
- Bundling font lokal `Onest` diperbaiki (`Onest-Regular/Medium/SemiBold/Bold/ExtraBold.ttf` + `assets/fonts/` di `AssetManifest` + `allowRuntimeFetching = false`) dan diverifikasi lewat `test/font_bundle_test.dart`; `fl_chart` & `phosphor_flutter` dihapus dari `pubspec.yaml`.
- Dashboard, Finance, Shipments, Detail, and Login aligned to `docs/Reference Design.png` (Lime + Dark two-tier hero card with concentric rings, Finance balance vault with 3-button dock & sparkline rows, interactive trend chart with crosshair & dark tooltip, Shipment Detail dual bottom actions).
- All English UI labels (`Revenue`, `Cost`, `Profit`, `Paid/Partial/Unpaid`, `FREIGHT INTELLIGENCE` eyebrow) migrated to Bahasa Indonesia sentence case; `flutter analyze lib` is 0 issues.
- Dashboard period chips (Harian/Bulanan/Tahunan) swap hero + stat values.
- Insight tab icon changed star → `lamp_charge`. Finance localized to ID.

## Changelog
- 2026-11-12 (aa) — **Build Release APK (`installer/FreightIntel-AI-v1.0.0-release.apk`) + Pengaturan URL Server di Login**:
  - `ApiClient` & `LoginScreen`: tambah `setCustomBaseUrl()` dan sheet **"Alamat server API"** di halaman Login agar APK rilis yang dikirim ke klien bisa langsung berjalan mandiri (offline fallback) maupun diarahkan ke URL server publik/tunnel tanpa perlu *rebuild* APK.
  - `installer/`: buat folder khusus installer berisi `FreightIntel-AI-v1.0.0-release.apk` (`59,7 MB`) dan `PANDUAN_INSTALASI_KLIEN.md` untuk dibagikan via Google Drive.
- 2026-11-12 (z) — **Sambungkan Dashboard, Detail Shipment P&L, Insight AI, Notifikasi, & Mutasi Pengaturan ke Backend NestJS**:
  - `DashboardScreen`: ambil KPI real-time & shipment sorotan dari `GET /api/v1/dashboard/summary` dan tampilkan nama perusahaan aktif di sheet profil (`Owner · <perusahaan aktif>`).
  - `ShipmentDetailScreen`: ambil rincian item invoice pendapatan & biaya nyata dari `GET /api/v1/shipments/:id/pnl` (dan otomatis refresh setelah mencatat transaksi baru di shipment tersebut).
  - `InsightScreen`: ambil *headline*, vendor termahal, dan rentang prediksi bulan depan (`predictedProfitJt`, `lowBandJt`, `highBandJt`) dari `GET /api/v1/insights`.
  - `NotificationScreen`: ambil daftar notifikasi dari `GET /api/v1/notifications` dan hubungkan tombol `Baca semua` ke `PATCH /api/v1/notifications/read-all`.
  - `SettingsRepository` & layar Pengaturan (`CompanyScreen`, `BranchesScreen`, `UsersScreen`, `CustomFieldsScreen`): simpan perubahan profil perusahaan (`PATCH /settings/company`), cabang baru (`POST /settings/branches`), undangan pengguna (`POST /settings/users`), dan custom field baru (`POST /settings/custom-fields`) ke PostgreSQL beserta pencatatan otomatis ke `audit_logs`.
- 2026-11-12 (y) — **Sambungkan seluruh Repository & Layar Flutter ke Backend NestJS (`/api/v1`) dengan Fallback Offline**:
  - `lib/core/network/api_client.dart` (baru): HTTP client ringan berbasis `dart:io` (`HttpClient`) tanpa dependensi eksternal tambahan. Otomatis meresolusi `127.0.0.1:4100` (desktop / `adb reverse`) dan `10.0.2.2:4100` (Android emulator bridge) dengan timeout cepat (`1200ms`) serta mengirim header `x-company-id` (`BR-10`) dan `Authorization: Bearer <token>`.
  - `ShipmentRepository` & `ShipmentsScreen`: `fetchPage()` mengambil dari `GET /api/v1/shipments`, `create()` mengirim `POST /api/v1/shipments`, `update()` menyinkronkan perubahan status/arsip/kontainer/ETD/ETA via `PATCH /api/v1/shipments/:id`.
  - `FinanceRepository`: `fetch()` mengambil daftar invoice live dari `GET /api/v1/finance/invoices`, `add()` menyimpan transaksi pemasukan/biaya baru via `POST /api/v1/finance/invoices` (dengan mata uang & kurs `BR-05`), `recordPayment()` mencatat cicilan/pelunasan via `POST /api/v1/finance/payments` (`BR-06`).
  - `CustomerRepository` & `VendorRepository`: mengambil analitik peringkat profitabilitas customer (`GET /api/v1/customers`) dan perbandingan tarif vendor (`GET /api/v1/vendors`).
  - `SettingsRepository` & `SettingsScreen`: `syncFromBackend()` memuat perusahaan, cabang, pengguna, dan log audit dari `GET /api/v1/settings/overview`; `switchCompany()` mengganti `x-company-id` dan mengosongkan cache repository (`FR-CMP-06`, `BR-10`).
  - `LoginScreen` & `AskAiScreen`: `LoginScreen` mengautentikasi via `POST /api/v1/auth/login` sebelum masuk ke `HomeShell`; `AskAiScreen` memanggil `POST /api/v1/insights/ask` berbasis data perusahaan aktif dengan fallback lokal saat offline.
- 2026-11-11 (x) — **Bangun Backend (`NestJS + Prisma + PostgreSQL 16`) & Database Terisolasi**:
  - `backend/docker-compose.yml`: container PostgreSQL 16 terisolasi (`freightintel-postgres`, network `freightintel-net`, volume `freightintel-pgdata`, port host `127.0.0.1:5439:5432`) — sama sekali tidak menyentuh container proyek lain (`biotrace-*`, `prima-hsse-*`).
  - `backend/prisma/schema.prisma` & `seed.ts`: seluruh 18 tabel ERD PRD §8.2 dengan tipe uang `Decimal @db.Decimal(18, 2)` (`BR-04`), isolasi `companyId` (`BR-10`), serta data awal lengkap (2 perusahaan, 3 cabang, 6 peran RBAC + 28 izin, user `bcrypt`, 20 shipment, invoice revenue/cost, cicilan `payments`, custom field, notifikasi, audit log).
  - `backend/src/*`: modul REST API NestJS (`/api/v1` di port `4100`) untuk `auth`, `dashboard`, `shipments` (+ P&L otomatis `BR-01..03`), `finance` (+ multi-mata uang `BR-05` & cicilan `BR-06`), dan `analytics` (`customers`, `vendors`, `insights`, `notifications`, `settings`).
  - `backend/test/verify-api.ts` & `docs/BACKEND.md`: 9 skenario uji integrasi end-to-end lulus 100%.
- 2026-11-11 (w) — **Tuntaskan seluruh celah detail PRD di frontend (0 `shortcut:` debt)**:
  - `CreateShipmentScreen`, `EditShipmentScreen`, `ShipmentDetailScreen`, & `Shipment` (`FR-SHP-01`): tambah field `Kontainer / Kargo` serta jadwal `ETD` & `ETA` (dengan date picker) yang langsung tampil di kartu informasi kargo Detail Shipment; seragamkan header dengan `ScreenHeader`.
  - `RecordTransactionScreen` & `Invoice` (`FR-REV-01`, `FR-CST-01`, `BR-05`): tambah `No. Invoice`, pemilih mata uang (`IDR`/`USD`/`SGD`) + input kurs ke IDR dengan pratinjau konversi otomatis ke ekuivalen IDR base, serta pre-select `initialShipmentNo` saat dibuka dari `ShipmentDetailScreen`.
  - `NotificationScreen` (`FR-NOT-01..05`): tambah pengingat kas operasional rendah (`FR-NOT-04`), seragamkan `ScreenHeader`, dan tambah aksi `Baca semua`.
  - `app_theme.dart`: hapus alias token lama `navy`/`border` (`0 shortcut:` tersisa di seluruh `lib/`).
- 2026-11-11 (v) — **Perbaiki resolusi aset lokal `Onest` di `google_fonts` + hapus dependensi mati**:
  - Audit sumber `google_fonts-8.2.1` (`findFamilyWithVariantAssetPath`) menemukan bahwa paket ini mencari berkas di `AssetManifest` berdasarkan nama varian API (`Onest-Regular.ttf`, `Onest-Medium.ttf`, `Onest-SemiBold.ttf`, `Onest-Bold.ttf`, `Onest-ExtraBold.ttf`), bukan `Onest-400..800.ttf`, serta mewajibkan folder `assets/fonts/` terdaftar di bawah `flutter: assets:` (bukan hanya `flutter: fonts:`).
  - Berkas di `app/assets/fonts/` diganti namanya sesuai konvensi `google_fonts`, `- assets/fonts/` ditambahkan ke `pubspec.yaml`, dan `GoogleFonts.config.allowRuntimeFetching = false` dikunci di `lib/main.dart` agar aplikasi tidak pernah mengunduh font saat runtime.
  - Tambah pengujian otomatis `app/test/font_bundle_test.dart` yang memverifikasi pemuatan 5 bobot `Onest` (`w400`–`w800`) secara offline (`flutter test` = lulus).
  - Hapus `fl_chart` dan `phosphor_flutter` dari `pubspec.yaml` (0 impor di seluruh `lib/`).
  - Perbarui *knowledge graph* `app/graphify-out/` dan `AGENTS.md`.
- 2026-11-11 (u) — **Onest dibundel lokal + dokumentasi serah terima**.
  - Build pertama ke HP (CPH1937) berhasil terpasang, tapi logcat menunjukkan
    `google_fonts was unable to load font Onest-Bold` -> `Failed host lookup:
    fonts.gstatic.com`. **HP tidak punya internet**, dan `google_fonts`
    mengunduh font saat runtime, jadi yang dirender Roboto, bukan Onest.
  - Perbaikan: 5 bobot Onest (400/500/600/700/800) diunduh sebagai TTF ke
    `app/assets/fonts/` dan dideklarasikan di `pubspec.yaml` dengan family
    persis `Onest`; `google_fonts` otomatis memakai berkas lokal. Tidak ada
    lagi unduhan runtime. Penting untuk pemakaian di lapangan/pelabuhan yang
    sinyalnya tidak menentu.
  - **Belum terverifikasi di perangkat**: HP lepas dari USB sebelum build ulang
    selesai, dan log-nya hilang saat `/tmp` dibersihkan pergantian tanggal.
    Dicatat sebagai butir pertama di bagian "Mulai dari sini".
  - `AGENTS.md` diperluas: status proyek, daftar jebakan teknis yang sudah
    pernah memakan waktu (hot reload vs restart, aset butuh rebuild, pkill
    membunuh shell sendiri, /tmp terhapus, batas RAM/Gradle, cara menyambung
    HP OPPO), invarian desain, dan cara kerja user.
  - `docs/FRONTEND.md` dapat bagian **"Mulai dari sini (serah terima)"**.
- 2026-11-10 (t) — **Ikon moda diganti vektor + bobot font uang diturunkan**:
  - `core/widgets/mode_icon.dart` (baru): `ModeIcon` — glyph `iconsax_plus`
    (`ship` / `airplane` / `box` / `truck_fast`) dalam kotak `surfaceAlt`
    radius 0,32x ukuran, ikon `ink`. Menggantikan disc ilustrasi raster
    `mode_*.png` yang pecah di 34-46px **dan** memakai `greenSoft` sebagai
    dekorasi (hijau dicadangkan untuk arti data). Dipakai di kartu Shipments
    (46px) dan sorotan Dashboard (34px).
  - `Illus.mode()` + 4 konstanta `mode*` dihapus (kode mati). Berkas PNG-nya
    masih ada di `assets/illustrations/` tapi tidak lagi dirujuk.
  - `numStyle`: bobot **w800 -> w700** (w800 di Onest terbaca terlalu padat
    untuk nominal besar) + **tracking negatif** menurut ukuran: -0,8 di >=26px,
    -0,4 di >=20px, -0,2 selebihnya. Satu override `weight: w800` di header
    Dashboard ikut dilepas. Berlaku ke 86 pemakaian di seluruh app sekaligus.
    Pill/tombol kecil (11-14px) tetap w800 karena di ukuran itu bobot tebal
    justru menjaga keterbacaan.
- 2026-11-10 (s) — **Avatar header: hilangkan "putih janggal"**. Dua sebab,
  keduanya diperbaiki:
  1. `border: Border.all(color: AppColors.surface, width: 2)` di avatar header
     Dashboard = **cincin putih 2px**. Di atas bg abu `#EFF1F3` itu terbaca
     sebagai halo. Dihapus; latar aset sudah `greenSoft` jadi menyatu sendiri.
  2. Aset `avatar_owner.png` berisi bust lengkap: kerah V di antara jas navy
     berwarna mint `#E7F6EE` yang **sangat pucat**, jadi di ukuran 42px terbaca
     sebagai blob putih. Aset **dikrop ulang** jadi potret kepala
     (`crop(90, 40, 340x340)` lalu skala ke 512) sehingga kerah itu keluar dari
     lingkaran. Aset asli dipertahankan di `/Asset Generate`.
  Catatan: ganti aset butuh **rebuild penuh**, bukan hot reload.
- 2026-11-10 (r) — **Kalibrasi skala tipe Dashboard** (audit: layout terasa
  terlalu besar & dominan). Masalahnya bukan semuanya kegedean, tapi
  **hierarki hilang**: hero 30px vs StatTile 24px = rasio 1,25x, padahal
  `24` itu setara M3 `headlineSmall` / HIG Title2 — ukuran judul halaman,
  dipakai 4x untuk KPI sekunder.
  - `StatTile`: nilai **24 -> 19** (rasio hero:tile jadi 1,58x, masuk rentang
    1,6x yang dipakai app finance matang), padding 16 -> 14/13, jarak internal
    8 -> 6, ikon delta 18 -> 15, delta 12,5 -> 11,5, keterangan 11,5 -> 11.
    Tinggi tile turun dari ~110px ke ~78px.
  - `HighlightCard`: **hero tetap 30px** (kontras datang dari mengecilkan yang
    sekunder, bukan mengecilkan yang utama). Pita lime vertikal 13 -> 10,
    padding badan 18/20 -> 16/18.
  - Dashboard: jarak hero->tile dan antar baris tile 14 -> 12.
  - Hasil: ruang sebelum grafik turun ~100px, jadi kartu tren ikut terbaca di
    layar pertama (sebelumnya terpotong di sekitar label "1,5M").
- 2026-11-10 (q) — **Semua layar PRD yang belum ada dibangun** (9 modul, 16 file
  baru). Entry point: Finance dapat baris pintasan (Laporan · Customer · Vendor ·
  Scan invoice), avatar Dashboard → sheet profil → **Pengaturan**, header
  Shipment Detail dapat tombol **Ubah**.
  - **Laporan keuangan** (FR-RPT-01..05): mode Bulanan/Tahunan, chip periode,
    hero laba + delta, tabel laba rugi (pendapatan, biaya, laba kotor, margin),
    arus kas (saldo awal → masuk → keluar → saldo akhir), batang biaya per
    kategori, sheet export PDF/Excel yang menjelaskan kenapa belum aktif.
  - **Customer analytics** (FR-CAN-01..03): kartu temuan AI, cari, urut
    laba/pendapatan/margin, daftar berperingkat; detail = hero laba + tag
    risiko bayar, 4 KPI, sparkline tren, shipment terakhir.
  - **Vendor analytics** (FR-VAN-01..03): kartu potensi hemat, daftar dengan
    tanda tarif vs rata-rata pasar, **mode perbandingan** (batang biaya
    relatif, merah bila di atas pasar); detail = rincian biaya per kategori.
  - **Pengaturan** (hub) + **profil perusahaan** (FR-CMP-03/04: nama, NPWP,
    alamat, mata uang, PPN, logo), **cabang** (FR-CMP-02), **pindah
    perusahaan** lewat sheet (FR-CMP-01/06, menyebut isolasi data FR-CMP-05).
  - **Pengguna & RBAC**: daftar + filter aktif/nonaktif + undang + ubah peran
    (FR-USR-01), **matriks izin** 6 peran × 7 modul × 4 aksi yang bisa diketuk,
    Super Admin terkunci penuh (FR-USR-02/03/04), **log aktivitas**
    dikelompokkan per tanggal (FR-USR-06).
  - **Custom field** (FR-CF-01..04): chip per modul target, daftar dengan tipe
    & tanda wajib, tambah field (7 tipe), hapus dengan **Batalkan** di SnackBar,
    empty state per modul.
  - **Scan invoice** (FR-OCR-01..04): 3 sumber (kamera/galeri/PDF) → status
    membaca → hasil ekstraksi yang **bisa dikoreksi** → simpan jadi transaksi
    di `FinanceRepository`. Ditandai jelas sebagai simulasi.
  - **Ubah shipment** (FR-SHP-05/06): pindah status lewat daftar siklus
    Booking→Completed yang bisa diketuk, ubah customer/rute/moda, **arsipkan**
    dengan dialog konfirmasi yang menyebut data transaksi tidak dihapus.
    `Shipment` dapat `copyWith` + `arsip`; `ShipmentRepository.update()`;
    daftar menyembunyikan yang diarsipkan dan menyegarkan diri saat kembali
    dari detail. `ShipmentDetailScreen` jadi `StatefulWidget` supaya status
    yang baru langsung tampil.
  - Komponen baru `core/widgets/screen_header.dart`: `ScreenHeader`,
    `HeaderAction`, `DemoNote` — dipakai 12 layar baru supaya header konsisten.
  - Semua layar: copy Bahasa Indonesia, token desain saja, `Pressable` +
    haptic, state kosong/termuat ditangani, dan setiap angka ditandai contoh.
    `flutter analyze lib` = 0 issues.
- 2026-11-10 (p) — **Chat Tanya AI + rapikan kartu Rekomendasi**:
  - `insight/ask_ai_screen.dart` (baru, FR-AI-04): layar chat penuh. Keadaan
    awal = kartu ajakan gelap + **4 pertanyaan siap pakai** (tap langsung
    kirim), bukan layar kosong. Bubble: milik user `ink` + teks putih rata
    kanan, jawaban kartu putih rata kiri, sudut bawah sisi pemilik 6 (sisanya
    20). **Indikator mengetik** 3 titik (repeat reverse) selama 750ms.
    Composer: `TextField` 1–4 baris + tombol kirim bulat lime. Tombol
    `refresh_2` di header untuk mulai ulang percakapan.
  - Jawaban **bukan model AI** — pencocokan kata kunci ke 6 jawaban contoh
    (margin/rute/piutang/biaya/prediksi/laba) + fallback jujur yang menyebut
    topik apa saja yang tersedia. Ditandai "Jawaban dari data demo" di header
    dan di bawah daftar saran (R-17/R-38).
  - `insight_screen.dart`: bar Tanya AI sekarang **membuka chat**; chip "Segera"
    diganti tombol bulat lime panah (R-26: kontrol hidup, bukan mati).
  - **Perbaikan tata letak**: `Column` terluar di `_recCard`/`_causeCard` pakai
    `crossAxisAlignment` default (**center**) sehingga tiap baris menyusut ke
    lebar isinya dan terlihat ragged/rata tengah. Diubah ke `stretch`, chip
    dampak dibungkus `Align` kiri supaya tidak ikut melar.
- 2026-11-10 (o) — **Layar Insight AI dibangun** (ganti placeholder "Segera
  hadir"), ikut `impeccable` craft-floor + `antislop`:
  - `insight/insight_screen.dart`: **kartu temuan gelap** (`inkDeep`) yang
    *memimpin dengan kalimat*, bukan template angka besar ("Profit naik 12%,
    tapi margin rute Jakarta → Tokyo turun 6 poin") + baris pendukung + meta
    "128 shipment · Oktober 2026". Ini satu-satunya momen motion yang diberi
    niat (`fadeIn 420ms` + `slideY 0.08`, `kEaseOut`).
  - **Penyebab** (FR-AI-02): kartu putih, 3 baris `nama · delta berwarna ·
    rupiah`, dibatasi divider — bukan 3 kartu ikon+judul+teks seragam.
  - **Rekomendasi** (FR-AI-03): judul tindakan + alasan 1 baris + chip dampak
    (`greenSoft`/`greenInk`), mis. "hemat Rp 24 jt/bln".
  - **Prediksi bulan depan** (FR-FC): nilai + delta hijau, **pita rentang**
    (batas bawah/atas `Rp 760 jt`–`Rp 880 jt`), catatan asal hitungan.
  - **Bar Tanya AI** (FR-AI-04): placeholder jujur — chip lime "Segera", tap →
    SnackBar "Tanya AI aktif setelah data perusahaan terhubung" (R-26: tidak
    ada kontrol mati tanpa penjelasan).
  - Semua angka ditandai contoh ("Analisis contoh dari data demo", R-17/R-38).
    4 state: `Skeletonizer` 600ms → data. `flutter analyze` = 0 issues.
  - **`app/DESIGN.md` ditulis ulang** (sebelumnya masih sistem lama: navy
    `#16365C`, aksen hijau, Plus Jakarta Sans, phosphor, FAB tengah, label
    ALL-CAPS). Sekarang cocok dengan kode: palet near-black + lime, Onest,
    iconsax_plus, nav 4 tab tanpa FAB, label sentence case, aturan "lime =
    aksen interaktif / hijau-merah = arti data", dan pola kartu daftar
    ber-divider.
- 2026-11-09 (n) — **Selaraskan seluruh layar utama ke `docs/Reference Design.png` + audit `antislop`/`impeccable`/`ponytail` + pasang `graphify` (`app/graphify-out/`)**:
  - `HighlightCard` (`app_card.dart`): dukung pita atas **Lime `#D3F85A`** dua-tingkat + motif lingkaran konsentris (`_RingsPainter`) untuk Dashboard, dan mode gelap ringkas + delta pill untuk Detail Shipment.
  - `DashboardScreen`: header 1 baris ("Halo, Owner!" + lonceng + avatar dgn sheet profil & tombol Keluar), StatTile berbahasa Indonesia (`Pendapatan`, `Biaya`, `Piutang`, `Hutang`), grafik kurva interaktif (`_InteractiveTrendCard`) dengan crosshair putus-putus & tooltip gelap (`Masuk` / `Biaya`), serta kartu `Sorotan Pengiriman` di bawah.
  - `FinanceScreen`: kartu saldo gelap di atas (`_buildBalanceVault`) + dock 3 tombol bulat (`Pemasukan`, `Biaya`, `Catat Baru` lime) + search bar kapsul + filter status (`Semua`/`Belum lunas`/`Lunas`) + daftar invoice dengan mini `Sparkline`.
  - `ShipmentsScreen` & `ShipmentDetailScreen`: search bar kapsul, migrasi label ke Bahasa Indonesia (`Moda`, `Pendapatan`, `Laba`, `Lunas`/`Cicilan`/`Belum lunas`), header tengah + 2 tombol aksi bawah (`Catat Biaya ↗` gelap & `Catat Masuk ↙` lime) yang langsung membuka `RecordTransactionScreen`.
  - `LoginScreen`: hapus eyebrow all-caps `FREIGHT INTELLIGENCE` (R-06 antislop) → subjudul kalimat Bahasa Indonesia. Bersihkan 3 lint `unnecessary_underscores` (`flutter analyze lib` = 0 issues).
- 2026-11-09 (m) — **Rombak design system penuh ikut `docs/Reference Design.png`**:
  palet baru (bg abu dingin, teks near-black, aksen **lime** utk tombol utama,
  hijau/merah khusus data). Hero = kartu **hitam** + delta pill. **StatTile
  dirombak** (label abu → angka besar → delta + keterangan; ikon & sparkline
  dibuang) — sekaligus **memperbaiki RenderFlex overflow** (garis merah di HP).
  Segmented periode tanpa track. Bottom nav tidak diubah (permintaan user).
- 2026-11-09 (l) — **Design system ikut `docs/Reference Design.png`**: hero
  profit jadi **kartu gelap** `inkDeep #111C2E` (label abu kecil, nilai putih
  32px, delta `▲ +12%` hijau terang di kanan, meta abu). Segmented periode:
  pill aktif **gelap** (bukan hijau). Palet dirapikan: `greenCard`/`greenPanel`
  dihapus, `inkDeep` + `greenBright` ditambah. Bottom nav tidak diubah.
- 2026-11-09 (k) — HighlightCard disederhanakan (referensi kartu "Weekly
  Progress"): satu card terang `greenPanel #C3E9D8`, chip ikon+label kecil di
  atas, nilai besar navy (tap = ringkas/detail) + toggle mata, meta 1 baris,
  dan **ring progres di kanan** berisi `+%` + keterangan kecil ("naik").
  Dua-zona/panel putih/badge dihapus. Teks navy di atas mint = kalem, AA aman.
- 2026-11-08 (i) — HighlightCard dua-zona (ikut wondr): kiri panel terang berisi
  ring "+%" + label "Pertumbuhan"; kanan judul + nilai + mata. Hijau solid.
- 2026-11-08 (h) — HighlightCard: nilai punya 2 opsi — tap angka untuk toggle
  ringkas ("Rp 26 jt") ↔ detail ("Rp 26.450.000"), auto-fit (FittedBox) biar tak
  kepotong. `_PData.profitFull` per periode. Logo header → favicon-48 (simbol).
- 2026-11-08 (g) — Header: Wordmark diganti logo (`assets/logo.png` dari
  logo kit). Avatar 46→40, ikon notif 26→22 (lebih ringkas). HighlightCard
  (profit hero) gaya wondr: **hijau solid** (bukan gradient diagonal, anti-slop),
  teks putih, toggle mata **inline** dengan nilai, ring dalam panel translucent
  (intentional, bukan mengambang). Warna tetap hijau brand.
- 2026-11-08 (f) — Header Dashboard gaya wondr: 2 baris — (1) Wordmark + tombol
  "Keluar" (logout → Login), (2) avatar + sapaan + aksi Notifikasi (ikon + label
  + dot unread).
- 2026-11-08 (e) — Transisi pindah layar global: `CupertinoPageTransitionsBuilder`
  (slide horizontal + swipe-back) untuk semua platform via `pageTransitionsTheme`.
  Shipments: FAB mengambang diganti tombol "+" di header (kanan judul), empty
  state dapat tombol "Buat shipment" (lebih clean). Impor `flutter/cupertino.dart`.
- 2026-11-08 (d) — Dashboard periode: segmented control gaya wondr dengan pill
  hijau yang **geser mengikuti offset swipe** (sinkron `PageController` via
  AnimatedBuilder, teks interpolasi warna). Konten per-periode dalam `PageView`
  (swipe kiri/kanan), halaman di-keep-alive (`AutomaticKeepAliveClientMixin`) +
  `allowImplicitScrolling` (pre-render tetangga) biar mulus/anti-lag. Header +
  tab tetap di atas.
- 2026-11-08 (c) — Catat pembayaran/cicilan (tap invoice → sheet →
  `FinanceRepository.recordPayment`, status Lunas/Cicilan/Belum; Invoice gains
  `paidRupiah`, `copyWith`, `totalJt`). Notification center (bell → list,
  read/unread, unread dot on bell). Dashboard period chips wired (hero + 4 stat
  values per Harian/Bulanan/Tahunan). Insight tab icon star → lamp_charge.
  Files: `notifications/notification_screen.dart`.
- 2026-11-08 (b) — Shipments filter (status chips) + search (id/customer/route).
  Finance "Catat transaksi": choose Pemasukan/Biaya → `RecordTransactionScreen`
  form (customer/vendor, optional shipment link, category, date, DPP + PPN,
  paid toggle) → `FinanceRepository.add`. Finance localized to ID
  (Pendapatan/Biaya/Laba, Lunas/Belum lunas). `finance_repository` extended with
  typed `Invoice` fields + `FinanceEntryType`. Files: `record_transaction_screen.dart`.
- 2026-11-08 — Shipment detail + P&L + status timeline; tappable cards; status
  chips on list; Create Shipment form + FAB. Illustration system wired (login
  hero, avatar, mode thumbnails, insight hero, empty states, dashboard pattern).
  Stat tiles got sparkline + delta chips. Bottom nav redesigned to floating
  labeled capsule (icon-weight active state). De-slopped labels (sentence case).
  Emulator given Pixel 6 device frame.
