import '../../core/network/api_client.dart';

/// Data layer Finance: mengambil daftar invoice dari backend NestJS
/// (`GET /api/v1/finance/invoices`), mencatat transaksi baru (`POST /invoices`),
/// dan mencatat cicilan/pelunasan (`POST /payments`) dengan fallback offline.
enum FinanceEntryType { revenue, cost }

class Invoice {
  final String no, note, amount, status;
  final bool paid;
  final FinanceEntryType? type;
  final String? counterparty, shipmentNo, category;
  final DateTime? invoiceDate;
  final int? dppRupiah, ppnRupiah, paidRupiah;
  final String currency;
  final int exchangeRate;

  const Invoice(
    this.no,
    this.note,
    this.amount,
    this.status,
    this.paid, {
    this.type,
    this.counterparty,
    this.shipmentNo,
    this.category,
    this.invoiceDate,
    this.dppRupiah,
    this.ppnRupiah,
    this.paidRupiah,
    this.currency = 'IDR',
    this.exchangeRate = 1,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        (j['no'] ?? '') as String,
        (j['note'] ?? '') as String,
        (j['amount'] ?? '+Rp 0 jt') as String,
        (j['status'] ?? 'UNPAID') as String,
        (j['paid'] as bool?) ?? false,
        type: j['type'] == 'cost'
            ? FinanceEntryType.cost
            : FinanceEntryType.revenue,
        counterparty: j['counterparty'] as String?,
        shipmentNo: j['shipmentNo'] as String?,
        category: j['category'] as String?,
        invoiceDate: j['invoiceDate'] is String
            ? DateTime.tryParse(j['invoiceDate'] as String)
            : null,
        dppRupiah: (j['dppRupiah'] as num?)?.toInt(),
        ppnRupiah: (j['ppnRupiah'] as num?)?.toInt(),
        paidRupiah: (j['paidRupiah'] as num?)?.toInt(),
        currency: (j['currency'] ?? 'IDR') as String,
        exchangeRate: (j['exchangeRate'] as num?)?.toInt() ?? 1,
      );

  /// Nilai tagihan dalam juta (dari DPP, atau parse dari string amount).
  int get totalJt =>
      dppRupiah ?? int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  bool get partial => status == 'PARTIAL';

  Invoice copyWith({String? status, bool? paid, int? paidRupiah}) => Invoice(
        no,
        note,
        amount,
        status ?? this.status,
        paid ?? this.paid,
        type: type,
        counterparty: counterparty,
        shipmentNo: shipmentNo,
        category: category,
        invoiceDate: invoiceDate,
        dppRupiah: dppRupiah,
        ppnRupiah: ppnRupiah,
        paidRupiah: paidRupiah ?? this.paidRupiah,
        currency: currency,
        exchangeRate: exchangeRate,
      );
}

class FinanceRepository {
  FinanceRepository._();
  static final instance = FinanceRepository._();

  List<Invoice>? _cache;
  bool get hasCache => _cache != null;
  List<Invoice> get cached => _cache ?? const [];

  void clearCache() => _cache = null;

  void add(Invoice entry) {
    final existing = _cache ?? _data;
    _cache = [entry, ...existing];
    ApiClient.instance.post('/finance/invoices', body: {
      'type': entry.type == FinanceEntryType.cost ? 'cost' : 'revenue',
      'invoiceNo': entry.no,
      'counterparty': entry.counterparty ?? 'PT Garuda Trading',
      'shipmentNo': entry.shipmentNo,
      'category': entry.category ?? 'Ocean Freight',
      'invoiceDate': entry.invoiceDate?.toIso8601String(),
      'currency': entry.currency,
      'exchangeRate': entry.exchangeRate,
      'dppJt': entry.totalJt,
      'ppnJt': entry.ppnRupiah ?? 0,
      'paid': entry.paid,
    });
  }

  /// Catat pembayaran (cicilan) sebesar [addJt] juta untuk invoice [no].
  /// Status jadi PAID bila lunas, PARTIAL bila sebagian (BR-06).
  void recordPayment(String no, int addJt) {
    final list = (_cache ?? _data).toList();
    final i = list.indexWhere((e) => e.no == no);
    if (i < 0) return;
    final inv = list[i];
    final paidNow = (inv.paidRupiah ?? 0) + addJt;
    final full = paidNow >= inv.totalJt;
    list[i] = inv.copyWith(
      status: full ? 'PAID' : 'PARTIAL',
      paid: full,
      paidRupiah: full ? inv.totalJt : paidNow,
    );
    _cache = list;
    ApiClient.instance.post('/finance/payments', body: {
      'invoiceNo': no,
      'addJt': addJt,
    });
  }

  Future<List<Invoice>> fetch() async {
    if (_cache != null) return _cache!;
    final res = await ApiClient.instance.get('/finance/invoices');
    if (res is List) {
      final list = res
          .whereType<Map<String, dynamic>>()
          .map(Invoice.fromJson)
          .toList();
      if (list.isNotEmpty) {
        return _cache = list;
      }
    }
    await Future.delayed(const Duration(milliseconds: 350));
    return _cache = _data;
  }

  static const _data = [
    Invoice('INV/2610/003', 'Handling · 2026-10-20', '+Rp 142 jt', 'PAID', true),
    Invoice('INV/2610/017', 'Ocean Freight · 2026-10-13', '+Rp 298 jt', 'PAID', true),
    Invoice('INV/2610/009', 'Handling · 2026-10-04', '+Rp 76 jt', 'UNPAID', false),
    Invoice('INV/2609/013', 'Air Freight · 2026-09-10', '+Rp 263 jt', 'PAID', true),
    Invoice('INV/2609/008', 'Trucking · 2026-09-02', '+Rp 54 jt', 'UNPAID', false),
  ];
}
