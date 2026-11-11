import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Profil perusahaan + mata uang & pajak (FR-CMP-03, FR-CMP-04).
class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _repo = SettingsRepository.instance;
  late final TextEditingController _nama, _npwp, _alamat, _ppn;
  late String _mataUang;
  bool _berubah = false;

  @override
  void initState() {
    super.initState();
    final c = _repo.active;
    _nama = TextEditingController(text: c.nama);
    _npwp = TextEditingController(text: c.npwp);
    _alamat = TextEditingController(text: c.alamat);
    _ppn = TextEditingController(text: c.ppnPersen.toStringAsFixed(0));
    _mataUang = c.mataUang;
    for (final c in [_nama, _npwp, _alamat, _ppn]) {
      c.addListener(() {
        if (!_berubah) setState(() => _berubah = true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_nama, _npwp, _alamat, _ppn]) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpan() {
    _repo.updateActive(_repo.active.copyWith(
      nama: _nama.text.trim(),
      npwp: _npwp.text.trim(),
      alamat: _alamat.text.trim(),
      mataUang: _mataUang,
      ppnPersen: double.tryParse(_ppn.text.trim()) ?? _repo.active.ppnPersen,
    ));
    setState(() => _berubah = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil perusahaan tersimpan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Profil perusahaan',
                subtitle: 'Identitas, mata uang, dan pajak'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _logoCard(),
                  const SizedBox(height: 20),
                  Text('Identitas', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _field('Nama perusahaan', _nama),
                  const SizedBox(height: 12),
                  _field('NPWP', _npwp),
                  const SizedBox(height: 12),
                  _field('Alamat', _alamat, lines: 2),
                  const SizedBox(height: 24),
                  Text('Mata uang & pajak', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mata uang utama',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12.5)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final m in ['IDR', 'USD', 'SGD'])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Pressable(
                                  onTap: () => setState(
                                      () => (_mataUang = m, _berubah = true)),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 160),
                                    curve: kEaseOut,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _mataUang == m
                                          ? AppColors.ink
                                          : AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(
                                          AppRadii.pill),
                                    ),
                                    child: Text(m,
                                        style: TextStyle(
                                            color: _mataUang == m
                                                ? Colors.white
                                                : AppColors.muted,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 28, color: AppColors.line),
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PPN keluaran & masukan',
                                      style: TextStyle(
                                          color: AppColors.ink,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 2),
                                  Text('Dipakai sebagai nilai awal transaksi',
                                      style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 76,
                              child: TextField(
                                controller: _ppn,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.end,
                                style: numStyle(size: 15),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  suffixText: '%',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          _berubah ? AppColors.lime : AppColors.line,
                      foregroundColor:
                          _berubah ? AppColors.ink : AppColors.muted,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.pill)),
                    ),
                    onPressed: _berubah ? _simpan : null,
                    child: Text(_berubah ? 'Simpan perubahan' : 'Tersimpan',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  const SizedBox(height: 14),
                  const DemoNote(
                      text:
                          'Tersimpan di memori aplikasi, belum dikirim ke server.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoCard() => AppCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(IconsaxPlusLinear.gallery,
                  size: 22, color: AppColors.muted),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logo perusahaan',
                      style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Tampil di invoice dan laporan',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            Pressable(
              semanticLabel: 'Unggah logo',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Unggah logo aktif setelah penyimpanan berkas tersambung.')),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Text('Unggah',
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );

  Widget _field(String label, TextEditingController c, {int lines = 1}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: lines,
            style: const TextStyle(
                color: AppColors.ink, fontSize: 14, height: 1.4),
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
