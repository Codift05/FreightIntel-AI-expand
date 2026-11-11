import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

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

/// Kartu sorotan metrik utama (ikut Reference Design):
/// - Bila [bannerLeft] diisi: kartu dua tingkat dengan pita atas Lime `#D3F85A`
///   + watermark lingkaran konsentris dan bodi gelap `#141414`.
/// - Bila [bannerLeft] kosong: kartu gelap ringkas dengan pill delta di kanan.
class HighlightCard extends StatefulWidget {
  final String label;
  final String value; // ringkas, mis. "Rp 26 jt"
  final String? valueFull; // detail, mis. "Rp 26.450.000" (tap untuk lihat)
  final String? sub;
  final String? delta; // mis. "+12%"
  final bool deltaUp;
  final String? bannerLeft;
  final String? bannerRight;

  const HighlightCard({
    super.key,
    required this.label,
    required this.value,
    this.valueFull,
    this.sub,
    this.delta,
    this.deltaUp = true,
    this.bannerLeft,
    this.bannerRight,
  });

  @override
  State<HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<HighlightCard> {
  bool _hidden = false;
  bool _detailed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final shown = _hidden
        ? 'Rp ••••••'
        : (_detailed && w.valueFull != null ? w.valueFull! : w.value);
    final hasBanner = w.bannerLeft != null;
    final deltaColor = w.deltaUp
        ? (hasBanner ? AppColors.lime : AppColors.greenBright)
        : AppColors.loss;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
              color: AppColors.inkDeep.withValues(alpha: 0.26),
              blurRadius: 26,
              offset: const Offset(0, 14),
              spreadRadius: -10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasBanner)
            CustomPaint(
              painter: const _RingsPainter(
                center: Alignment(-0.85, -0.4),
                color: Color(0x18141414),
                maxRadius: 56,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(AppRadii.card - 4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        w.bannerLeft!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (w.bannerRight != null)
                      Text(
                        w.bannerRight!,
                        style: TextStyle(
                          color: AppColors.ink.withValues(alpha: 0.78),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          CustomPaint(
            painter: const _RingsPainter(
              center: Alignment(0.72, 0.65),
              color: Color(0x14FFFFFF),
              maxRadius: 76,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (w.valueFull != null && !_hidden)
                                    ? () =>
                                        setState(() => _detailed = !_detailed)
                                    : null,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(shown,
                                      maxLines: 1,
                                      style: numStyle(
                                          size: 30, color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Pressable(
                              semanticLabel: _hidden
                                  ? 'Tampilkan nilai'
                                  : 'Sembunyikan nilai',
                              onTap: () => setState(() => _hidden = !_hidden),
                              child: Icon(
                                  _hidden
                                      ? IconsaxPlusLinear.eye_slash
                                      : IconsaxPlusLinear.eye,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  size: 18),
                            ),
                          ],
                        ),
                      ),
                      if (w.delta != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: hasBanner ? 6 : 10,
                              vertical: hasBanner ? 2 : 5),
                          decoration: hasBanner
                              ? null
                              : BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  w.deltaUp
                                      ? Icons.arrow_drop_up_rounded
                                      : Icons.arrow_drop_down_rounded,
                                  size: 20,
                                  color: deltaColor),
                              Text(w.delta!,
                                  style: TextStyle(
                                      color: deltaColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (w.sub != null) ...[
                    const SizedBox(height: 6),
                    Text(w.sub!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.52),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Watermark lingkaran konsentris halus pada kartu gelap / pita lime
/// sesuai motif di Reference Design.
class _RingsPainter extends CustomPainter {
  final Alignment center;
  final Color color;
  final double maxRadius;

  const _RingsPainter({
    required this.center,
    required this.color,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = center.alongSize(size);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    for (final factor in const [0.32, 0.62, 1.0]) {
      canvas.drawCircle(c, maxRadius * factor, p);
    }
    canvas.drawCircle(c, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.center != center || old.color != color || old.maxRadius != maxRadius;
}

/// Tile statistik gaya Reference Design: label abu kecil, angka besar,
/// lalu delta berwarna + keterangan. Tanpa ikon/sparkline (ringkas, tak overflow).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;

  /// Delta opsional, mis. "8,2%". [deltaGood] menentukan warna (hijau/merah).
  final String? delta;
  final bool deltaUp;
  final bool deltaGood;
  final String deltaNote;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor = AppColors.ink,
    this.delta,
    this.deltaUp = true,
    this.deltaGood = true,
    this.deltaNote = 'vs lalu',
  });

  @override
  Widget build(BuildContext context) {
    final dc = deltaGood ? AppColors.green : AppColors.loss;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: numStyle(size: 19, color: valueColor)),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(deltaUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 15, color: dc),
                Text(delta!,
                    style: TextStyle(
                        color: dc, fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(deltaNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
