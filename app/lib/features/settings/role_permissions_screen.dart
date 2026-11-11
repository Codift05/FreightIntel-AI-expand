import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Peran bawaan + matriks izin per modul (FR-USR-02, FR-USR-03, FR-USR-04).
class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({super.key});

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  final _repo = SettingsRepository.instance;
  String _role = kRoles[1];

  bool get _terkunci => _role == 'Super Admin';

  void _toggle(String modul, String aksi) {
    if (_terkunci) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Izin Super Admin tidak bisa dikurangi.')),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      final set = _repo.permissions[_role]![modul]!;
      if (set.contains(aksi)) {
        set.remove(aksi);
      } else {
        set.add(aksi);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final perm = _repo.permissions[_role]!;
    final total = perm.values.fold<int>(0, (s, e) => s + e.length);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Peran & izin',
                subtitle: 'Hak akses per modul'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final r in kRoles)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Pressable(
                              onTap: () => setState(() => _role = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                curve: kEaseOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _role == r
                                      ? AppColors.ink
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                  boxShadow:
                                      _role == r ? null : AppShadows.soft,
                                ),
                                child: Text(r,
                                    style: TextStyle(
                                        color: _role == r
                                            ? Colors.white
                                            : AppColors.muted,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inkDeep,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_role,
                                  style: numStyle(
                                      size: 16, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                  '$total izin aktif dari ${kModules.length * kActions.length}',
                                  style: const TextStyle(
                                      color: AppColors.onDark,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                        if (_terkunci)
                          const Icon(IconsaxPlusBold.lock_1,
                              size: 20, color: AppColors.onDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _matrix(perm),
                  const SizedBox(height: 14),
                  DemoNote(
                      text: _terkunci
                          ? 'Super Admin selalu punya akses penuh. Ketuk peran lain untuk mengubah izin.'
                          : 'Ketuk kotak untuk memberi atau mencabut izin. Tersimpan sementara.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matrix(Map<String, Set<String>> perm) => AppCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(flex: 4, child: SizedBox()),
                for (final a in kActions)
                  Expanded(
                    flex: 2,
                    child: Text(a,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            for (final m in kModules) ...[
              const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(m,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    for (final a in kActions)
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Pressable(
                            scale: 0.88,
                            semanticLabel: '$m $a',
                            onTap: () => _toggle(m, a),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              curve: kEaseOut,
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: perm[m]!.contains(a)
                                    ? AppColors.ink
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: perm[m]!.contains(a)
                                  ? const Icon(Icons.check,
                                      size: 15, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}
