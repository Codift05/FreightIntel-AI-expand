import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'shipment_repository.dart';

/// Ubah data & status shipment, serta arsipkan (FR-SHP-05, FR-SHP-06).
/// Mengembalikan [Shipment] yang sudah diubah lewat `Navigator.pop`.
class EditShipmentScreen extends StatefulWidget {
  final Shipment shipment;
  const EditShipmentScreen(this.shipment, {super.key});

  @override
  State<EditShipmentScreen> createState() => _EditShipmentScreenState();
}

class _EditShipmentScreenState extends State<EditShipmentScreen> {
  late final TextEditingController _client, _asal, _tujuan;
  late String _type, _status;
  late bool _arsip;
  bool _berubah = false;

  static const _modes = ['Ocean Freight', 'Air Freight', 'Trucking', 'Handling'];

  @override
  void initState() {
    super.initState();
    final s = widget.shipment;
    final r = s.route.split('→');
    _client = TextEditingController(text: s.client);
    _asal = TextEditingController(text: r.first.trim());
    _tujuan = TextEditingController(text: r.length > 1 ? r[1].trim() : '');
    _type = s.type;
    _status = s.status;
    _arsip = s.arsip;
    for (final c in [_client, _asal, _tujuan]) {
      c.addListener(() {
        if (!_berubah) setState(() => _berubah = true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_client, _asal, _tujuan]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setStatus(String s) {
    HapticFeedback.selectionClick();
    setState(() => (_status = s, _berubah = true));
  }

  void _simpan() {
    final updated = widget.shipment.copyWith(
      client: _client.text.trim(),
      route: '${_asal.text.trim()} → ${_tujuan.text.trim()}',
      type: _type,
      status: _status,
      arsip: _arsip,
    );
    ShipmentRepository.instance.update(updated);
    Navigator.of(context).pop(updated);
  }

  Future<void> _konfirmasiArsip() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.tile)),
        title: Text(_arsip ? 'Kembalikan dari arsip?' : 'Arsipkan shipment?',
            style: numStyle(size: 16)),
        content: Text(
            _arsip
                ? '${widget.shipment.id} akan tampil lagi di daftar aktif.'
                : '${widget.shipment.id} disembunyikan dari daftar aktif. Transaksi yang sudah tercatat tetap tersimpan, tidak dihapus.',
            style: const TextStyle(
                color: AppColors.inkSoft, fontSize: 13.5, height: 1.45)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_arsip ? 'Kembalikan' : 'Arsipkan',
                style: const TextStyle(
                    color: AppColors.loss, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ya == true) setState(() => (_arsip = !_arsip, _berubah = true));
  }

  @override
  Widget build(BuildContext context) {
    final idx = kShipmentStatuses.indexOf(_status);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader('Ubah shipment', subtitle: widget.shipment.id),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Text('Status', style: numStyle(size: 15)),
                  const SizedBox(height: 4),
                  const Text(
                      'Urutan siklus: Booking sampai Completed. Ketuk untuk pindah status.',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0;
                            i < kShipmentStatuses.length;
                            i++) ...[
                          if (i > 0) const SizedBox(height: 2),
                          _statusRow(kShipmentStatuses[i], i, idx),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Data shipment', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _field('Customer', _client),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _field('Asal', _asal)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Tujuan', _tujuan)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Moda',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in _modes)
                        Pressable(
                          onTap: () =>
                              setState(() => (_type = m, _berubah = true)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            curve: kEaseOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _type == m
                                  ? AppColors.ink
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                              boxShadow:
                                  _type == m ? null : AppShadows.soft,
                            ),
                            child: Text(m,
                                style: TextStyle(
                                    color: _type == m
                                        ? Colors.white
                                        : AppColors.muted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Pressable(
                    semanticLabel: _arsip ? 'Kembalikan' : 'Arsipkan',
                    onTap: _konfirmasiArsip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.lossSoft,
                        borderRadius: BorderRadius.circular(AppRadii.tile),
                      ),
                      child: Row(
                        children: [
                          const Icon(IconsaxPlusLinear.archive_1,
                              size: 19, color: AppColors.loss),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _arsip
                                        ? 'Shipment diarsipkan'
                                        : 'Arsipkan shipment',
                                    style: const TextStyle(
                                        color: AppColors.loss,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                const Text(
                                    'Tidak dihapus permanen karena ada transaksi terkait.',
                                    style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 11.5,
                                        height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const DemoNote(
                      text:
                          'Perubahan tersimpan sementara di memori aplikasi.'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _berubah ? AppColors.lime : AppColors.line,
                    foregroundColor:
                        _berubah ? AppColors.ink : AppColors.muted,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: _berubah ? _simpan : null,
                  child: Text(
                      _berubah ? 'Simpan perubahan' : 'Belum ada perubahan',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String s, int i, int aktif) {
    final lewat = i < aktif;
    final kini = i == aktif;
    return Pressable(
      scale: 0.98,
      semanticLabel: 'Set status $s',
      onTap: () => _setStatus(s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: kEaseOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: kini
                    ? AppColors.ink
                    : lewat
                        ? AppColors.greenSoft
                        : AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                  kini
                      ? Icons.circle
                      : lewat
                          ? Icons.check
                          : Icons.circle_outlined,
                  size: kini ? 8 : 13,
                  color: kini
                      ? Colors.white
                      : lewat
                          ? AppColors.greenInk
                          : AppColors.line),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(s,
                  style: TextStyle(
                      color: kini
                          ? AppColors.ink
                          : lewat
                              ? AppColors.inkSoft
                              : AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: kini ? FontWeight.w700 : FontWeight.w500)),
            ),
            if (kini)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Text('Sekarang',
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            style: const TextStyle(color: AppColors.ink, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.input),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
}
