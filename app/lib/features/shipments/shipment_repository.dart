/// Data layer Shipments.
///
/// Untuk demo dipakai data statis + delay (simulasi jaringan). Saat backend
/// siap, ganti isi [_fetch] dengan call API (NestJS) dan hapus [_all].
/// Cache halaman yang sudah dimuat ditahan di memori agar pindah tab tidak
/// memicu skeleton ulang.
class Shipment {
  final String id, client, route, type, revenue, profit, status;
  final bool profitUp;
  final bool arsip;
  final String container;
  final String etd;
  final String eta;

  const Shipment(
    this.id,
    this.client,
    this.route,
    this.type,
    this.revenue,
    this.profit,
    this.profitUp,
    this.status, {
    this.arsip = false,
    this.container = '1 x 40ft HC',
    this.etd = '12 Okt 2026',
    this.eta = '28 Okt 2026',
  });

  Shipment copyWith({
    String? client,
    String? route,
    String? type,
    String? status,
    bool? arsip,
    String? container,
    String? etd,
    String? eta,
  }) =>
      Shipment(
        id,
        client ?? this.client,
        route ?? this.route,
        type ?? this.type,
        revenue,
        profit,
        profitUp,
        status ?? this.status,
        arsip: arsip ?? this.arsip,
        container: container ?? this.container,
        etd: etd ?? this.etd,
        eta: eta ?? this.eta,
      );
}

/// Urutan siklus status shipment (PRD §9.2).
const kShipmentStatuses = [
  'Booking',
  'In Transit',
  'Arrived',
  'Customs',
  'Delivered',
  'Completed',
];

class ShipmentRepository {
  ShipmentRepository._();
  static final instance = ShipmentRepository._();

  static const pageSize = 6;

  final List<Shipment> _cache = [];
  bool get hasCache => _cache.isNotEmpty;
  List<Shipment> get cached => List.unmodifiable(_cache);

  /// Ganti satu shipment di cache (dipakai layar Ubah shipment).
  void update(Shipment s) {
    final i = _cache.indexWhere((e) => e.id == s.id);
    if (i >= 0) _cache[i] = s;
  }

  /// Ambil satu halaman. List kosong = sudah habis.
  Future<List<Shipment>> fetchPage(int page) async {
    await Future.delayed(const Duration(milliseconds: 700)); // simulasi API
    final start = page * pageSize;
    if (start >= _all.length) return const [];
    final end = (start + pageSize).clamp(0, _all.length);
    final slice = _all.sublist(start, end);
    _cache.addAll(slice);
    return slice;
  }

  static const _routes = [
    ['Jakarta', 'Rotterdam'],
    ['Singapore', 'Surabaya'],
    ['Jakarta', 'Tokyo'],
    ['Hamburg', 'Jakarta'],
    ['Shanghai', 'Belawan'],
    ['Surabaya', 'Busan'],
  ];
  static const _clients = ['PT Garuda Trading', 'PT Astra Export', 'CV Mitra Laut'];

  static const _modes = ['Ocean Freight', 'Air Freight', 'Trucking', 'Handling'];

  static final List<Shipment> _all = List.generate(20, (i) {
    final r = _routes[i % _routes.length];
    final up = i % 4 != 2;
    final rev = 80 + (i * 23) % 240;
    final prof = up ? 20 + (i * 11) % 120 : -(30 + (i * 7) % 40);
    return Shipment(
      'FI-2610-${(1000 + i * 137).toRadixString(16).toUpperCase().padLeft(4, '0')}',
      _clients[i % _clients.length],
      '${r[0]} → ${r[1]}',
      _modes[i % _modes.length],
      'Rp $rev jt',
      '${prof < 0 ? '-' : ''}Rp ${prof.abs()} jt',
      up,
      kShipmentStatuses[i % kShipmentStatuses.length],
    );
  });
}
