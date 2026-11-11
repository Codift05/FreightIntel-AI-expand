import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/illustrations.dart';

/// Pusat notifikasi in-app (PRD FR-NOT-01..05):
/// - FR-NOT-01: Reminder invoice jatuh tempo (piutang)
/// - FR-NOT-02: Reminder hutang vendor
/// - FR-NOT-03: Peringatan shipment delay
/// - FR-NOT-04: Peringatan kas rendah
/// - FR-NOT-05: Pusat notifikasi in-app (baca/belum baca)
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _items = <_Notif>[
    _Notif(
      IconsaxPlusBold.receipt_item,
      AppColors.warning,
      'Invoice jatuh tempo',
      'Piutang INV/2610/009 (Rp 76 jt · PT Garuda Trading) jatuh tempo 3 hari lagi.',
      '2 jam lalu',
    ),
    _Notif(
      IconsaxPlusBold.money_send,
      AppColors.loss,
      'Hutang vendor jatuh tempo',
      'Tagihan Meratus Line untuk FI-2610-03E8 mendekati tenggat pembayaran.',
      '5 jam lalu',
    ),
    _Notif(
      IconsaxPlusBold.wallet_remove,
      AppColors.loss,
      'Peringatan kas operasional',
      'Cadangan kas cabang Surabaya mendekati batas minimum minggu ini.',
      '8 jam lalu',
    ),
    _Notif(
      IconsaxPlusBold.truck,
      AppColors.ink,
      'Shipment tertahan (delay)',
      'FI-2610-04FA tertahan di pemeriksaan Customs pelabuhan tujuan.',
      '1 hari lalu',
    ),
    _Notif(
      IconsaxPlusBold.wallet_money,
      AppColors.greenInk,
      'Pembayaran masuk',
      'INV/2610/017 telah dilunasi penuh (Rp 298 jt).',
      '2 hari lalu',
      read: true,
    ),
  ];

  bool get _hasUnread => _items.any((e) => !e.read);

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.read = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((e) => !e.read).length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Notifikasi',
              subtitle: unreadCount > 0
                  ? '$unreadCount belum dibaca'
                  : 'Semua sudah dibaca',
              action: _hasUnread
                  ? HeaderAction(
                      icon: IconsaxPlusLinear.tick_circle,
                      label: 'Baca semua',
                      onTap: _markAllRead,
                    )
                  : null,
            ),
            Expanded(
              child: _items.isEmpty
                  ? const EmptyState(
                      asset: Illus.emptyFinance,
                      title: 'Belum ada notifikasi',
                      message:
                          'Pengingat piutang, hutang vendor, kas, dan shipment akan tampil di sini.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _items.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == _items.length) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: DemoNote(
                              text:
                                  'Ketuk kartu notifikasi untuk menandai sudah dibaca.',
                            ),
                          );
                        }
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
                                                      : FontWeight.w700)),
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
                                            color: AppColors.inkSoft,
                                            fontSize: 13,
                                            height: 1.35)),
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
            ),
          ],
        ),
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
