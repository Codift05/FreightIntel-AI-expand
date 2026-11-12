import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'shipment_repository.dart';

/// Form buat shipment lengkap sesuai PRD FR-SHP-01:
/// customer, moda/tipe, rute (asal & tujuan), kontainer, dan jadwal (ETD & ETA).
/// Mengembalikan [Shipment] baru (status Booking, nilai 0) lewat `Navigator.pop`.
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
  final _container = TextEditingController(text: '1 x 40ft HC');
  String _type = 'Ocean Freight';
  DateTime _etd = DateTime.now().add(const Duration(days: 2));
  DateTime _eta = DateTime.now().add(const Duration(days: 14));

  static const _types = [
    'Ocean Freight',
    'Air Freight',
    'Trucking',
    'Handling',
  ];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  void dispose() {
    _customer.dispose();
    _origin.dispose();
    _dest.dispose();
    _container.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEtd}) async {
    final initial = isEtd ? _etd : _eta;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isEtd) {
        _etd = picked;
        if (_eta.isBefore(_etd)) {
          _eta = _etd.add(const Duration(days: 7));
        }
      } else {
        _eta = picked;
      }
    });
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
      container: _container.text.trim().isEmpty
          ? '1 x 40ft HC'
          : _container.text.trim(),
      etd: _fmt(_etd),
      eta: _fmt(_eta),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Buat shipment', subtitle: 'Data & jadwal pengiriman'),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _field('Customer', _customer, hint: 'mis. PT Garuda Trading'),
                    const SizedBox(height: 16),
                    _label('Moda / Tipe'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in _types)
                          Pressable(
                            onTap: () => setState(() => _type = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: kEaseOut,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: _type == t
                                    ? AppColors.ink
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                boxShadow:
                                    _type == t ? null : AppShadows.soft,
                              ),
                              child: Text(t,
                                  style: TextStyle(
                                      color: _type == t
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _field('Pelabuhan / Kota Asal', _origin,
                                hint: 'Jakarta')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field('Pelabuhan / Kota Tujuan', _dest,
                                hint: 'Rotterdam')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _field(
                      'Kontainer / Kargo',
                      _container,
                      hint: 'mis. 1 x 40ft HC · TCLU-882910',
                      required: false,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _dateTile(
                            label: 'Jadwal Berangkat (ETD)',
                            value: _fmt(_etd),
                            onTap: () => _pickDate(isEtd: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateTile(
                            label: 'Estimasi Tiba (ETA)',
                            value: _fmt(_eta),
                            onTap: () => _pickDate(isEtd: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const DemoNote(
                        text:
                            'Nomor shipment dibuat otomatis dan tersimpan di memori sesi ini.'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: _save,
                  child: const Text('Simpan shipment',
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

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w700));

  Widget _dateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          Pressable(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Row(
                children: [
                  const Icon(IconsaxPlusLinear.calendar_1,
                      size: 17, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(value,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _field(String label, TextEditingController c,
          {String? hint, bool required = true}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
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
