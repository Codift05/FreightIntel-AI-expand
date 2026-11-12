import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Kelola pengguna per perusahaan (FR-USR-01).
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _repo = SettingsRepository.instance;
  String _filter = 'Semua';

  List<AppUser> get _rows => switch (_filter) {
        'Aktif' => _repo.users.where((u) => u.aktif).toList(),
        'Nonaktif' => _repo.users.where((u) => !u.aktif).toList(),
        _ => _repo.users,
      };

  void _aksi(AppUser u) {
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
              Text(u.nama, style: numStyle(size: 16)),
              const SizedBox(height: 2),
              Text(u.email,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const SizedBox(height: 18),
              const Text('Ubah peran',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const SizedBox(height: 8),
              for (final r in kRoles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Pressable(
                    onTap: () {
                      setState(() {
                        final i = _repo.users.indexOf(u);
                        if (i >= 0) {
                          _repo.users[i] = u.copyWith(peran: r);
                        }
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: r == u.peran
                            ? AppColors.greenSoft
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadii.tile),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(r,
                                style: TextStyle(
                                    color: r == u.peran
                                        ? AppColors.greenInk
                                        : AppColors.ink,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (r == u.peran)
                            const Icon(IconsaxPlusBold.tick_circle,
                                size: 18, color: AppColors.greenInk),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Pressable(
                onTap: () {
                  setState(() {
                    final i = _repo.users.indexOf(u);
                    if (i >= 0) _repo.users[i] = u.copyWith(aktif: !u.aktif);
                  });
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                      u.aktif ? 'Nonaktifkan pengguna' : 'Aktifkan pengguna',
                      style: TextStyle(
                          color: u.aktif ? AppColors.loss : AppColors.greenInk,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tambah() {
    final nama = TextEditingController();
    final email = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Undang pengguna', style: numStyle(size: 16)),
                const SizedBox(height: 6),
                const Text('Peran awal: Staff. Bisa diubah setelah dibuat.',
                    style:
                        TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 16),
                _input(nama, 'Nama lengkap'),
                const SizedBox(height: 12),
                _input(email, 'Email kerja'),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: () {
                    final n = nama.text.trim();
                    if (n.isNotEmpty) {
                      setState(() => _repo.addUser(AppUser(
                          n,
                          email.text.trim().isEmpty
                              ? '-'
                              : email.text.trim(),
                          'Staff',
                          _repo.branches.first.nama)));
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Undang',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      nama.dispose();
      email.dispose();
    });
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
    final rows = _rows;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Pengguna',
              subtitle: '${_repo.users.where((u) => u.aktif).length} aktif',
              action: HeaderAction(
                  icon: IconsaxPlusBold.add,
                  label: 'Undang pengguna',
                  onTap: _tambah),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      for (final f in ['Semua', 'Aktif', 'Nonaktif'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Pressable(
                            onTap: () => setState(() => _filter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: kEaseOut,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _filter == f
                                    ? AppColors.ink
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                boxShadow:
                                    _filter == f ? null : AppShadows.soft,
                              ),
                              child: Text(f,
                                  style: TextStyle(
                                      color: _filter == f
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text('Tidak ada pengguna di filter ini.',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                      ),
                    )
                  else
                    for (final u in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: () => _aksi(u),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: u.aktif
                                      ? AppColors.greenSoft
                                      : AppColors.surfaceAlt,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(u.initials,
                                    style: numStyle(
                                        size: 14,
                                        color: u.aktif
                                            ? AppColors.greenInk
                                            : AppColors.muted)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(u.nama,
                                        style: numStyle(size: 14.5)),
                                    const SizedBox(height: 2),
                                    Text('${u.peran} · ${u.cabang}',
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (!u.aktif)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lossSoft,
                                    borderRadius: BorderRadius.circular(
                                        AppRadii.pill),
                                  ),
                                  child: const Text('Nonaktif',
                                      style: TextStyle(
                                          color: AppColors.loss,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 4),
                  const DemoNote(
                      text:
                          'Ketuk pengguna untuk ubah peran atau nonaktifkan. Tersimpan sementara.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
