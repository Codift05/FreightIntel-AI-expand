# FreightIntel AI

Aplikasi **mobile (Flutter)** manajemen keuangan & operasional untuk perusahaan **freight forwarding** Indonesia — pencatatan shipment, biaya, **profit otomatis**, pelaporan, dan intelijen bisnis berbasis analitik.

> Dokumen lengkap (PRD, RAB, brand kit, infra) bersifat **internal** dan disimpan terpisah — tidak termasuk dalam repository ini.

## Teknologi
| Lapisan | Teknologi |
|---|---|
| Mobile | **Flutter (Dart)** — Android & iOS |
| Backend | Node.js + **NestJS** + **Prisma** *(menyusul)* |
| Database | **PostgreSQL** |
| Hosting | VPS self-host (**Docker Compose**) |

Isolasi antar-perusahaan lewat filter `company_id`. Intelijen/AI dibangun dari analitik & statistik atas data sendiri (tanpa API LLM berbayar).

## Struktur
```
app/                      # Aplikasi Flutter
  lib/
    core/theme/           # tema & palet brand (navy #16365C, green #17A55B)
    core/widgets/         # komponen bersama (logo, dll)
    features/
      auth/               # login
      home/               # shell + bottom navigation
      dashboard/          # ringkasan keuangan
      shipments/          # daftar shipment
      finance/            # invoice & tiles
      insight/            # analitik (menyusul)
```

## Menjalankan (frontend)
```bash
cd app
flutter pub get
flutter run                 # di emulator / HP
# atau preview di browser:
flutter build web && (cd build/web && python3 -m http.server 8099)
```

## Status
**Tahap 1 — Frontend scaffold.** Login, dashboard, shipments, finance, insight (masih memakai data contoh, belum terhubung backend).

### Roadmap tahap
1. Fondasi & nilai inti — Auth, Shipment, Revenue, Cost, Profit, Dashboard
2. Keuangan & operasional — pembayaran/cicilan, multi-mata uang, laporan, notifikasi
3. Enterprise — multi-perusahaan, RBAC, custom field, analytics
4. Intelijen — analitik bisnis, forecasting, OCR invoice

---
© FreightIntel AI
