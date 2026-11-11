import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Daftar cabang perusahaan aktif (FR-CMP-02).
class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final _repo = SettingsRepository.instance;

  Future<void> _tambah() async {
    final nama = TextEditingController();
    final kota = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Cabang baru', style: numStyle(size: 16)),
                const SizedBox(height: 16),
                _input(nama, 'Nama cabang'),
                const SizedBox(height: 12),
                _input(kota, 'Kota'),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Tambah cabang',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true && nama.text.trim().isNotEmpty) {
      setState(() => _repo.branches
          .add(Branch(nama.text.trim(), kota.text.trim().isEmpty ? '-' : kota.text.trim())));
    }
    nama.dispose();
    kota.dispose();
  }

  static Widget _input(TextEditingController c, String hint) => TextField(
        controller: c,
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: BorderSide.none,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final b = _repo.branches;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Cabang',
              subtitle: '${b.length} cabang · ${_repo.active.nama}',
              action: HeaderAction(
                  icon: IconsaxPlusBold.add,
                  label: 'Tambah cabang',
                  onTap: _tambah),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  for (final x in b)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: x.pusat
                                    ? AppColors.greenSoft
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                  x.pusat
                                      ? IconsaxPlusBold.buildings_2
                                      : IconsaxPlusLinear.buildings,
                                  size: 20,
                                  color: x.pusat
                                      ? AppColors.greenInk
                                      : AppColors.ink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                          child: Text(x.nama,
                                              style: numStyle(size: 14.5))),
                                      if (x.pusat) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.greenSoft,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadii.pill),
                                          ),
                                          child: const Text('Pusat',
                                              style: TextStyle(
                                                  color: AppColors.greenInk,
                                                  fontSize: 10.5,
                                                  fontWeight:
                                                      FontWeight.w800)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${x.kota} · ${x.pengguna} pengguna',
                                      style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  const DemoNote(
                      text:
                          'Cabang baru tersimpan sementara di memori aplikasi.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
