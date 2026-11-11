import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/sparkline.dart';
import 'customer_repository.dart';

/// Detail customer: KPI, tren 6 bulan, shipment terakhir (FR-CAN-01).
class CustomerDetailScreen extends StatelessWidget {
  final Customer c;
  const CustomerDetailScreen(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(c.name, subtitle: '${c.city} · sejak ${c.sejak}'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _kpi('Pendapatan', 'Rp ${c.revenueJt} jt')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _kpi('Shipment', '${c.shipments}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _kpi('Margin',
                              '${c.marginPct.toStringAsFixed(1)}%')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _kpi('Bayar tepat waktu',
                              '${c.tepatWaktuPct.toStringAsFixed(0)}%')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Tren laba 6 bulan', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    child: SizedBox(
                      height: 72,
                      child: Sparkline(
                        data: c.trend,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Shipment terakhir', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  if (c.recent.isEmpty)
                    const AppCard(
                      child: Text('Belum ada shipment tercatat.',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < c.recent.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                  height: 1, color: AppColors.line),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(c.recent[i].id,
                                            style: numStyle(size: 13.5)),
                                        const SizedBox(height: 2),
                                        Text(c.recent[i].route,
                                            style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text('Rp ${c.recent[i].profitJt} jt',
                                      style: numStyle(
                                          size: 13.5,
                                          color: AppColors.green)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const DemoNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Laba dari customer ini',
                style: TextStyle(color: AppColors.onDark, fontSize: 12.5)),
            const SizedBox(height: 8),
            Text('Rp ${c.profitJt} jt',
                style: numStyle(size: 32, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                _tag('Risiko bayar ${c.risiko.toLowerCase()}',
                    c.tepatWaktuPct >= 90
                        ? AppColors.greenBright
                        : c.tepatWaktuPct >= 75
                            ? AppColors.warning
                            : AppColors.loss),
              ],
            ),
          ],
        ),
      );

  Widget _tag(String text, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(text,
            style: TextStyle(
                color: c, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );

  Widget _kpi(String label, String value) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: numStyle(size: 20)),
          ],
        ),
      );
}
