import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/illustrations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/login_screen.dart';
import 'activity_log_screen.dart';
import 'branches_screen.dart';
import 'company_screen.dart';
import 'custom_fields_screen.dart';
import 'role_permissions_screen.dart';
import 'settings_repository.dart';
import 'users_screen.dart';

/// Pusat pengaturan: perusahaan, cabang, pengguna, izin, custom field, log.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = SettingsRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.syncFromBackend().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) setState(() {}); // ringkasan bisa berubah
  }

  void _switchCompany() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pindah perusahaan', style: numStyle(size: 16)),
              const SizedBox(height: 6),
              const Text(
                  'Data shipment, keuangan, dan laporan ikut berganti. Antar perusahaan tidak saling terlihat.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12.5, height: 1.4)),
              const SizedBox(height: 16),
              for (final c in _repo.companies)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Pressable(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _repo.switchCompany(c.id);
                      if (!mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Perusahaan aktif: ${c.nama}')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: c.id == _repo.activeCompanyId
                            ? AppColors.greenSoft
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadii.tile),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.nama, style: numStyle(size: 14)),
                                const SizedBox(height: 2),
                                Text(c.npwp,
                                    style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          if (c.id == _repo.activeCompanyId)
                            const Icon(IconsaxPlusBold.tick_circle,
                                size: 20, color: AppColors.greenInk),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _repo.active;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Pengaturan',
                subtitle: 'Perusahaan, pengguna, dan data'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _companyCard(c),
                  const SizedBox(height: 24),
                  Text('Perusahaan', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _group([
                    _row(IconsaxPlusLinear.buildings, 'Profil perusahaan',
                        'Nama, NPWP, alamat, mata uang & PPN',
                        () => _open(const CompanyScreen())),
                    _row(IconsaxPlusLinear.hierarchy_square, 'Cabang',
                        '${_repo.branches.length} cabang terdaftar',
                        () => _open(const BranchesScreen())),
                  ]),
                  const SizedBox(height: 24),
                  Text('Pengguna & akses', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _group([
                    _row(IconsaxPlusLinear.profile_2user, 'Pengguna',
                        '${_repo.users.where((u) => u.aktif).length} aktif dari ${_repo.users.length}',
                        () => _open(const UsersScreen())),
                    _row(IconsaxPlusLinear.lock_1, 'Peran & izin',
                        '${kRoles.length} peran bawaan',
                        () => _open(const RolePermissionsScreen())),
                    _row(IconsaxPlusLinear.clock, 'Log aktivitas',
                        'Login dan perubahan data',
                        () => _open(const ActivityLogScreen())),
                  ]),
                  const SizedBox(height: 24),
                  Text('Data', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _group([
                    _row(IconsaxPlusLinear.category, 'Custom field',
                        '${_repo.fields.length} field aktif',
                        () => _open(const CustomFieldsScreen())),
                  ]),
                  const SizedBox(height: 24),
                  Pressable(
                    semanticLabel: 'Keluar dari sesi demo',
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        boxShadow: AppShadows.soft,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconsaxPlusLinear.logout,
                              size: 18, color: AppColors.loss),
                          SizedBox(width: 8),
                          Text('Keluar dari sesi demo',
                              style: TextStyle(
                                  color: AppColors.loss,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const DemoNote(
                      text:
                          'Perubahan pengaturan tersimpan sementara, hilang saat aplikasi ditutup.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _companyCard(Company c) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                  color: AppColors.greenSoft, shape: BoxShape.circle),
              child: Image.asset(Illus.avatarOwner, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Perusahaan aktif',
                      style: TextStyle(
                          color: AppColors.onDark, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(c.nama,
                      style: numStyle(size: 16, color: Colors.white)),
                ],
              ),
            ),
            Pressable(
              semanticLabel: 'Pindah perusahaan',
              onTap: _switchCompany,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Text('Ganti',
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );

  Widget _group(List<Widget> rows) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              rows[i],
            ],
          ],
        ),
      );

  Widget _row(IconData icon, String title, String sub, VoidCallback onTap) =>
      Pressable(
        semanticLabel: title,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(IconsaxPlusLinear.arrow_right_3,
                  size: 16, color: AppColors.muted),
            ],
          ),
        ),
      );
}
