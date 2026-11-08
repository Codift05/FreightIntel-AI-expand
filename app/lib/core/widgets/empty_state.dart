import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Empty state ber-ilustrasi (muncul saat tidak ada data).
class EmptyState extends StatelessWidget {
  final String asset;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.asset,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(asset, height: 180, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text(title, style: numStyle(size: 17), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
