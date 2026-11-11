# AGENTS.md — Rules for AI agents on FreightIntel AI

> Read this first. It applies to every AI agent (Claude, GPT, Gemini, etc.) that
> edits this repo. Context source of truth: [`docs/PRD.md`](docs/PRD.md).
> Current frontend state: [`docs/FRONTEND.md`](docs/FRONTEND.md) — keep it updated.

## RULE 0 — Documentation is mandatory
Any change to the app MUST be reflected in docs **in the same change**:
- Frontend change → update [`docs/FRONTEND.md`](docs/FRONTEND.md) (what changed, why, new files).
- New decision/convention → add it here or in `docs/FRONTEND.md`.
- Append a dated line to the **Changelog** at the bottom of `docs/FRONTEND.md`.
A change without doc update is unfinished. This is so the next agent (often a
different AI) understands the app without re-reading all code.

## Project in one line
Flutter mobile app (Android/iOS) for Indonesian freight-forwarding finance:
shipments, revenue/cost, profit, dashboard, AI insight. Backend (NestJS +
PostgreSQL) is planned but **not built yet** — frontend uses demo data.

## Scope right now
Frontend only. Mature the UI with demo data. Do not add backend calls yet.
Implementation order follows PRD §13 (Tahap 1 first).

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
- Emulator AVD `expo_review` (has Pixel 6 device frame skin).
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

### BELUM TERVERIFIKASI — cek ini lebih dulu
Font **Onest baru saja dibundel** ke `assets/fonts/` + `pubspec.yaml`
(sebelumnya `google_fonts` mengunduh saat runtime, dan di HP tanpa internet app
jatuh ke Roboto). Berkas dan deklarasinya sudah ada, **tapi belum pernah
dijalankan sampai selesai di perangkat** — HP lepas dari USB sebelum build
kelar. Tugas pertama: build ke perangkat, lalu pastikan log **tidak** memuat
`google_fonts was unable to load font`. Kalau masih muncul, berarti bundling
belum terbaca dan harus diperbaiki sebelum menilai tipografi apa pun.

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
