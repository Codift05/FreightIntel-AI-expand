/// Data layer Finance (demo). Ganti [_data] dengan call API saat backend siap.
enum FinanceEntryType { revenue, cost }

class Invoice {
  final String no, note, amount, status;
  final bool paid;
  final FinanceEntryType? type;
  final String? counterparty, shipmentNo, category;
  final DateTime? invoiceDate;
  final int? dppRupiah, ppnRupiah;

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
  });
}

class FinanceRepository {
  FinanceRepository._();
  static final instance = FinanceRepository._();

  List<Invoice>? _cache;
  bool get hasCache => _cache != null;
  List<Invoice> get cached => _cache ?? const [];

  void add(Invoice entry) {
    final existing = _cache ?? _data;
    _cache = [entry, ...existing];
  }

  Future<List<Invoice>> fetch() async {
    if (_cache != null) return _cache!;
    await Future.delayed(const Duration(milliseconds: 700)); // simulasi API
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
