import 'package:flutter/material.dart';

/// Membungkus elemen pressable agar "terasa" ditekan: skala turun halus
/// (0.97) saat jari menyentuh, balik cepat saat lepas.
/// Rujukan: Emil Kowalski (design-eng) + HIG accessibility (label untuk SR).
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          // Tekan cepat (feedback instan), lepas sedikit lebih lembut.
          duration: Duration(milliseconds: _down ? 90 : 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
