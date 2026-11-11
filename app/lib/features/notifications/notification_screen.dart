import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/illustrations.dart';

/// Pusat notifikasi in-app (PRD FR-NOT-05). Data demo; tap untuk tandai dibaca.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _items = <_Notif>[
    _Notif(IconsaxPlusBold.receipt_item, AppColors.warning,
        'Invoice jatuh tempo', 'INV/2610/009 jatuh tempo 3 hari lagi.', '2 jam'),
    _Notif(IconsaxPlusBold.money_send, AppColors.loss,
        'Hutang vendor', 'Pembayaran ke CV Mitra Laut mendekati tenggat.', '5 jam'),
    _Notif(IconsaxPlusBold.truck, AppColors.ink,
        'Shipment delay', 'FI-2610-04FA tertahan di Customs.', '1 hari'),
    _Notif(IconsaxPlusBold.wallet_money, AppColors.greenInk,
        'Pembayaran masuk', 'INV/2610/017 telah lunas (Rp 298 jt).', '2 hari',
        read: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifikasi', style: numStyle(size: 17))),
      body: _items.isEmpty
          ? const EmptyState(
              asset: Illus.emptyFinance,
              title: 'Belum ada notifikasi',
              message: 'Pengingat invoice, hutang, dan shipment akan tampil di sini.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = _items[i];
                return AppCard(
                  shadow: AppShadows.soft,
                  onTap: () => setState(() => n.read = true),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                            color: n.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle),
                        child: Icon(n.icon, size: 19, color: n.color),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: numStyle(size: 14).copyWith(
                                          fontWeight: n.read
                                              ? FontWeight.w600
                                              : FontWeight.w800)),
                                ),
                                if (!n.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: AppColors.green,
                                        shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(n.body,
                                style: const TextStyle(
                                    color: AppColors.inkSoft, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(n.time, style: labelStyle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title, body, time;
  bool read;
  _Notif(this.icon, this.color, this.title, this.body, this.time,
      {this.read = false});
}
