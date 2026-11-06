import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  static const _inv = [
    ['INV/2610/003', 'Handling · 2026-10-20', '+Rp 142 jt', 'PAID', true],
    ['INV/2610/017', 'Ocean Freight · 2026-10-13', '+Rp 298 jt', 'PAID', true],
    ['INV/2610/009', 'Handling · 2026-10-04', '+Rp 76 jt', 'UNPAID', false],
    ['INV/2609/013', 'Air Freight · 2026-09-10', '+Rp 263 jt', 'PAID', true],
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          const Text('Finance',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 14),
          Row(
            children: [
              _tile('REVENUE', 'Rp 3,2 M', AppColors.navy),
              const SizedBox(width: 10),
              _tile('COST', 'Rp 2,4 M', AppColors.loss),
              const SizedBox(width: 10),
              _tile('PROFIT', 'Rp 789 jt', AppColors.green),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Invoice terbaru',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.navy)),
          const SizedBox(height: 8),
          ..._inv.map((e) {
            final paid = e[4] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e[0] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        Text(e[1] as String,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(e[2] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: paid
                              ? AppColors.green.withValues(alpha: 0.12)
                              : AppColors.loss.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(e[3] as String,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: paid ? AppColors.green : AppColors.loss)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          const Text('Angka contoh — belum terhubung data.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _tile(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: color, fontSize: 15)),
            ],
          ),
        ),
      );
}
