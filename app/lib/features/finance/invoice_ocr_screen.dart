import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'finance_repository.dart';

enum _Step { pilih, baca, hasil }

/// Scan invoice: unggah berkas, AI ekstrak isinya, hasil bisa dikoreksi
/// sebelum disimpan (FR-OCR-01..04).
class InvoiceOcrScreen extends StatefulWidget {
  const InvoiceOcrScreen({super.key});

  @override
  State<InvoiceOcrScreen> createState() => _InvoiceOcrScreenState();
}

class _InvoiceOcrScreenState extends State<InvoiceOcrScreen> {
  _Step _step = _Step.pilih;
  String _sumber = '';

  // Hasil ekstraksi (bisa dikoreksi user sebelum disimpan).
  final _pihak = TextEditingController(text: 'CV Mitra Laut');
  final _noInvoice = TextEditingController(text: 'INV/MTL/2610/118');
  final _tanggal = TextEditingController(text: '2026-10-28');
  final _dpp = TextEditingController(text: '14000000');
  final _ppn = TextEditingController(text: '1540000');
  final _kategori = TextEditingController(text: 'Trucking pelabuhan');
  FinanceEntryType _tipe = FinanceEntryType.cost;

  @override
  void dispose() {
    for (final c in [_pihak, _noInvoice, _tanggal, _dpp, _ppn, _kategori]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _mulai(String sumber) async {
    setState(() => (_sumber = sumber, _step = _Step.baca));
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _step = _Step.hasil);
  }

  void _simpan() {
    final dpp = int.tryParse(_dpp.text.trim()) ?? 0;
    final ppn = int.tryParse(_ppn.text.trim()) ?? 0;
    final jt = (dpp / 1000000).round();
    FinanceRepository.instance.add(Invoice(
      _noInvoice.text.trim(),
      '${_kategori.text.trim()} · ${_tanggal.text.trim()}',
      '${_tipe == FinanceEntryType.revenue ? '+' : '-'}Rp $jt jt',
      'UNPAID',
      false,
      type: _tipe,
      counterparty: _pihak.text.trim(),
      category: _kategori.text.trim(),
      dppRupiah: jt,
      ppnRupiah: (ppn / 1000000).round(),
      paidRupiah: 0,
    ));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Scan invoice',
                subtitle: 'AI membaca isi invoice jadi transaksi'),
            Expanded(
              child: switch (_step) {
                _Step.pilih => _pilih(),
                _Step.baca => _baca(),
                _Step.hasil => _hasil(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pilih() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.line, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt, shape: BoxShape.circle),
                  child: const Icon(IconsaxPlusLinear.document_upload,
                      size: 26, color: AppColors.ink),
                ),
                const SizedBox(height: 16),
                const Text('Unggah foto atau PDF invoice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                    'Vendor, nomor, tanggal, jumlah, dan pajak diisi otomatis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.muted, fontSize: 12.5, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _sumberBtn(IconsaxPlusLinear.camera, 'Kamera',
                      dark: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _sumberBtn(IconsaxPlusLinear.gallery, 'Galeri')),
              const SizedBox(width: 12),
              Expanded(
                  child: _sumberBtn(IconsaxPlusLinear.document_text, 'PDF')),
            ],
          ),
          const SizedBox(height: 20),
          const DemoNote(
              text:
                  'Mode demo: berkas belum benar-benar dibaca. Hasil di bawah adalah contoh ekstraksi yang bisa kamu koreksi.'),
        ],
      );

  Widget _sumberBtn(IconData icon, String label, {bool dark = false}) =>
      Pressable(
        semanticLabel: 'Ambil dari $label',
        onTap: () => _mulai(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: dark ? AppColors.ink : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.tile),
            boxShadow: dark ? null : AppShadows.soft,
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20, color: dark ? Colors.white : AppColors.ink),
              const SizedBox(height: 7),
              Text(label,
                  style: TextStyle(
                      color: dark ? Colors.white : AppColors.ink,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  Widget _baca() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                  strokeWidth: 2.6, color: AppColors.ink),
            ),
            const SizedBox(height: 18),
            Text('Membaca invoice dari $_sumber',
                style: numStyle(size: 15)),
            const SizedBox(height: 6),
            const Text('Mengenali vendor, nominal, dan pajak',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
          ],
        ).animate().fadeIn(duration: 260.ms),
      );

  Widget _hasil() => Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(AppRadii.tile),
                  ),
                  child: Row(
                    children: [
                      const Icon(IconsaxPlusBold.tick_circle,
                          size: 20, color: AppColors.greenInk),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                            'Isi invoice terbaca. Periksa dulu sebelum disimpan.',
                            style: TextStyle(
                                color: AppColors.greenInk,
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1, end: 0, curve: kEaseOut),
                const SizedBox(height: 20),
                Text('Jenis transaksi', style: numStyle(size: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _tipeBtn(
                            FinanceEntryType.cost, 'Biaya', 'ke vendor')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _tipeBtn(FinanceEntryType.revenue,
                            'Pemasukan', 'dari customer')),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Hasil ekstraksi', style: numStyle(size: 15)),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: [
                      _field(
                          _tipe == FinanceEntryType.cost
                              ? 'Vendor'
                              : 'Customer',
                          _pihak),
                      _field('Nomor invoice', _noInvoice),
                      _field('Tanggal', _tanggal),
                      _field('Kategori', _kategori),
                      _field('DPP (Rp)', _dpp, angka: true),
                      _field('PPN (Rp)', _ppn, angka: true, last: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const DemoNote(
                    text:
                        'Nilai di atas contoh hasil ekstraksi, bukan dari berkas asli.'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Pressable(
                    onTap: () => setState(() => _step = _Step.pilih),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        boxShadow: AppShadows.soft,
                      ),
                      child: const Text('Ulangi',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Pressable(
                    onTap: _simpan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: const Text('Simpan sebagai transaksi',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _tipeBtn(FinanceEntryType t, String label, String sub) {
    final sel = _tipe == t;
    return Pressable(
      onTap: () => setState(() => _tipe = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: kEaseOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          boxShadow: sel ? null : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: sel ? Colors.white : AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    color: sel ? AppColors.onDark : AppColors.muted,
                    fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
          {bool angka = false, bool last = false}) =>
      Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 108,
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12.5)),
              ),
              Expanded(
                child: TextField(
                  controller: c,
                  keyboardType:
                      angka ? TextInputType.number : TextInputType.text,
                  style: numStyle(size: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          if (!last) const Divider(height: 1, color: AppColors.line),
        ],
      );
}
