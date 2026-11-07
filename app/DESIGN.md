# FreightIntel AI — Design System (Mobile / Flutter)

Bahasa visual: **modern clean fintech** — surface terang, kartu rounded, shadow lembut ber-tint, angka besar sebagai pahlawan, **satu** aksen hijau, chart batang rounded, bottom-nav pill + FAB tengah.

Fondasi: **Material 3** (`useMaterial3: true`) + prinsip anti-slop. Patuhi *consistency locks* di bawah — jangan menyimpang per-layar.

---

## 0. Aturan wajib (consistency locks)
- **Satu aksen:** hijau `#17A55B`. Tidak ada warna aksen lain muncul tiba-tiba.
- **Satu skala radius:** kartu `20`, tile `18`, input `14`, chip/FAB/nav `pill (999)`. Tidak campur acak.
- **Shadow ber-tint, bukan hitam:** pakai navy transparan, lembut. Tidak ada `Colors.black` drop shadow.
- **Angka = tabular** (`FontFeature.tabularFigures`) dan tebal. Uang & KPI adalah elemen utama.
- **Tiap layar data wajib 4 state:** loading (skeleton), berisi, kosong (empty), error+retry.
- **Tanpa AI-tell:** tanpa gradien ungu, tanpa emoji di UI, tanpa nama/angka palsu "sempurna", ikon dari satu family saja.

---

## 1. Warna (tokens)

```
# Surface / netral
bg            #F4F6F8   // latar aplikasi (cool-neutral terang)
surface       #FFFFFF   // kartu
surfaceAlt    #F8FAFC   // kartu sekunder / input fill
line          #EDF1F5   // garis halus (jarang dipakai; andalkan shadow)

# Teks
ink           #16365C   // judul & angka (brand navy, near-black)
inkSoft       #3A4B66   // teks sekunder gelap
muted         #64748B   // label, caption

# Aksen (SATU)
green         #17A55B   // aksen utama / positif / profit
greenSoft     #E7F6EE   // fill highlight card / badge success
greenInk      #0E7A42   // teks hijau di atas greenSoft

# Semantik finansial
loss          #E0523D   // rugi / negatif
lossSoft      #FCEAE6
warning       #E0A33E
warningSoft   #FCF3E2
```

**Highlight card** (seperti kartu "Weekly Progress" di referensi): fill `greenSoft`, teks `ink`, angka/aksen `green`. Satu per layar, untuk metrik terpenting.

Dark mode: siapkan nanti (bg `#0E1726`, surface `#16233A`, ink `#E6EDF6`, green tetap). Bukan prioritas MVP, tapi semua warna sudah token agar mudah.

---

## 2. Tipografi

Font: **Plus Jakarta Sans** (Google Fonts, OFL) — modern, ramah, cocok fintech. Satu family, variasi berat. Angka pakai **tabular figures**.

| Peran | Size | Weight | Warna | Catatan |
|---|---|---|---|---|
| Display angka (hero) | 30–34 | 800 | ink | tabular; untuk angka besar (Rp, kcal-style) |
| Judul layar | 22 | 700 | ink | |
| Judul kartu | 16 | 700 | ink | |
| Angka stat (tile) | 20 | 800 | ink/green/loss | tabular |
| Body | 14 | 500 | inkSoft | |
| Label caps | 11 | 700 | muted | letterSpacing 0.8, UPPERCASE |
| Caption | 12 | 500 | muted | |

Flutter: `google_fonts: ^6.x` → `GoogleFonts.plusJakartaSansTextTheme()`. Angka: `TextStyle(fontFeatures: [FontFeature.tabularFigures()])`.

---

## 3. Spasi, radius, elevation

- **Skala spasi:** 4 · 8 · 12 · 16 · 20 · 24 · 32.
- **Padding layar:** 20 (horizontal). **Padding kartu:** 18–20. **Jarak antar kartu:** 14.
- **Radius:** card 20 · tile 18 · input 14 · chip/pill 999 · FAB circle.
- **Shadow kartu (lembut, ber-tint):**
  ```dart
  BoxShadow(color: Color(0x1416365C), blurRadius: 24, offset: Offset(0, 10), spreadRadius: -6)
  ```
  (navy ~8% opacity, blur besar, offset turun). Hover/press: naikkan sedikit.

---

## 4. Komponen

### Kartu dasar
`surface` + radius 20 + shadow lembut. **Tanpa border** (andalkan shadow). Border halus `line` hanya bila di atas `bg` perlu pemisah ekstra.

### Highlight card (hero metrik)
Fill `greenSoft`, judul kecil + angka besar `ink`, ring/indikator progress `green`. Satu per layar.

### Stat tile
Label caps (muted) → angka besar tabular (ink/green/loss). Grid 2 kolom, gap 12. Ikon kecil dalam lingkaran `greenSoft`/`surfaceAlt` opsional di pojok.

### Tombol
- Primary: fill `green`, teks putih, radius pill, padding vertikal 16, berat 700. Press: `scale 0.98`.
- Secondary/ghost: `surface` + teks `ink`, radius pill.
- Kontras teks wajib lolos WCAG AA. Tidak ada putih-di-atas-putih.

### Segmented / period chips (Harian/Bulanan/Tahunan)
Track `surfaceAlt` pill; item aktif = fill `ink` teks putih **atau** `greenSoft` teks `greenInk` (pilih satu, konsisten).

### List row (shipment / invoice)
Kartu per item (radius 16, shadow lembih tipis). Baris: judul `ink` bold + sub `muted`; kanan: angka + badge status (pill `greenSoft`/`lossSoft`). Profit negatif → `loss`.

### Chart (ciri khas)
Bar chart, **batang rounded** (radius atas 6). Batang aktif `green` solid; lainnya `greenSoft` (ghost). Gridline sangat halus. Label `muted`. Pakai paket **`fl_chart`**. Line chart (BPM-style) untuk tren tipis.

### Bottom navigation (pill + FAB)
Bar mengambang (radius 24, shadow) berisi 4 item; **FAB tengah** lingkaran `green` (aksi cepat: Tambah shipment/transaksi). Item aktif: ikon + label dengan pill `greenSoft`. 4 tab: Dashboard · Shipments · Finance · Insight.

### States
- **Loading:** skeleton shimmer bentuk kartu final (paket `shimmer` atau `flutter_animate`). Bukan spinner bulat polos.
- **Empty:** ikon dalam lingkaran `greenSoft` + pesan + 1 aksi.
- **Error:** pesan inline jelas + tombol "Coba lagi".

---

## 5. Ikon & motion
- **Ikon:** satu family. Pakai **`phosphor_flutter`** (regular/bold) untuk kesan modern-ramah — konsisten strokeWidth. Jangan campur dengan Material Icons di komponen yang sama.
- **Motion (secukupnya, bermotivasi):** transisi tap `scale 0.98`; masuk list stagger halus (`flutter_animate`); angka boleh count-up saat load. Hormati `MediaQuery.disableAnimations` / reduce-motion. Tanpa animasi loop tanpa makna.

---

## 6. Paket Flutter (tambah ke pubspec)
```yaml
google_fonts: ^6.2.1      # Plus Jakarta Sans
fl_chart: ^0.69.0         # chart batang/line rounded
phosphor_flutter: ^2.1.0  # ikon modern
flutter_animate: ^4.5.0   # motion + shimmer ringan
```
(versi contoh — sesuaikan saat `flutter pub add`.)

---

## 7. Penerapan
1. `AppColors` + `AppTypography` di `lib/core/theme/` jadi sumber tunggal token.
2. `buildAppTheme()` set `colorScheme` (seed green/navy), `textTheme` Plus Jakarta Sans, radius & shadow default.
3. Komponen bersama di `lib/core/widgets/`: `AppCard`, `StatTile`, `HighlightCard`, `SectionChips`, `AppButton`, `BarChartCard`, `AppBottomNav`, `AppSkeleton`, `EmptyState`, `ErrorState`.
4. Semua layar pakai komponen itu — tidak ada styling ad-hoc per layar (biar konsisten & tidak slop).

> Acuan ini mengikat. Kalau suatu kebutuhan tidak tercakup, tambahkan token/komponen di sini dulu, baru dipakai — jangan styling liar.
