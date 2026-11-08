import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../notifications/notification_screen.dart';

typedef _PData = ({
  String hero,
  String profit,
  String sub,
  double prog,
  String pl,
  String rev,
  String revU,
  String cost,
  String costU,
  String piu,
  String piuU,
  String hut,
  String hutU,
});

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pc = PageController(initialPage: 1);
  static const _labels = ['Harian', 'Bulanan', 'Tahunan'];

  static const List<_PData> _periods = [
    (hero: 'Profit hari ini', profit: 'Rp 26 jt', sub: 'Margin 23,1% · 18 shipment', prog: 0.55, pl: '+9%', rev: 'Rp 112', revU: 'jt', cost: 'Rp 86', costU: 'jt', piu: 'Rp 48', piuU: 'jt', hut: 'Rp 120', hutU: 'jt'),
    (hero: 'Profit bulan ini', profit: 'Rp 789 jt', sub: 'Margin 24,6% · naik dari bulan lalu', prog: 0.62, pl: '+12%', rev: 'Rp 3,2', revU: 'M', cost: 'Rp 2,4', costU: 'M', piu: 'Rp 636', piuU: 'jt', hut: 'Rp 1,8', hutU: 'M'),
    (hero: 'Profit tahun ini', profit: 'Rp 9,2 M', sub: 'Margin 25,3% · 214 shipment', prog: 0.71, pl: '+18%', rev: 'Rp 38', revU: 'M', cost: 'Rp 28', costU: 'M', piu: 'Rp 7,1', piuU: 'M', hut: 'Rp 4,2', hutU: 'M'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _goto(int i) => _pc.animateToPage(i, duration: 320.ms, curve: kEaseOut);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _header(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PeriodChips(
                controller: _pc, items: _labels, onTap: _goto),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              allowImplicitScrolling: true, // pre-render tetangga -> swipe mulus
              itemCount: _periods.length,
              itemBuilder: (_, i) => _PeriodPage(_periods[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
        children: [
          Container(
            width: 46,
            height: 46,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
                color: AppColors.greenSoft, shape: BoxShape.circle),
            child: Image.asset(Illus.avatarOwner, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, Owner',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                Text('Ringkasan keuangan',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          Pressable(
            semanticLabel: 'Notifikasi',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft),
                  child: const Icon(IconsaxPlusBold.notification,
                      color: AppColors.ink, size: 20),
                ),
                Positioned(
                  right: 10,
                  top: 11,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                        color: AppColors.loss,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surface, width: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

/// Konten satu periode. Di-keep-alive agar swipe balik tak rebuild (anti-lag).
class _PeriodPage extends StatefulWidget {
  final _PData p;
  const _PeriodPage(this.p);
  @override
  State<_PeriodPage> createState() => _PeriodPageState();
}

class _PeriodPageState extends State<_PeriodPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = widget.p;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 112),
      children: [
        HighlightCard(
          label: p.hero,
          value: p.profit,
          sub: p.sub,
          progress: p.prog,
          progressLabel: p.pl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    label: 'Revenue',
                    value: p.rev,
                    unit: p.revU,
                    icon: IconsaxPlusBold.trend_up,
                    trend: const [2.4, 2.6, 2.5, 2.8, 2.9, 3.0, 3.2],
                    delta: '8,2%',
                    deltaUp: true,
                    deltaGood: true,
                    sparkColor: AppColors.green)),
            const SizedBox(width: 14),
            Expanded(
                child: StatTile(
                    label: 'Cost',
                    value: p.cost,
                    unit: p.costU,
                    valueColor: AppColors.loss,
                    icon: IconsaxPlusBold.trend_down,
                    trend: const [2.1, 2.2, 2.15, 2.3, 2.35, 2.3, 2.4],
                    delta: '3,1%',
                    deltaUp: true,
                    deltaGood: false,
                    sparkColor: AppColors.loss)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    label: 'Piutang',
                    value: p.piu,
                    unit: p.piuU,
                    icon: IconsaxPlusBold.receive_square,
                    trend: const [720, 700, 690, 672, 658, 645, 636],
                    delta: '4,0%',
                    deltaUp: false,
                    deltaGood: true,
                    sparkColor: AppColors.green)),
            const SizedBox(width: 14),
            Expanded(
                child: StatTile(
                    label: 'Hutang',
                    value: p.hut,
                    unit: p.hutU,
                    icon: IconsaxPlusBold.money_send,
                    trend: const [2.4, 2.3, 2.2, 2.1, 2.0, 1.9, 1.8],
                    delta: '6,0%',
                    deltaUp: false,
                    deltaGood: true,
                    sparkColor: AppColors.green)),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child:
                          Text('Revenue vs Cost', style: numStyle(size: 15))),
                  Text('6 bulan', style: labelStyle()),
                ],
              ),
              const SizedBox(height: 20),
              const _MiniBars(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Angka contoh, belum terhubung data.',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

/// Segmented control periode (gaya wondr): pill hijau geser mengikuti swipe.
class _PeriodChips extends StatelessWidget {
  final PageController controller;
  final List<String> items;
  final ValueChanged<int> onTap;
  const _PeriodChips(
      {required this.controller, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.soft,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final segW = c.maxWidth / items.length;
          return SizedBox(
            height: 38,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final page = (controller.hasClients &&
                        controller.positions.isNotEmpty &&
                        controller.page != null)
                    ? controller.page!.clamp(0.0, (items.length - 1).toDouble())
                    : controller.initialPage.toDouble();
                return Stack(
                  children: [
                    // Pill hijau geser mengikuti posisi swipe.
                    Positioned(
                      left: page * segW,
                      top: 0,
                      bottom: 0,
                      width: segW,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (i) {
                        final sel = (1 - (page - i).abs()).clamp(0.0, 1.0);
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(i),
                            child: Center(
                              child: Text(items[i],
                                  style: TextStyle(
                                      color: Color.lerp(
                                          AppColors.muted, Colors.white, sel),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Bar chart: label nilai + batang; bulan terakhir hijau.
class _MiniBars extends StatelessWidget {
  const _MiniBars();
  static const _h = [0.5, 0.35, 0.82, 0.45, 0.6, 0.95];
  static const _val = ['1,9', '1,4', '2,6', '1,8', '2,2', '3,2'];
  static const _months = ['06', '07', '08', '09', '10', '11'];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final active = i == 5;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_val[i],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.greenInk : AppColors.muted)),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  height: 14 + _h[i] * 96,
                  decoration: BoxDecoration(
                    color: active ? AppColors.green : AppColors.greenSoft,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_months[i], style: labelStyle().copyWith(fontSize: 11)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
