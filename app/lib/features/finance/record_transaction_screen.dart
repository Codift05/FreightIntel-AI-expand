import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'finance_repository.dart';
import '../shipments/shipment_repository.dart';

/// Form catat transaksi: pemasukan (revenue) atau biaya (cost).
/// PRD FR-REV-01 / FR-CST-01. Mengembalikan [Invoice] via Navigator.pop.
/// Data demo; nominal dalam satuan juta (jt).
class RecordTransactionScreen extends StatefulWidget {
  final FinanceEntryType type;
  final Future<List<Shipment>> Function() loadShipments;

  const RecordTransactionScreen({
    super.key,
    required this.type,
    required this.loadShipments,
  });

  @override
  State<RecordTransactionScreen> createState() =>
      _RecordTransactionScreenState();
}

class _RecordTransactionScreenState extends State<RecordTransactionScreen> {
  final _form = GlobalKey<FormState>();
  final _party = TextEditingController();
  final _category = TextEditingController();
  final _dpp = TextEditingController();
  final _ppn = TextEditingController();
  DateTime _date = DateTime.now();
  bool _paid = false;
  List<Shipment> _shipments = const [];
  String? _shipmentNo;

  bool get _isRevenue => widget.type == FinanceEntryType.revenue;

  @override
  void initState() {
    super.initState();
    widget.loadShipments().then((v) {
      if (mounted) setState(() => _shipments = v);
    });
  }

  @override
  void dispose() {
    _party.dispose();
    _category.dispose();
    _dpp.dispose();
    _ppn.dispose();
    super.dispose();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
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

  void _save() {
    if (!_form.currentState!.validate()) return;
    final dpp = int.tryParse(_dpp.text.trim()) ?? 0;
    final ppn = int.tryParse(_ppn.text.trim()) ?? 0;
    final sign = _isRevenue ? '+' : '-';
    Navigator.of(context).pop(Invoice(
      'INV/2610/${DateTime.now().millisecondsSinceEpoch % 1000}',
      '${_category.text.trim()} · ${_fmt(_date)}',
      '$sign Rp $dpp jt',
      _paid ? 'PAID' : 'UNPAID',
      _paid,
      type: widget.type,
      counterparty: _party.text.trim(),
      shipmentNo: _shipmentNo,
      category: _category.text.trim(),
      invoiceDate: _date,
      dppRupiah: dpp,
      ppnRupiah: ppn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRevenue ? 'Catat pemasukan' : 'Catat biaya',
            style: numStyle(size: 17)),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _field(_isRevenue ? 'Customer' : 'Vendor', _party),
            const SizedBox(height: 16),
            _label('Shipment (opsional)'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              initialValue: _shipmentNo,
              decoration: _dec(),
              hint: const Text('Tanpa shipment'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tanpa shipment')),
                for (final s in _shipments)
                  DropdownMenuItem(value: s.id, child: Text('${s.id} · ${s.route}')),
              ],
              onChanged: (v) => setState(() => _shipmentNo = v),
            ),
            const SizedBox(height: 16),
            _field('Kategori', _category, hint: 'mis. Ocean Freight, Handling'),
            const SizedBox(height: 16),
            _label('Tanggal'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadii.input),
              child: InputDecorator(
                decoration: _dec(),
                child: Text(_fmt(_date),
                    style: const TextStyle(fontSize: 15, color: AppColors.ink)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field('Nominal DPP (jt)', _dpp, number: true)),
                const SizedBox(width: 12),
                Expanded(child: _field('PPN (jt)', _ppn, number: true, required: false)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.green,
              title: const Text('Sudah lunas',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.ink)),
              value: _paid,
              onChanged: (v) => setState(() => _paid = v),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('save-transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill)),
              ),
              onPressed: _save,
              child: const Text('Simpan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.inkSoft, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _field(String label, TextEditingController c,
          {String? hint, bool number = false, bool required = true}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            keyboardType: number ? TextInputType.number : TextInputType.text,
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
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
      );
}
