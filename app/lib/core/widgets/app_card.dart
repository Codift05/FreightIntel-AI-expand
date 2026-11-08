import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../illustrations.dart';
import 'sparkline.dart';

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
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(Illus.patternRoutes,
                fit: BoxFit.cover, alignment: Alignment.centerRight),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle(color: AppColors.inkSoft)),
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: kEaseOut,
                    builder: (_, value, __) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.green),
                      strokeCap: StrokeCap.round,
                    ),
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
  final String? unit;
  final Color valueColor;
  final IconData? icon;

  /// Data tren (opsional). Jika diisi, tampil delta chip + sparkline.
  final List<double>? trend;
  final String? delta;
  final bool deltaUp;
  final bool deltaGood;
  final Color? sparkColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor = AppColors.ink,
    this.icon,
    this.trend,
    this.delta,
    this.deltaUp = true,
    this.deltaGood = true,
    this.sparkColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: labelStyle())),
              if (icon != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: AppColors.greenSoft, shape: BoxShape.circle),
                  child: Icon(icon, size: 17, color: AppColors.greenInk),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    style: numStyle(size: 22, color: valueColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          if (trend != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (delta != null) _deltaChip(),
                const Spacer(),
                SizedBox(
                  width: 68,
                  height: 30,
                  child: Sparkline(
                      data: trend!, color: sparkColor ?? AppColors.green),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _deltaChip() {
    final c = deltaGood ? AppColors.greenInk : AppColors.loss;
    final bg = deltaGood ? AppColors.greenSoft : AppColors.lossSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(deltaUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 12, color: c),
          const SizedBox(width: 2),
          Text(delta!,
              style: TextStyle(
                  color: c, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
