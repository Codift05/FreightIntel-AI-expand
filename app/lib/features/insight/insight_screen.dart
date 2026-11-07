import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                  color: AppColors.greenSoft, shape: BoxShape.circle),
              child: const Icon(Icons.insights_rounded,
                  color: AppColors.greenInk, size: 34),
            ),
            const SizedBox(height: 18),
            Text('Insight', style: numStyle(size: 20)),
            const SizedBox(height: 8),
            const Text(
              'Analisis keuangan & operasional otomatis (tren, penyebab, '
              'vendor termahal, prediksi) langsung dari data perusahaan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Text('Segera hadir',
                  style: labelStyle().copyWith(
                      color: AppColors.greenInk, letterSpacing: 0)),
            ),
          ],
        ),
      ),
    );
  }
}
