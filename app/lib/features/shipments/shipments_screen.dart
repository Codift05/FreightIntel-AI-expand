import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text('Shipments',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _data.length,
              itemBuilder: (_, i) {
                final s = _data[i];
                final profit = s[5] as String;
                final ok = s[6] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s[0] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy)),
                      Text(s[1] as String,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(s[2] as String,
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.navy)),
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _kv('TYPE', s[3] as String, AppColors.navy),
                          _kv('REVENUE', s[4] as String, AppColors.navy),
                          _kv('PROFIT', profit,
                              ok ? AppColors.green : AppColors.loss),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: c, fontSize: 13)),
        ],
      );
}
