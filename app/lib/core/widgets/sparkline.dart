import 'package:flutter/material.dart';

/// Mini grafik tren (sparkline): garis + fill lembut di bawahnya.
/// Animasi tumbuh kiri→kanan saat muncul.
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.strokeWidth = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, t, _) => CustomPaint(
        painter: _SparkPainter(data, color, strokeWidth, t),
        size: Size.infinite,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;
  final double t; // 0..1 progress reveal

  _SparkPainter(this.data, this.color, this.strokeWidth, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final lo = data.reduce((a, b) => a < b ? a : b);
    final hi = data.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : (hi - lo);
    const pad = 3.0;
    final h = size.height - pad * 2;
    double px(int i) => size.width * i / (data.length - 1);
    double py(double v) => pad + h * (1 - (v - lo) / span);

    final line = Path()..moveTo(px(0), py(data[0]));
    for (var i = 1; i < data.length; i++) {
      line.lineTo(px(i), py(data[i]));
    }

    // Reveal kiri -> kanan.
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * t, size.height));

    // Fill lembut di bawah garis.
    final fill = Path.from(line)
      ..lineTo(px(data.length - 1), size.height)
      ..lineTo(px(0), size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.t != t || old.data != data || old.color != color;
}
