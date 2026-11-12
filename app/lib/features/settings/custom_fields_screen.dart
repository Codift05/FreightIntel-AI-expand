import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Kelola custom field tanpa ubah kode (FR-CF-01..04).
class CustomFieldsScreen extends StatefulWidget {
  const CustomFieldsScreen({super.key});

  @override
  State<CustomFieldsScreen> createState() => _CustomFieldsScreenState();
}

class _CustomFieldsScreenState extends State<CustomFieldsScreen> {
  final _repo = SettingsRepository.instance;
  String _target = kFieldTargets.first;

  List<CustomField> get _rows =>
      _repo.fields.where((f) => f.target == _target).toList();

  void _tambah() {
    final nama = TextEditingController();
    var tipe = FieldType.teks;
    var wajib = false;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Field baru di $_target', style: numStyle(size: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nama,
                    style: const TextStyle(
                        color: AppColors.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Nama field, mis. "Nomor segel"',
                      hintStyle: const TextStyle(
                          color: AppColors.muted, fontSize: 14),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.input),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipe data',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in FieldType.values)
                        Pressable(
                          onTap: () => setSheet(() => tipe = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              color: tipe == t
                                  ? AppColors.ink
                                  : AppColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(t.label,
                                style: TextStyle(
                                    color: tipe == t
                                        ? Colors.white
                                        : AppColors.muted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: wajib,
                    onChanged: (v) => setSheet(() => wajib = v),
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.ink,
                    title: const Text('Wajib diisi',
                        style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.pill)),
                    ),
                    onPressed: () {
                      final n = nama.text.trim();
                      if (n.isNotEmpty) {
                        setState(() => _repo.addCustomField(
                            CustomField(n, _target, tipe, wajib: wajib)));
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Tambah field',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(nama.dispose);
  }

  void _hapus(CustomField f) {
    setState(() => _repo.fields.remove(f));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Field "${f.nama}" dihapus.'),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: () => setState(() => _repo.fields.add(f)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Custom field',
              subtitle: '${_repo.fields.length} field di ${kFieldTargets.length} modul',
              action: HeaderAction(
                  icon: IconsaxPlusBold.add,
                  label: 'Tambah field',
                  onTap: _tambah),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final t in kFieldTargets)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Pressable(
                              onTap: () => setState(() => _target = t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                curve: kEaseOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _target == t
                                      ? AppColors.ink
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                  boxShadow:
                                      _target == t ? null : AppShadows.soft,
                                ),
                                child: Text(t,
                                    style: TextStyle(
                                        color: _target == t
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
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          const Icon(IconsaxPlusLinear.category,
                              size: 28, color: AppColors.muted),
                          const SizedBox(height: 10),
                          Text('Belum ada custom field di $_target.',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 13)),
                          const SizedBox(height: 14),
                          Pressable(
                            onTap: _tambah,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.lime,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                              child: const Text('Tambah field',
                                  style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < rows.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, color: AppColors.line),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(rows[i].nama,
                                                  style: const TextStyle(
                                                      color: AppColors.ink,
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            if (rows[i].wajib) ...[
                                              const SizedBox(width: 6),
                                              const Text('wajib',
                                                  style: TextStyle(
                                                      color: AppColors.loss,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                            '${rows[i].tipe.label}${rows[i].bisaDicari ? ' · bisa dicari' : ''}',
                                            style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Pressable(
                                    scale: 0.9,
                                    semanticLabel: 'Hapus ${rows[i].nama}',
                                    onTap: () => _hapus(rows[i]),
                                    child: const SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Icon(IconsaxPlusLinear.trash,
                                          size: 17, color: AppColors.muted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  const DemoNote(
                      text:
                          'Field yang ditambah di sini akan muncul di form modul terkait saat backend siap.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
