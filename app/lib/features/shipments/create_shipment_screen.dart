import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'shipment_repository.dart';

/// Form buat shipment (PRD FR-SHP-01, inti). Mengembalikan Shipment baru
/// (status Booking, nilai 0) lewat Navigator.pop. Data demo, belum ke backend.
/// shortcut: container & jadwal (ETD/ETA) belum diisi di sini; tambah saat modul detail siap.
class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _form = GlobalKey<FormState>();
  final _customer = TextEditingController();
  final _origin = TextEditingController();
  final _dest = TextEditingController();
  String _type = 'Ocean Freight';

  static const _types = ['Ocean Freight', 'Air Freight', 'Trucking', 'Handling'];

  @override
  void dispose() {
    _customer.dispose();
    _origin.dispose();
    _dest.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final id = 'FI-2610-${DateTime.now().millisecondsSinceEpoch % 10000}';
    Navigator.of(context).pop(Shipment(
      id,
      _customer.text.trim(),
      '${_origin.text.trim()} → ${_dest.text.trim()}',
      _type,
      'Rp 0 jt',
      'Rp 0 jt',
      true,
      'Booking',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat shipment', style: numStyle(size: 17))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _field('Customer', _customer),
            const SizedBox(height: 16),
            _label('Tipe'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: _dec(),
              items: [
                for (final t in _types)
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            _field('Asal', _origin),
            const SizedBox(height: 16),
            _field('Tujuan', _dest),
            const SizedBox(height: 28),
            FilledButton(
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

  Widget _field(String label, TextEditingController c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            decoration: _dec(hint: label),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
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
