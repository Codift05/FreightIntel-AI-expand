import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';

/// Ikon moda pengiriman: glyph vektor dalam kotak netral.
///
/// Menggantikan disc ilustrasi raster yang pecah di ukuran kecil dan memakai
/// hijau sebagai dekorasi (hijau dicadangkan untuk arti data, lihat DESIGN.md).
class ModeIcon extends StatelessWidget {
  final String type;
  final double size;
  const ModeIcon(this.type, {super.key, this.size = 46});

  static IconData glyph(String type) => switch (type) {
        'Ocean Freight' => IconsaxPlusBold.ship,
        'Air Freight' => IconsaxPlusBold.airplane,
        'Handling' => IconsaxPlusBold.box,
        _ => IconsaxPlusBold.truck_fast,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(glyph(type), size: size * 0.46, color: AppColors.ink),
    );
  }
}
