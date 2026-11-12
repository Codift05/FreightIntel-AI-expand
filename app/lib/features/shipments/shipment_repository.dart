import '../../core/network/api_client.dart';

/// Data layer Shipments.
///
/// Mengambil data live dari backend NestJS (`GET /api/v1/shipments`) dan
/// menyimpan perubahan via `POST`/`PATCH`, dengan fallback otomatis ke data
/// offline bila peranti sedang tidak terhubung ke server.
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

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
        (j['id'] ?? '') as String,
        (j['client'] ?? 'PT Garuda Trading') as String,
        (j['route'] ?? '') as String,
        (j['type'] ?? 'Ocean Freight') as String,
        (j['revenue'] ?? 'Rp 0 jt') as String,
        (j['profit'] ?? 'Rp 0 jt') as String,
        (j['profitUp'] as bool?) ?? true,
        (j['status'] ?? 'Booking') as String,
        arsip: (j['arsip'] as bool?) ?? false,
        container: (j['container'] ?? '1 x 40ft HC') as String,
        etd: (j['etd'] ?? '12 Okt 2026') as String,
        eta: (j['eta'] ?? '28 Okt 2026') as String,
      );

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

  void clearCache() => _cache.clear();

  /// Simpan shipment baru ke backend (`POST /shipments`) + masukkan ke awal cache.
  Future<Shipment> create(Shipment draft) async {
    final parts = draft.route.split('→');
    final origin = parts.first.trim();
    final dest = parts.length > 1 ? parts[1].trim() : '';
    final res = await ApiClient.instance.post('/shipments', body: {
      'customerName': draft.client,
      'type': draft.type,
      'origin': origin,
      'destination': dest,
      'container': draft.container,
      'etd': draft.etd,
      'eta': draft.eta,
    });
    final created =
        res is Map<String, dynamic> ? Shipment.fromJson(res) : draft;
    _cache.insert(0, created);
    return created;
  }

  /// Ganti satu shipment di cache dan sinkronkan ke backend (`PATCH /shipments/:id`).
  void update(Shipment s) {
    final i = _cache.indexWhere((e) => e.id == s.id);
    if (i >= 0) _cache[i] = s;
    ApiClient.instance.patch('/shipments/${s.id}', body: {
      'client': s.client,
      'route': s.route,
      'type': s.type,
      'status': s.status,
      'arsip': s.arsip,
      'container': s.container,
      'etd': s.etd,
      'eta': s.eta,
    });
  }

  /// Ambil satu halaman dari backend NestJS, atau fallback ke data offline.
  Future<List<Shipment>> fetchPage(int page) async {
    final res = await ApiClient.instance.get('/shipments', query: {
      'page': '$page',
      'pageSize': '$pageSize',
    });
    if (res is List) {
      final slice = res
          .whereType<Map<String, dynamic>>()
          .map(Shipment.fromJson)
          .toList();
      if (page == 0) _cache.clear();
      for (final s in slice) {
        if (!_cache.any((e) => e.id == s.id)) _cache.add(s);
      }
      return slice;
    }

    await Future.delayed(const Duration(milliseconds: 350));
    final start = page * pageSize;
    if (start >= _all.length) return const [];
    final end = (start + pageSize).clamp(0, _all.length);
    final slice = _all.sublist(start, end);
    for (final s in slice) {
      if (!_cache.any((e) => e.id == s.id)) _cache.add(s);
    }
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
  static const _clients = [
    'PT Garuda Trading',
    'PT Astra Export',
    'CV Mitra Laut'
  ];

  static const _modes = [
    'Ocean Freight',
    'Air Freight',
    'Trucking',
    'Handling'
  ];

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
