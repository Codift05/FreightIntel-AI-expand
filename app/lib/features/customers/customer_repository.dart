import '../../core/network/api_client.dart';

/// Data layer Customer Analytics: mengambil data customer dan profitabilitas
/// dari backend NestJS (`GET /api/v1/customers`) dengan fallback offline.
class Customer {
  final String name, city, sejak;
  final int shipments, revenueJt, profitJt;
  final double marginPct, tepatWaktuPct;
  final List<double> trend; // 6 bulan terakhir, relatif
  final List<({String id, String route, int profitJt})> recent;

  const Customer({
    required this.name,
    required this.city,
    required this.sejak,
    required this.shipments,
    required this.revenueJt,
    required this.profitJt,
    required this.marginPct,
    required this.tepatWaktuPct,
    required this.trend,
    required this.recent,
  });

  factory Customer.fromJson(Map<String, dynamic> j, int idx) {
    final fallback = CustomerRepository._data[idx % CustomerRepository._data.length];
    final avgDays = (j['rataHariBayar'] as num?)?.toInt() ?? 20;
    final tepatPct = (110 - avgDays).clamp(60, 96).toDouble();
    return Customer(
      name: (j['name'] ?? fallback.name) as String,
      city: (j['city'] ?? fallback.city) as String,
      sejak: 'Sejak ${(j['since'] ?? '2022')}',
      shipments: (j['shipments'] as num?)?.toInt() ?? fallback.shipments,
      revenueJt: (j['revenueJt'] as num?)?.toInt() ?? fallback.revenueJt,
      profitJt: (j['profitJt'] as num?)?.toInt() ?? fallback.profitJt,
      marginPct: (j['marginPct'] as num?)?.toDouble() ?? fallback.marginPct,
      tepatWaktuPct: tepatPct,
      trend: fallback.trend,
      recent: fallback.recent,
    );
  }

  /// Inisial untuk avatar huruf (tanpa foto palsu).
  String get initials {
    final parts = name.split(' ').where((w) => w.length > 2).toList();
    if (parts.isEmpty) return name.substring(0, 1);
    return parts.take(2).map((w) => w[0]).join().toUpperCase();
  }

  /// Risiko bayar sederhana dari ketepatan waktu (FR-CAN-03).
  String get risiko => tepatWaktuPct >= 90
      ? 'Rendah'
      : tepatWaktuPct >= 75
          ? 'Sedang'
          : 'Tinggi';
}

class CustomerRepository {
  CustomerRepository._();
  static final instance = CustomerRepository._();

  Future<List<Customer>> fetch() async {
    final res = await ApiClient.instance.get('/customers');
    if (res is List) {
      final list = <Customer>[];
      var i = 0;
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          list.add(Customer.fromJson(item, i++));
        }
      }
      if (list.isNotEmpty) return list;
    }
    await Future.delayed(const Duration(milliseconds: 350));
    return _data;
  }

  static const _data = <Customer>[
    Customer(
      name: 'PT Sinar Abadi',
      city: 'Jakarta',
      sejak: 'Maret 2023',
      shipments: 34,
      revenueJt: 1240,
      profitJt: 286,
      marginPct: 23.1,
      tepatWaktuPct: 72,
      trend: [0.4, 0.55, 0.5, 0.72, 0.68, 0.86],
      recent: [
        (id: 'FI-2610-021', route: 'Jakarta → Shanghai', profitJt: 31),
        (id: 'FI-2610-014', route: 'Jakarta → Tokyo', profitJt: 12),
        (id: 'FI-2609-038', route: 'Surabaya → Singapura', profitJt: 27),
      ],
    ),
    Customer(
      name: 'CV Harum Jaya',
      city: 'Surabaya',
      sejak: 'Januari 2024',
      shipments: 21,
      revenueJt: 780,
      profitJt: 194,
      marginPct: 24.9,
      tepatWaktuPct: 68,
      trend: [0.3, 0.42, 0.6, 0.55, 0.7, 0.74],
      recent: [
        (id: 'FI-2610-019', route: 'Surabaya → Port Klang', profitJt: 22),
        (id: 'FI-2609-031', route: 'Surabaya → Singapura', profitJt: 19),
      ],
    ),
    Customer(
      name: 'PT Mega Logistik',
      city: 'Semarang',
      sejak: 'Agustus 2022',
      shipments: 48,
      revenueJt: 1610,
      profitJt: 302,
      marginPct: 18.8,
      tepatWaktuPct: 94,
      trend: [0.62, 0.58, 0.66, 0.7, 0.76, 0.8],
      recent: [
        (id: 'FI-2610-027', route: 'Semarang → Busan', profitJt: 24),
        (id: 'FI-2610-008', route: 'Semarang → Ho Chi Minh', profitJt: 18),
      ],
    ),
    Customer(
      name: 'PT Bahari Timur',
      city: 'Makassar',
      sejak: 'Juni 2024',
      shipments: 12,
      revenueJt: 395,
      profitJt: 61,
      marginPct: 15.4,
      tepatWaktuPct: 88,
      trend: [0.2, 0.3, 0.28, 0.4, 0.38, 0.46],
      recent: [
        (id: 'FI-2610-030', route: 'Makassar → Jakarta', profitJt: 9),
      ],
    ),
    Customer(
      name: 'UD Cahaya Niaga',
      city: 'Medan',
      sejak: 'Februari 2025',
      shipments: 9,
      revenueJt: 212,
      profitJt: 24,
      marginPct: 11.3,
      tepatWaktuPct: 61,
      trend: [0.18, 0.22, 0.2, 0.26, 0.22, 0.3],
      recent: [
        (id: 'FI-2610-033', route: 'Belawan → Port Klang', profitJt: 4),
      ],
    ),
  ];
}
