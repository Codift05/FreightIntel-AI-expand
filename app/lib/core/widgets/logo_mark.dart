import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Marka logo FreightIntel AI: rute biru tua + satu node hijau di tujuan.
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RoutePainter()),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 256.0;
    final line = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(52 * s, 192 * s)
      ..lineTo(102 * s, 156 * s)
      ..lineTo(154 * s, 138 * s)
      ..lineTo(204 * s, 92 * s);
    canvas.drawPath(path, line);
    canvas.drawCircle(
      Offset(204 * s, 92 * s),
      19 * s,
      Paint()..color = AppColors.green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark "FreightIntel AI" (AI hijau).
class Wordmark extends StatelessWidget {
  final double fontSize;
  const Wordmark({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.navy,
        ),
        children: const [
          TextSpan(text: 'FreightIntel'),
          TextSpan(text: ' AI', style: TextStyle(color: AppColors.green)),
        ],
      ),
    );
  }
}
