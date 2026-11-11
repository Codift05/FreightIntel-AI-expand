import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/sparkline.dart';
import 'vendor_repository.dart';

/// Detail vendor: biaya, performa, rincian kategori (FR-VAN-01).
class VendorDetailScreen extends StatelessWidget {
  final Vendor v;
  const VendorDetailScreen(this.v, {super.key});

  @override
  Widget build(BuildContext context) {
    final total = v.rincian.fold<int>(0, (s, e) => s + e.jt);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(v.name, subtitle: '${v.kind} · ${v.city}'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _kpi('Shipment', '${v.shipments}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _kpi('Tepat waktu',
                              '${v.tepatWaktuPct.toStringAsFixed(0)}%')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Tren biaya 6 bulan', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    child: SizedBox(
                      height: 72,
                      child:
                          Sparkline(data: v.trend, color: AppColors.loss),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Rincian biaya', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < v.rincian.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: AppColors.line),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(v.rincian[i].kategori,
                                      style: const TextStyle(
                                          color: AppColors.ink,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                    total == 0
                                        ? '-'
                                        : '${(v.rincian[i].jt * 100 / total).round()}%',
                                    style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12)),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 72,
                                  child: Text('Rp ${v.rincian[i].jt} jt',
                                      textAlign: TextAlign.end,
                                      style: numStyle(size: 13)),
                                ),
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
            const Text('Biaya ke vendor ini',
                style: TextStyle(color: AppColors.onDark, fontSize: 12.5)),
            const SizedBox(height: 8),
            Text('Rp ${v.costJt} jt',
                style: numStyle(size: 32, color: Colors.white)),
            const SizedBox(height: 12),
            if (v.potensiHematJt > 0)
              Text(
                'Tarif ${v.selisihTarifPct.toStringAsFixed(0)}% di atas rata-rata. Potensi hemat Rp ${v.potensiHematJt} jt/bln.',
                style: const TextStyle(
                    color: AppColors.onDark, fontSize: 12.5, height: 1.45),
              )
            else
              const Text('Tarif setara atau di bawah rata-rata pasar.',
                  style: TextStyle(
                      color: AppColors.onDark, fontSize: 12.5, height: 1.45)),
          ],
        ),
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
