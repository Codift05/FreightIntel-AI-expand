import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// Header baku layar sekunder: tombol kembali, judul, subjudul, aksi opsional.
/// Dipakai semua layar yang dibuka lewat push (bukan tab).
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const ScreenHeader(this.title, {super.key, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 10),
      child: Row(
        children: [
          Pressable(
            semanticLabel: 'Kembali',
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(IconsaxPlusLinear.arrow_left,
                  size: 22, color: AppColors.ink),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: numStyle(size: 18)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Tombol ikon bulat untuk slot [ScreenHeader.action].
class HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const HeaderAction(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: AppColors.surface, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

/// Catatan jujur bahwa angka di layar ini contoh.
class DemoNote extends StatelessWidget {
  final String text;
  const DemoNote(
      {super.key, this.text = 'Angka contoh, belum terhubung data.'});

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4));
}
