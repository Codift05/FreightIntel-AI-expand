/// Data layer Vendor Analytics (demo). Ganti dengan call API saat backend siap.
class Vendor {
  final String name, kind, city;
  final int shipments, costJt;
  final double tepatWaktuPct, indeksTarif; // 1.0 = rata-rata pasar
  final List<double> trend;
  final List<({String kategori, int jt})> rincian;

  const Vendor({
    required this.name,
    required this.kind,
    required this.city,
    required this.shipments,
    required this.costJt,
    required this.tepatWaktuPct,
    required this.indeksTarif,
    required this.trend,
    required this.rincian,
  });

  String get initials {
    final parts = name.split(' ').where((w) => w.length > 2).toList();
    if (parts.isEmpty) return name.substring(0, 1);
    return parts.take(2).map((w) => w[0]).join().toUpperCase();
  }

  /// Selisih tarif terhadap rata-rata pasar, dalam persen (+ = lebih mahal).
  double get selisihTarifPct => (indeksTarif - 1) * 100;

  /// Potensi hemat bila tarif diturunkan ke rata-rata pasar (FR-VAN-03).
  int get potensiHematJt =>
      indeksTarif <= 1 ? 0 : (costJt - costJt / indeksTarif).round();

  String get performa => tepatWaktuPct >= 92
      ? 'Baik'
      : tepatWaktuPct >= 80
          ? 'Cukup'
          : 'Perlu perhatian';
}

class VendorRepository {
  VendorRepository._();
  static final instance = VendorRepository._();

  Future<List<Vendor>> fetch() async {
    await Future.delayed(const Duration(milliseconds: 550));
    return _data;
  }

  static const _data = <Vendor>[
    Vendor(
      name: 'CV Mitra Laut',
      kind: 'Trucking',
      city: 'Jakarta',
      shipments: 41,
      costJt: 268,
      tepatWaktuPct: 78,
      indeksTarif: 1.12,
      trend: [0.42, 0.5, 0.55, 0.68, 0.74, 0.9],
      rincian: [
        (kategori: 'Trucking pelabuhan', jt: 168),
        (kategori: 'Lift on / lift off', jt: 62),
        (kategori: 'Menginap & tunggu', jt: 38),
      ],
    ),
    Vendor(
      name: 'PT Samudra Line',
      kind: 'Pelayaran',
      city: 'Surabaya',
      shipments: 36,
      costJt: 412,
      tepatWaktuPct: 95,
      indeksTarif: 0.98,
      trend: [0.6, 0.62, 0.58, 0.64, 0.6, 0.66],
      rincian: [
        (kategori: 'Ocean freight', jt: 344),
        (kategori: 'Terminal handling', jt: 68),
      ],
    ),
    Vendor(
      name: 'PT Bea Cepat',
      kind: 'Customs broker',
      city: 'Jakarta',
      shipments: 52,
      costJt: 96,
      tepatWaktuPct: 91,
      indeksTarif: 1.04,
      trend: [0.3, 0.34, 0.32, 0.38, 0.36, 0.4],
      rincian: [
        (kategori: 'Jasa kepabeanan', jt: 72),
        (kategori: 'Dokumen & legalisasi', jt: 24),
      ],
    ),
    Vendor(
      name: 'UD Gudang Sentosa',
      kind: 'Pergudangan',
      city: 'Semarang',
      shipments: 18,
      costJt: 74,
      tepatWaktuPct: 86,
      indeksTarif: 1.07,
      trend: [0.22, 0.26, 0.3, 0.28, 0.34, 0.36],
      rincian: [
        (kategori: 'Sewa gudang', jt: 54),
        (kategori: 'Bongkar muat', jt: 20),
      ],
    ),
    Vendor(
      name: 'PT Angkasa Kargo',
      kind: 'Air freight',
      city: 'Tangerang',
      shipments: 14,
      costJt: 186,
      tepatWaktuPct: 73,
      indeksTarif: 1.15,
      trend: [0.4, 0.46, 0.52, 0.5, 0.6, 0.64],
      rincian: [
        (kategori: 'Air freight', jt: 152),
        (kategori: 'Surcharge bahan bakar', jt: 34),
      ],
    ),
  ];
}
