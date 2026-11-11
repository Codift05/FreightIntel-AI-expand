import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'finance_repository.dart';
import '../shipments/shipment_repository.dart';

/// Form catat transaksi: pemasukan (revenue) atau biaya (cost).
/// PRD FR-REV-01..02 / FR-CST-01..02 & BR-05 (multi-mata uang dengan kurs ke IDR base).
/// Mengembalikan [Invoice] via `Navigator.pop`.
class RecordTransactionScreen extends StatefulWidget {
  final FinanceEntryType type;
  final Future<List<Shipment>> Function() loadShipments;
  final String? initialShipmentNo;

  const RecordTransactionScreen({
    super.key,
    required this.type,
    required this.loadShipments,
    this.initialShipmentNo,
  });

  @override
  State<RecordTransactionScreen> createState() =>
      _RecordTransactionScreenState();
}

class _RecordTransactionScreenState extends State<RecordTransactionScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _invoiceNo = TextEditingController(
    text: 'INV/2610/${DateTime.now().millisecondsSinceEpoch % 900 + 100}',
  );
  final _party = TextEditingController();
  final _category = TextEditingController();
  final _dpp = TextEditingController();
  final _ppn = TextEditingController();
  final _rate = TextEditingController(text: '15800');
  DateTime _date = DateTime.now();
  bool _paid = false;
  String _currency = 'IDR';
  List<Shipment> _shipments = const [];
  String? _shipmentNo;

  static const _currencies = ['IDR', 'USD', 'SGD'];
  static const _defaultRates = {'IDR': 1, 'USD': 15800, 'SGD': 11900};

  bool get _isRevenue => widget.type == FinanceEntryType.revenue;

  @override
  void initState() {
    super.initState();
    _shipmentNo = widget.initialShipmentNo;
    widget.loadShipments().then((v) {
      if (mounted) {
        setState(() {
          _shipments = v;
          if (_shipmentNo != null &&
              !_shipments.any((s) => s.id == _shipmentNo)) {
            _shipmentNo = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _invoiceNo.dispose();
    _party.dispose();
    _category.dispose();
    _dpp.dispose();
    _ppn.dispose();
    _rate.dispose();
    super.dispose();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  /// Konversi nilai input ke ekuivalen juta Rupiah (IDR base, BR-05):
  /// - Jika IDR: input sudah dalam satuan juta (jt).
  /// - Jika USD/SGD: input dalam ribuan mata uang asal (mis. 5 = USD 5.000)
  ///   atau nominal langsung, dikonversi dengan kurs ke juta IDR.
  int get _baseIdrJt {
    final raw = double.tryParse(_dpp.text.trim().replaceAll(',', '.')) ?? 0;
    if (_currency == 'IDR') return raw.round();
    final rate = int.tryParse(_rate.text.trim()) ?? _defaultRates[_currency]!;
    // Jika user mengetik <= 500 (mis. 10 = 10 ribu USD), konversi dari ribuan;
    // jika > 500 (mis. 10000 USD), konversi langsung ke juta IDR.
    final fullForeign = raw <= 500 ? raw * 1000 : raw;
    return ((fullForeign * rate) / 1000000).round().clamp(1, 999999);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final dppJt = _baseIdrJt;
    final ppn = int.tryParse(_ppn.text.trim()) ?? 0;
    final rate = _currency == 'IDR'
        ? 1
        : (int.tryParse(_rate.text.trim()) ?? _defaultRates[_currency]!);
    final sign = _isRevenue ? '+' : '-';
    final curNote = _currency == 'IDR' ? '' : ' ($_currency)';
    final invNo = _invoiceNo.text.trim().isEmpty
        ? 'INV/2610/${DateTime.now().millisecondsSinceEpoch % 1000}'
        : _invoiceNo.text.trim();
    Navigator.of(context).pop(Invoice(
      invNo,
      '${_category.text.trim()}$curNote · ${_fmt(_date)}',
      '$sign Rp $dppJt jt',
      _paid ? 'PAID' : 'UNPAID',
      _paid,
      type: widget.type,
      counterparty: _party.text.trim(),
      shipmentNo: _shipmentNo,
      category: _category.text.trim(),
      invoiceDate: _date,
      dppRupiah: dppJt,
      ppnRupiah: ppn,
      paidRupiah: _paid ? dppJt : 0,
      currency: _currency,
      exchangeRate: rate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              _isRevenue ? 'Catat pemasukan' : 'Catat biaya',
              subtitle: _isRevenue
                  ? 'Tagihan customer (DPP & PPN keluaran)'
                  : 'Tagihan vendor (DPP & PPN masukan)',
            ),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _field('No. Invoice', _invoiceNo),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: _datePickerField(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field(_isRevenue ? 'Customer penagih' : 'Vendor', _party,
                        hint: _isRevenue
                            ? 'mis. PT Garuda Trading'
                            : 'mis. Meratus Line'),
                    const SizedBox(height: 14),
                    _label('Tautkan ke Shipment (opsional)'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      initialValue: _shipmentNo,
                      decoration: _dec(),
                      hint: const Text('Tanpa shipment'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Tanpa shipment')),
                        for (final s in _shipments)
                          DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.id} · ${s.route}')),
                      ],
                      onChanged: (v) => setState(() => _shipmentNo = v),
                    ),
                    const SizedBox(height: 14),
                    _field('Kategori', _category,
                        hint: 'mis. Ocean Freight, Handling, THC'),
                    const SizedBox(height: 16),
                    _label('Mata uang (BR-05)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in _currencies) ...[
                          if (c != _currencies.first) const SizedBox(width: 8),
                          Pressable(
                            onTap: () => setState(() {
                              _currency = c;
                              if (c != 'IDR') {
                                _rate.text = '${_defaultRates[c]}';
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: kEaseOut,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: _currency == c
                                    ? AppColors.ink
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                boxShadow:
                                    _currency == c ? null : AppShadows.soft,
                              ),
                              child: Text(c,
                                  style: TextStyle(
                                      color: _currency == c
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_currency != 'IDR') ...[
                      const SizedBox(height: 14),
                      _field(
                        'Kurs $_currency ke IDR',
                        _rate,
                        number: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            _currency == 'IDR'
                                ? 'Nominal DPP (jt IDR)'
                                : 'Nominal DPP (ribu $_currency)',
                            _dpp,
                            number: true,
                            hint: _currency == 'IDR' ? '120' : '10',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            _isRevenue
                                ? 'PPN Keluaran (jt)'
                                : 'PPN Masukan (jt)',
                            _ppn,
                            number: true,
                            required: false,
                            hint: '0',
                          ),
                        ),
                      ],
                    ),
                    if (_currency != 'IDR' && _dpp.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Ekuivalen base IDR: Rp $_baseIdrJt jt (kurs Rp ${_rate.text}/$_currency)',
                          style: const TextStyle(
                              color: AppColors.greenInk,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.ink,
                      title: const Text('Sudah lunas',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.ink)),
                      subtitle: const Text(
                          'Jika belum lunas, otomatis masuk daftar piutang/hutang.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                      value: _paid,
                      onChanged: (v) => setState(() => _paid = v),
                    ),
                    const SizedBox(height: 10),
                    const DemoNote(
                        text:
                            'Profit dihitung dari nilai sebelum pajak (DPP); PPN dicatat terpisah sesuai BR-03.'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('save-transaction'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: _save,
                  child: const Text('Simpan transaksi',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Tanggal'),
          const SizedBox(height: 6),
          Pressable(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Row(
                children: [
                  const Icon(IconsaxPlusLinear.calendar_1,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_fmt(_date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w700));

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    bool number = false,
    bool required = true,
    ValueChanged<String>? onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.ink, fontSize: 14),
            decoration: _dec(hint: hint ?? label),
            validator: required
                ? (v) =>
                    (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
                : null,
          ),
        ],
      );

  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
      );
}
