import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  static const _data = [
    ['FI-2610-E1D5', 'PT Garuda Trading', 'Jakarta → Rotterdam', 'Trucking', 'Rp 142 jt', 'Rp 27 jt', true],
    ['FI-2610-5458', 'PT Garuda Trading', 'Singapore → Surabaya', 'Air Freight', 'Rp 298 jt', 'Rp 138 jt', true],
    ['FI-2610-60C4', 'PT Astra Export', 'Jakarta → Tokyo', 'Trucking', 'Rp 76 jt', '-Rp 60 jt', false],
    ['FI-2609-2336', 'PT Garuda Trading', 'Hamburg → Jakarta', 'Air Freight', 'Rp 263 jt', 'Rp 93 jt', true],
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('Shipments', style: numStyle(size: 22)),
          const SizedBox(height: 14),
          ..._data.map((s) {
            final ok = s[6] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s[0] as String, style: numStyle(size: 15)),
                    Text(s[1] as String,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(s[2] as String,
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.ink))),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.line),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _kv('TYPE', s[3] as String, AppColors.ink),
                        _kv('REVENUE', s[4] as String, AppColors.ink),
                        _kv('PROFIT', s[5] as String,
                            ok ? AppColors.green : AppColors.loss),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: labelStyle().copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: c, fontSize: 13)),
        ],
      );
}
