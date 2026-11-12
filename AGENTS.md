# AGENTS.md — Rules for AI agents on FreightIntel AI

> Read this first. It applies to every AI agent (Claude, GPT, Gemini, etc.) that
> edits this repo. Context source of truth: [`docs/PRD.md`](docs/PRD.md).
> Current frontend state: [`docs/FRONTEND.md`](docs/FRONTEND.md) — keep it updated.
> Current backend state: [`docs/BACKEND.md`](docs/BACKEND.md) — keep it updated.

## RULE 0 — Documentation is mandatory
Any change to the app MUST be reflected in docs **in the same change**:
- Frontend change → update [`docs/FRONTEND.md`](docs/FRONTEND.md) (what changed, why, new files).
- Backend / DB change → update [`docs/BACKEND.md`](docs/BACKEND.md).
- New decision/convention → add it here or in `docs/FRONTEND.md` / `docs/BACKEND.md`.
- Append a dated line to the **Changelog** at the bottom of `docs/FRONTEND.md`.
A change without doc update is unfinished. This is so the next agent (often a
different AI) understands the app without re-reading all code.

## Project in one line
Flutter mobile app (Android/iOS) + NestJS & PostgreSQL backend for Indonesian
freight-forwarding finance: shipments, revenue/cost, profit, dashboard, AI
insight. Backend (`backend/`) runs on port `4100` with isolated PostgreSQL 16
Docker container (`freightintel-postgres` on `127.0.0.1:5439`).

## Scope right now
Full-stack connected: Flutter frontend (`app/`) + NestJS & Prisma backend (`backend/` on port `4100`) + isolated PostgreSQL 16 Docker (`freightintel-postgres` on `127.0.0.1:5439`). Repositories use `lib/core/network/api_client.dart` with automatic offline fallback.

## Hard conventions (do not break)
- **Language:** UI copy in **Bahasa Indonesia**. (Known debt: some labels still
  English — Revenue/Cost/PAID; migrate to ID when touched.)
- **No AI-slop** (antislop): no ALL-CAPS letter-spaced "eyebrow" labels (use
  sentence case), no em-dash `—` in UI text, no fabricated numbers — demo data
  is labelled honestly ("Angka contoh, belum terhubung data").
- **One accent:** green `#17A55B` only for data/positive/primary action, never
  for plain labels.
- **Design tokens only:** colors/radii/shadows/fonts from
  `lib/core/theme/app_theme.dart`. Don't hard-code hex in screens.
- **Reuse components:** `AppCard`, `StatTile`, `Pressable`, `EmptyState`,
  `Sparkline`, `StatusChip`, illustrations via `lib/core/illustrations.dart`.
- **States:** every data screen handles loading / data / empty / error (PRD).
- **Press feedback + haptic** on interactive elements (use `Pressable`).
- **Money = DECIMAL** semantics when backend lands (PRD BR-04); profit = Σrev−Σcost.
- **No Co-Authored-By Claude** in commits (user rule).

## How to run / iterate
- Emulator AVD `iphone_13` (skin iPhone 13 buatan sendiri, 1170x2532 @460dpi =
  390x844pt) atau `expo_review` (Pixel 6, 1080x2400 @420dpi). Skin hanya
  mengubah bingkai - OS di dalamnya tetap Android.
- **AVD `iphone_13` disimpan di `/home/mip/.avd-data/`, bukan `~/.android/avd/`.**
  `~/.android` adalah symlink ke partisi `Workspace` yang 98% penuh (sisa 3,1G),
  sehingga emulator gagal: `FATAL | Not enough space to create userdata
  partition`. Jangan pindahkan balik. Kalau membuat AVD baru, taruh di
  `/home/mip/.avd-data/` dan arahkan `path=` di berkas `.ini`-nya.
  Mengecilkan `disk.dataPartition.size` **tidak berguna** — emulator menimpanya
  kembali ke 6G setiap start, dan tetap mengukur ruang di folder `.avd`.
- `flutter run -d emulator-5554`. Hot reload = send SIGUSR1 to the run process;
  hot restart = SIGUSR2 (needed after changing a `const` class or adding assets).
- New assets in `pubspec.yaml` need a full rebuild, not hot reload.

## Design & quality skills installed (optional, in ~/.claude/skills)
`apple-design` (HIG audit, Flutter), Emil Kowalski set (`emil-design-eng`,
`choreograph`, `improve-animations`), `antislop` + `antislop-ui`, `ponytail`
(minimal-change coding), `caveman` set (terse token-saving voice + surgical
patch skills). Use them for UI audits and polish.

## Before you finish
1. `flutter analyze lib` is clean (or only pre-existing infos).
2. App runs; you clicked the changed flow.
3. Docs updated per RULE 0.

## Status saat ini (per 2026-11-11)

**Semua modul PRD sudah punya layar frontend.** Tidak ada layar yang perlu
dibuat dari nol lagi. Rinciannya: tabel cakupan di `docs/FRONTEND.md`.

Yang tersisa bukan UI, melainkan **backend + penyambungan**. Jangan mulai
menulis layar baru sebelum membaca `docs/FRONTEND.md` bagian "Known debt".

### Bundling font Onest (TERVERIFIKASI OFFLINE)
Font **Onest sudah dibundel & diverifikasi offline** di `assets/fonts/` + `pubspec.yaml`:
- `google_fonts` mencari berkas di `AssetManifest` dengan nama varian API (`Onest-Regular.ttf`, `Onest-Medium.ttf`, `Onest-SemiBold.ttf`, `Onest-Bold.ttf`, `Onest-ExtraBold.ttf`), bukan `Onest-400..800.ttf`, dan direktori `assets/fonts/` wajib terdaftar di bawah `flutter: assets:`.
- `GoogleFonts.config.allowRuntimeFetching = false` sudah dikunci di `lib/main.dart` dan diuji otomatis di `test/font_bundle_test.dart` (`flutter test` lulus 100% tanpa jaringan).

## Jebakan yang sudah pernah menghabiskan waktu

Baca ini sebelum eksperimen; semuanya sudah pernah terjadi di repo ini.

- **Hot reload vs restart.** Ubah field pada `const` class -> hot reload DITOLAK
  ("Const class cannot remove fields"). Itu batasan hot reload, bukan bug kode.
  Pakai hot restart: `kill -USR2 <pid flutter run>`.
- **Aset baru atau aset yang ditimpa butuh BUILD ULANG PENUH**, bukan reload dan
  bukan restart. Berlaku untuk `assets/illustrations/*`, `assets/fonts/*`, dan
  perubahan `pubspec.yaml`.
- **`pkill -f "flutter run -d chrome"` membunuh shell-nya sendiri** karena pola
  itu cocok dengan baris perintah si pkill. Pakai kelas karakter:
  `pkill -f "run -d chro[m]e"`. Hal sama berlaku untuk `pgrep -f qemu-system`
  (pakai `pgrep -c -x qemu-system-x86_64`).
- **`/tmp` dibersihkan saat tanggal berganti.** Jangan simpan log `flutter run`
  di `/tmp`; proses yang log-nya hilang juga ikut mati.
- **RAM mesin 14 GB dan pernah OOM sampai VS Code terbunuh** gara-gara Gradle
  `-Xmx8G`. Sekarang `android/gradle.properties` dikunci `-Xmx2G` +
  `org.gradle.daemon=false`. Jangan dinaikkan. Tutup `flutter run -d chrome`
  sebelum build Android.
- **HP uji = OPPO A9 2020 (CPH1937), id `c7a35bc8`.** Kalau `adb devices`
  kosong, cek `lsusb`: interface `ff/42/01` = ADB, `ff/ff/00` = mode diag
  (bukan ADB). Di ColorOS: Pengaturan > Tentang ponsel > ketuk Versi 7x, lalu
  Pengaturan tambahan > Opsi pengembang > Debugging USB + Nonaktifkan
  pemantauan izin.
- **HP ini tidak punya internet.** Apa pun yang mengambil sumber daya dari
  jaringan saat runtime akan gagal diam-diam dan merusak tampilan.

## Invarian desain (jangan dilanggar tanpa izin user)

Penjelasan lengkap di `app/DESIGN.md`. Yang paling sering dilanggar agent:

- **Lime `#D3F85A` = aksi interaktif. Hijau `#17A55B` / merah `#E0523D` = arti
  data.** Jangan pakai hijau sebagai dekorasi (mis. latar ikon) dan jangan pakai
  lime untuk menandakan "positif".
- **Satu kartu gelap (`inkDeep`) per layar**, untuk metrik paling penting.
- **Hierarki angka: hero 30px, KPI sekunder 19px, rasio ~1,6x.** Menaikkan KPI
  sekunder ke 24+ membuat layar terasa "besar-besar dan dominan" (user sudah
  pernah menolak ini).
- **Bobot angka w700, bukan w800**, dengan tracking negatif. Pill/tombol kecil
  (11-14px) tetap w800.
- **Avatar dipasang tanpa border.** Cincin putih di atas bg `#EFF1F3` terbaca
  sebagai halo.
- **Struktur bottom nav sudah disetujui user — jangan diubah**, warna saja.
- **Tidak ada kontrol mati.** Fitur yang belum jalan harus menjelaskan diri
  (SnackBar/chip), bukan diam saja saat ditekan.
- **Setiap angka demo ditandai jujur** (`DemoNote`), jangan tampil seolah data
  perusahaan sungguhan.

## Cara user bekerja

- Bahasa Indonesia, langsung ke pokok masalah.
- Sering berganti agent AI -> karena itu RULE 0 ada. Dokumentasi bukan opsional.
- Minta skill dipakai saat ngoding: `ponytail` (perubahan minimal), `caveman`,
  `antislop`/`antislop-ui`, `apple-design`, `impeccable`.
- Tidak suka AI-slop: eyebrow ALL-CAPS, gradien sebagai default, angka palsu.
- Kalau user bertanya "ini kebesaran ga?" atau "ini janggal ga?", dia minta
  **audit dengan angka**, bukan jawaban selera. Ukur dari kode, bandingkan ke
  skala tipe resmi (HIG / Material 3), baru simpulkan.

## Jebakan integrasi app <-> backend (baru, 2026-11-13)

- **Fallback offline itu diam.** Endpoint salah, header hilang, atau server mati
  terlihat **sama persis** dengan kondisi normal: app tetap menampilkan angka
  yang masuk akal. Dua bug pernah lolos lama karena ini. Kalau mengubah
  repository atau endpoint, **buktikan** dengan membandingkan angka di layar
  terhadap `curl` ke endpoint yang sama - jangan percaya "kelihatan jalan".
- **Dashboard menampilkan penanda** "Angka contoh, belum terhubung server"
  saat `ApiClient.lastCallOnline == false`. Jangan dihapus; itu yang membuat
  salah sambung terlihat.
- **Sumber kebenaran path = `docs/BACKEND.md` + log boot NestJS**
  (`grep "Mapped {" ` pada log). Pernah terjadi app memanggil
  `/dashboard/summary` yang tidak pernah ada.
- **Periode dashboard**: backend menerima `daily|monthly|yearly`, bukan
  `Harian|Bulanan|Tahunan`.
- **`companyId` ada di `user.company.id`**, bukan `user.companyId`.
- **TUGAS TERTUNDA: `.ipa` v1.0.1 belum dibangun.** `installer/` masih berisi
  `FreightIntel-AI-v1.0.0-iOS.ipa` yang membawa bug Dashboard lama. Alurnya:
  push -> workflow macOS membangun `.ipa` -> unduh dari GitHub Release ->
  simpan sebagai `installer/FreightIntel-AI-v1.0.1-iOS.ipa` -> user memasang
  ke iPhone-nya sendiri dengan `xtool install`. **`.ipa` tidak bisa dibangun
  dari mesin Linux ini.** Lihat `installer/PANDUAN_INSTALASI_KLIEN.md`.
- **Seluruh rute backend wajib token** sejak 13 Nov 2026 (`JwtAuthGuard` global
  via `APP_GUARD`). Rute baru otomatis ikut terlindungi; pakai `@Public()`
  hanya bila memang harus terbuka. **Konteks perusahaan diambil dari token**,
  bukan dari header `x-company-id` (guard menimpanya), jadi jangan percaya
  header itu. `resolveCompanyId()` melempar `ForbiddenException` bila konteks
  kosong - jangan kembalikan fallback "perusahaan pertama".
- **Build klien di `installer/`**: APK dibangun lokal
  (`flutter build apk --release`), `.ipa` **hanya** dari GitHub Actions
  (`.github/workflows/build-ios.yml`, terpicu saat push). Setiap perbaikan yang
  mengenai klien harus diikuti naik versi di `app/pubspec.yaml` + build ulang,
  kalau tidak klien memakai paket lama yang masih bermasalah.
