# FreightIntel AI — Design System (Mobile / Flutter)

> Sumber token tunggal: [`lib/core/theme/app_theme.dart`](lib/core/theme/app_theme.dart).
> Dokumen ini menjelaskan *kenapa*-nya. Kalau keduanya berbeda, **kode yang benar**
> — perbarui dokumen ini (AGENTS.md RULE 0).
> Acuan visual: `docs/Reference Design.png`. Status layar: [`../docs/FRONTEND.md`](../docs/FRONTEND.md).

Bahasa visual: **fintech tenang, near-monochrome**. Latar abu dingin, kartu putih
radius besar, shadow lembut ber-tint, angka tabular sebagai pahlawan, **satu aksen
interaktif lime**, dan hijau/merah dipakai *hanya* untuk arti data. Fondasi
**Material 3** (`useMaterial3: true`).

---

## 0. Aturan wajib (consistency locks)
- **Dua peran warna yang tidak boleh tertukar:** `lime #D3F85A` = aksen
  interaktif (tombol utama, chip aktif); `green #17A55B` / `loss #E0523D` =
  **arti data** (naik/turun, laba/rugi). Hijau tidak pernah jadi dekorasi
  tombol, lime tidak pernah berarti "positif".
- **Hirarki kartu:** maksimal **satu kartu gelap** (`inkDeep`) per layar =
  metrik/temuan terpenting. Sisanya kartu putih.
- **Satu skala radius:** card 24 · tile 20 · input 14 · chip/pill 999.
- **Shadow ber-tint, bukan hitam** (`AppShadows.card` / `.soft`). Tanpa border
  kecuali perlu pemisah tipis (`line`).
- **Angka = tabular + tebal** (`numStyle`). Uang & KPI adalah elemen utama.
- **Label = sentence case** (`labelStyle`, 13px w600). **Dilarang** eyebrow
  ALL-CAPS ber-letterSpacing (antislop R-06/R-09, permintaan tegas user).
- **Tiap layar data wajib 4 state:** loading (`Skeletonizer`, bentuk mengikuti
  kartu final) · berisi · kosong (`EmptyState` + 1 aksi) · error + "Coba lagi".
- **Copy UI Bahasa Indonesia.** Angka demo ditandai jujur ("Angka contoh,
  belum terhubung data").
- **Tanpa AI-tell:** tanpa gradien sebagai default, tanpa emoji di UI, tanpa
  kontrol mati tanpa penjelasan, ikon satu family.

---

## 1. Warna (token aktual)

```
# Surface / netral — abu dingin
bg            #EFF1F3   // latar aplikasi
surface       #FFFFFF   // kartu
surfaceAlt    #F6F7F9   // kartu sekunder / input fill
line          #E8EAED   // garis & divider halus

# Teks — near-black, bukan navy
ink           #141414   // judul & angka (18,4:1 di putih)
inkDeep       #141414   // fill kartu hero gelap
inkSoft       #5B6066   // teks sekunder (6,3:1)
muted         #6B7280   // label, caption (4,8:1)
onDark        #9CA3AF   // label di atas kartu gelap (7,3:1)

# Aksen interaktif (SATU) — teks di atasnya selalu ink
lime          #D3F85A

# Arti data
green         #17A55B   // positif / laba
greenSoft     #E7F6EE   // fill chip dampak / badge sukses
greenInk      #0E7A42   // teks hijau di atas greenSoft
greenBright   #3FD98A   // positif di atas kartu gelap
loss          #E0523D   // negatif / rugi
lossSoft      #FCEAE6
warning       #E0A33E
warningSoft   #FCF3E2
```

Alias lama `navy` → `ink` dan `border` → `line` masih ada supaya layar lama
kompilasi; hapus saat layar itu disentuh.

Dark mode: belum. Semua warna sudah token, jadi bisa ditambah tanpa bongkar layar.

---

## 2. Tipografi

Font: **Onest** (`google_fonts`, `GoogleFonts.onestTextTheme()`). Satu family,
variasi berat. Angka pakai `FontFeature.tabularFigures()`.

**Bobot angka = w700, bukan w800.** Di Onest, w800 pada nominal besar terbaca
padat dan berat — kesannya kurang modern. `numStyle` juga merapatkan tracking
seiring ukuran naik (-0,8 di >=26px, -0,4 di >=20px, -0,2 selebihnya); angka
besar dengan jarak huruf normal terlihat renggang. Pengecualian: pill dan
tombol kecil (11-14px) tetap w800 karena di ukuran itu bobot tebal menjaga
keterbacaan.

| Peran | Helper | Size | Weight | Warna |
|---|---|---|---|---|
| Nilai hero (kartu gelap) | manual | 32 | w800 | putih |
| Judul layar | `numStyle(size: 22)` | 22 | w800 | ink |
| Angka stat (StatTile) | `numStyle(size: 19)` | 19 | w800 | ink |
| Angka forecast / KPI detail | `numStyle(size: 20–25)` | 20–25 | w800 | ink |
| Judul section | `numStyle(size: 15)` | 15 | w800 | ink |
| Judul kartu / item | — | 14–15 | w700 | ink |
| Body | textTheme | 13–13,5 | w500 | inkSoft |
| Label / caption | `labelStyle()` | 12–13 | w600 | muted |

---

## 3. Spasi, radius, elevation

- **Skala spasi:** 4 · 8 · 10 · 12 · 14 · 18 · 20 · 24.
- **Padding layar:** 20 horizontal, 18 atas, **112 bawah** (ruang bottom nav
  mengambang). **Padding kartu:** 16–20. **Jarak antar kartu:** 12.
- **Jarak antar section:** 24 (judul → kartu = 10).
- **Radius:** `AppRadii.card 24` · `tile 20` · `input 14` · `pill 999`.
- **Shadow:** `AppShadows.card` (kartu) / `.soft` (chip, search bar, bar aksi).

---

## 4. Komponen (`lib/core/widgets/`)

### `AppCard`
`surface` + radius 24 + `AppShadows.card`, tanpa border. Opsional `onTap`
(terbungkus `Pressable`). Padding bisa di-override untuk kartu berisi daftar
baris ber-divider (`horizontal: 16, vertical: 4`).

### `HighlightCard` (hero)
Kartu gelap `inkDeep`: label abu kecil → nilai besar putih (tap = toggle
ringkas ↔ detail, `FittedBox` biar tak kepotong) + toggle mata (`Rp ••••••`) →
delta sebagai **pill** berwarna (`arrow_drop_up` + fill `delta.withValues(alpha: .16)`)
→ meta abu. Varian Dashboard punya pita atas lime dua-tingkat + motif lingkaran
konsentris. **Satu per layar.**

### `StatTile`
Label abu 12 w500 → angka `numStyle(19)` + unit → panah + delta
(`green`/`loss`) + keterangan ("vs lalu"). Padding 14/13, jarak internal 6.
**Tanpa ikon, tanpa sparkline** — versi lama bikin RenderFlex overflow di HP.

**Aturan hierarki angka:** hero kartu gelap 30px, KPI sekunder 19px. Rasio
dijaga di sekitar **1,6x**; kalau KPI sekunder naik ke 24+ ia masuk tier judul
halaman dan layar langsung terasa "besar-besar dan dominan". Kontras dibuat
dengan mengecilkan yang sekunder, bukan membesarkan yang utama.

### `ScreenHeader` (layar sekunder)
Semua layar yang dibuka lewat `push` pakai header yang sama: tombol kembali
44×44 (`arrow_left`), judul `numStyle(18)`, subjudul `muted` 12, dan satu slot
aksi opsional (`HeaderAction`: lingkaran 40 `surface` + ikon `ink`). Padding
`fromLTRB(12, 6, 16, 10)`. Di bawahnya `Expanded(ListView)` dengan padding
`fromLTRB(20, 8, 20, 24)` — layar push tidak perlu ruang bottom nav.
`DemoNote` menutup layar: catatan `muted` 12 yang menyebut angkanya contoh.

### Matriks izin
Baris modul × kolom aksi dalam satu kartu. Kotak 26×26 radius 9: aktif `ink` +
centang putih, nonaktif `surfaceAlt`. Ketuk = toggle + haptic. Peran yang
dikunci menjelaskan alasannya lewat SnackBar, bukan kotak mati tanpa pesan.

### Batang perbandingan
`LinearProgressIndicator` tinggi 8, radius pill, track `line`, isi `ink` —
atau `loss` bila nilainya di atas ambang (mis. tarif vendor di atas pasar).
Dipakai di Laporan (biaya per kategori) dan Vendor (perbandingan biaya).

### `Pressable`
Semua elemen interaktif: `scale 0.97` (90ms turun / 140ms naik) +
`Semantics(button: true, label:)`. Tab bar + aksi penting pakai
`HapticFeedback.selectionClick()`.

### Tombol
- Primary: fill `lime`, **ikon & teks `ink`** (bukan putih — tak terlihat),
  radius pill, padding vertikal 13–16, w700.
- Secondary: fill `ink`/`surface` + teks kontras, radius pill.
- Kontras teks wajib lolos WCAG AA.

### Segmented / period chips
**Tanpa track.** Pill aktif `ink` + teks putih, item lain `muted`. Di Dashboard
pill-nya **geser mengikuti offset swipe** `PageController` (AnimatedBuilder,
warna teks ter-interpolasi).

### Filter chip / search bar
Chip: aktif `ink` + putih; idle `surface` + `muted` + `AppShadows.soft`.
Search: `TextField` kapsul `surface`, prefix `search_normal_1` warna `ink`.

### List row (shipment / invoice)
Satu `AppCard` per item: thumbnail moda 52 bulat (`greenSoft` + `Illus.mode`),
id `numStyle(15)` + customer `muted`, `StatusChip` di kanan, divider, lalu 3
kolom `Moda / Pendapatan / Laba` (laba `green`/`loss`).

### Kartu daftar ber-divider (Penyebab, Rekomendasi)
Satu kartu putih berisi n baris dipisah `Divider(height: 1, color: line)` —
**bukan** n kartu ikon+judul+teks seragam (itu template, craft-floor impeccable).

### Bubble chat (Tanya AI)
Milik user: fill `ink`, teks putih, rata kanan. Jawaban: kartu `surface` +
`AppShadows.soft`, rata kiri. Radius 20, **kecuali sudut bawah di sisi pemilik =
6** (ekor). Lebar maksimal 78% layar. Masuk dengan `fadeIn 220ms` +
`slideY 0.12`. Indikator mengetik = 3 titik `muted` 6px, `repeat(reverse: true)`
beda delay 140ms.

### `ModeIcon`
Moda pengiriman dipakai sebagai **glyph vektor**, bukan ilustrasi raster:
`ship` / `airplane` / `box` / `truck_fast` dari `IconsaxPlusBold`, warna `ink`,
di dalam kotak `surfaceAlt` radius 0,32x ukuran. Ukuran 46 di daftar Shipments,
34 di sorotan Dashboard. Latarnya **netral, bukan `greenSoft`** — hijau
dicadangkan untuk arti data, bukan dekorasi ikon.

### Chart
Kurva interaktif (`_InteractiveTrendCard` di Dashboard): crosshair putus-putus +
tooltip gelap. `Sparkline` untuk tren mini di baris invoice. `fl_chart` terpasang
tapi chart utama digambar sendiri (`CustomPainter`) supaya ikut token.

### Bottom navigation
Kapsul mengambang, **4 tab**: Dashboard · Shipments · Finance · Insight.
Aktif = `IconsaxPlusBold` + `ink` + underline 16×3 animasi; idle =
`IconsaxPlusLinear` + `muted`. **Tanpa FAB tengah** (dihapus; aksi tambah ada di
header layarnya). Struktur nav sudah disetujui user — **jangan diubah**, hanya warna.

### States
- **Loading:** `Skeletonizer` membungkus layout final (pakai record/objek
  `_ghost`), bukan spinner polos.
- **Empty:** `EmptyState` (ilustrasi + judul + pesan) + 1 tombol aksi.
- **Error:** pesan inline + "Coba lagi".

---

## 5. Ikon, ilustrasi & motion
- **Ikon:** `iconsax_plus` — `IconsaxPlusBold` (aktif/terisi),
  `IconsaxPlusLinear` (idle/outline). Jangan campur Material Icons dalam satu
  komponen (pengecualian sadar: `Icons.arrow_drop_up` untuk delta).
  Hindari glyph "AI" generik (magic_star) — Insight pakai `lamp_charge`.
- **Ilustrasi:** flat-vector playful (acuan Travelo), `assets/illustrations/`
  via helper `Illus` / `Illus.mode(type)`. **Objek tanpa wajah**; hanya orang
  (avatar) yang punya wajah. Sumber mentah di `/Asset Generate` — jangan dihapus.
  **Avatar dipasang tanpa border.** Cincin putih di atas bg abu `#EFF1F3`
  terbaca sebagai halo yang janggal; latar aset sudah `greenSoft` sehingga
  menyatu dengan fill lingkaran. Aset avatar juga dikrop sebatas kepala —
  detail pucat seperti kerah baju jadi blob putih di ukuran 40-46px.
- **Motion:** `flutter_animate`. **Satu momen yang diberi niat per layar**
  (mis. kartu temuan Insight: `fadeIn 420ms` + `slideY 0.08`). Sisanya mikro:
  press `scale`, chip `AnimatedContainer` 160ms, semua pakai `kEaseOut`
  `Cubic(0.22, 1, 0.36, 1)`. Transisi antar layar: `CupertinoPageTransitionsBuilder`
  untuk semua platform (slide + swipe-back). Tanpa animasi loop tanpa makna.

---

## 6. Paket terpasang (`pubspec.yaml`)
```yaml
google_fonts: ^8.2.1      # Onest
iconsax_plus: ^1.0.0      # ikon Bold/Linear
flutter_animate: ^4.5.2   # motion
skeletonizer: ^3.0.0      # loading skeleton
fl_chart: ^1.3.0          # tersedia; chart utama custom painter
phosphor_flutter: ^2.1.0  # sisa eksperimen awal — kandidat dihapus
```

---

## 7. Penerapan
1. `AppColors` / `AppRadii` / `AppShadows` / `numStyle` / `labelStyle` /
   `kEaseOut` di `lib/core/theme/app_theme.dart` = **satu-satunya** sumber token.
   Jangan hard-code hex di layar.
2. `buildAppTheme()` set `colorScheme` (primary = `ink`, secondary = `green`),
   `textTheme` Onest, `scaffoldBackgroundColor` = `bg`, `pageTransitionsTheme`.
3. Pakai komponen bersama di `lib/core/widgets/`; kalau butuh yang baru,
   tambahkan di sana + catat di dokumen ini dulu, baru dipakai.

> Acuan ini mengikat. Kebutuhan yang belum tercakup: tambah token/komponen di
> sini dulu, baru pakai — jangan styling liar per layar.
