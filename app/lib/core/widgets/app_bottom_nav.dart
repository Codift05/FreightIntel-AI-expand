import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// Bottom nav kapsul mengambang. Slot sama rata. Item aktif ditandai lewat
/// bobot ikon (filled vs outline) + warna + garis indikator kecil, bukan
/// kotak/blob berwarna. Perbedaan bukan hanya warna (aksesibel).
class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const AppBottomNav({
    super.key,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              _item(0, IconsaxPlusBold.element_3,
                  IconsaxPlusLinear.element_3, 'Dashboard'),
              _item(1, IconsaxPlusBold.truck,
                  IconsaxPlusLinear.truck, 'Shipments'),
              _item(2, IconsaxPlusBold.empty_wallet,
                  IconsaxPlusLinear.empty_wallet, 'Finance'),
              _item(3, IconsaxPlusBold.lamp_charge,
                  IconsaxPlusLinear.lamp_charge, 'Insight'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData activeIcon, IconData idleIcon, String label) {
    final active = i == index;
    return Expanded(
      child: Pressable(
        semanticLabel: label,
        onTap: () {
          if (!active) HapticFeedback.selectionClick();
          onSelect(i);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 220),
              curve: kEaseOut,
              child: Icon(active ? activeIcon : idleIcon,
                  size: 23, color: active ? AppColors.green : AppColors.muted),
            ),
            const SizedBox(height: 5),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active ? AppColors.greenInk : AppColors.muted)),
            const SizedBox(height: 5),
            // Garis indikator kecil (menandai tab aktif, bukan dekorasi).
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: kEaseOut,
              width: active ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
