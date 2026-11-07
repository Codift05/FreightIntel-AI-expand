import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu dasar: surface, radius 20, shadow lembut, tanpa border.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final List<BoxShadow>? shadow;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.shadow,
    this.radius = AppRadii.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ?? AppShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: box,
      ),
    );
  }
}

/// Kartu sorotan metrik utama (fill greenSoft). Satu per layar.
class HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final double progress; // 0..1
  final String progressLabel;

  const HighlightCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.progress = 0.0,
    this.progressLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.greenSoft,
      shadow: AppShadows.soft,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: labelStyle(color: AppColors.greenInk)),
                const SizedBox(height: 10),
                Text(value, style: numStyle(size: 30, color: AppColors.ink)),
                if (sub != null) ...[
                  const SizedBox(height: 4),
                  Text(sub!,
                      style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.green),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(progressLabel,
                    textAlign: TextAlign.center,
                    style: numStyle(size: 15, color: AppColors.greenInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile statistik: label kapital + angka besar tabular.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.ink,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: labelStyle())),
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: AppColors.greenSoft, shape: BoxShape.circle),
                  child: Icon(icon, size: 15, color: AppColors.greenInk),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: numStyle(size: 21, color: valueColor)),
        ],
      ),
    );
  }
}
