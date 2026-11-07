import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('Finance', style: numStyle(size: 22)),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: StatTile(label: 'REVENUE', value: 'Rp 3,2 M')),
              SizedBox(width: 12),
              Expanded(
                  child: StatTile(
                      label: 'COST',
                      value: 'Rp 2,4 M',
                      valueColor: AppColors.loss)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: StatTile(
                      label: 'PROFIT',
                      value: 'Rp 789 jt',
                      valueColor: AppColors.green)),
              SizedBox(width: 12),
              Expanded(child: StatTile(label: 'MARGIN', value: '24,6%')),
            ],
          ),
          const SizedBox(height: 18),
          Text('Invoice terbaru', style: numStyle(size: 15)),
          const SizedBox(height: 10),
          ..._inv.map((e) {
            final paid = e[4] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                shadow: AppShadows.soft,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e[0] as String, style: numStyle(size: 14)),
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
                            style: numStyle(size: 14, color: AppColors.green)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: paid
                                ? AppColors.greenSoft
                                : AppColors.lossSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(e[3] as String,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: paid
                                      ? AppColors.greenInk
                                      : AppColors.loss)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          const Text('Angka contoh — belum terhubung data.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
