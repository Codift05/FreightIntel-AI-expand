import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/illustrations.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/mode_icon.dart';
import '../../core/widgets/pressable.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';
import '../settings/settings_repository.dart';
import '../settings/settings_screen.dart';
import '../shipments/shipment_detail_screen.dart';
import '../shipments/shipment_repository.dart';

typedef _PData = ({
  String name,
  String dateLabel,
  String hero,
  String profit,
  String profitFull,
  String sub,
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

  final List<_PData> _periods = List.of(_defaultPeriods);
  Shipment _featured = _defaultFeatured;

  static const _defaultFeatured = Shipment(
    'FI-2610-03E8',
    'PT Garuda Trading',
    'Jakarta → Rotterdam',
    'Ocean Freight',
    'Rp 80 jt',
    'Rp 20 jt',
    true,
    'Booking',
  );

  static const List<_PData> _defaultPeriods = [
    (
      name: 'Harian',
      dateLabel: '9 Nov 2026',
      hero: 'Laba bersih hari ini',
      profit: 'Rp 26 jt',
      profitFull: 'Rp 26.450.000',
      sub: 'Margin 23,1% · 18 shipment',
      pl: '9,4%',
      rev: 'Rp 112',
      revU: 'jt',
      cost: 'Rp 86',
      costU: 'jt',
      piu: 'Rp 48',
      piuU: 'jt',
      hut: 'Rp 120',
      hutU: 'jt',
    ),
    (
      name: 'Bulanan',
      dateLabel: 'November 2026',
      hero: 'Laba bersih bulan ini',
      profit: 'Rp 789 jt',
      profitFull: 'Rp 789.300.000',
      sub: 'Margin 24,6% · 128 shipment',
      pl: '14,3%',
      rev: 'Rp 3,2',
      revU: 'M',
      cost: 'Rp 2,4',
      costU: 'M',
      piu: 'Rp 636',
      piuU: 'jt',
      hut: 'Rp 1,8',
      hutU: 'M',
    ),
    (
      name: 'Tahunan',
      dateLabel: 'Tahun 2026',
      hero: 'Laba bersih tahun ini',
      profit: 'Rp 9,2 M',
      profitFull: 'Rp 9.214.000.000',
      sub: 'Margin 25,3% · 214 shipment',
      pl: '18,1%',
      rev: 'Rp 38',
      revU: 'M',
      cost: 'Rp 28',
      costU: 'M',
      piu: 'Rp 7,1',
      piuU: 'M',
      hut: 'Rp 4,2',
      hutU: 'M',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveSummary();
  }

  /// Periode UI -> nilai yang dimengerti backend (`daily|monthly|yearly`).
  static const _periodApi = ['daily', 'monthly', 'yearly'];

  /// false = angka yang tampil berasal dari data contoh, bukan server.
  bool _live = false;

  Future<void> _loadLiveSummary() async {
    // Muat ketiga periode sekaligus supaya swipe Harian/Bulanan/Tahunan
    // menampilkan angka server, bukan hanya Bulanan.
    for (var i = 0; i < _periodApi.length; i++) {
      await _loadPeriod(i);
    }
    if (mounted) setState(() => _live = ApiClient.instance.lastCallOnline);
  }

  Future<void> _loadPeriod(int idx) async {
    final res = await ApiClient.instance
        .get('/dashboard', query: {'period': _periodApi[idx]});
    if (!mounted || res is! Map<String, dynamic>) return;
    final kpis = res['metrics'];
    final feat = res['featuredShipment'];
    setState(() {
      if (feat is Map<String, dynamic>) {
        _featured = Shipment.fromJson(feat);
      }
      if (kpis is Map<String, dynamic>) {
        final base = _periods[idx];
        final netJt = (kpis['profitJt'] as num?)?.toInt() ?? 789;
        final revJt = (kpis['revenueJt'] as num?)?.toInt() ?? 3200;
        final costJt = (kpis['costJt'] as num?)?.toInt() ?? 2400;
        final arJt = (kpis['receivablesJt'] as num?)?.toInt() ?? 636;
        final apJt = (kpis['payablesJt'] as num?)?.toInt() ?? 1800;
        final margin = (kpis['marginPct'] as num?)?.toDouble() ?? 24.6;
        final activeShp =
            (res['activeShipmentsCount'] as num?)?.toInt() ?? 20;
        _periods[idx] = (
          name: base.name,
          dateLabel: base.dateLabel,
          hero: base.hero,
          profit: 'Rp $netJt jt',
          profitFull: 'Rp ${netJt * 1000}.000',
          sub:
              'Margin ${margin.toStringAsFixed(1).replaceAll('.', ',')}% · $activeShp shipment',
          pl: base.pl,
          rev: revJt >= 1000
              ? 'Rp ${(revJt / 1000).toStringAsFixed(1).replaceAll('.', ',')}'
              : 'Rp $revJt',
          revU: revJt >= 1000 ? 'M' : 'jt',
          cost: costJt >= 1000
              ? 'Rp ${(costJt / 1000).toStringAsFixed(1).replaceAll('.', ',')}'
              : 'Rp $costJt',
          costU: costJt >= 1000 ? 'M' : 'jt',
          piu: 'Rp $arJt',
          piuU: 'jt',
          hut: apJt >= 1000
              ? 'Rp ${(apJt / 1000).toStringAsFixed(1).replaceAll('.', ',')}'
              : 'Rp $apJt',
          hutU: apJt >= 1000 ? 'M' : 'jt',
        );
      }
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _goto(int i) => _pc.animateToPage(i, duration: 320.ms, curve: kEaseOut);

  void _openProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                        color: AppColors.greenSoft, shape: BoxShape.circle),
                    child: Image.asset(Illus.avatarOwner, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Owner · ${SettingsRepository.instance.active.nama}',
                            style: numStyle(size: 15)),
                        const SizedBox(height: 2),
                        const Text('Sesi aktif',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Pressable(
                semanticLabel: 'Pengaturan',
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                  if (mounted) _loadLiveSummary();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadii.tile),
                  ),
                  child: const Row(
                    children: [
                      Icon(IconsaxPlusLinear.setting_2,
                          size: 19, color: AppColors.ink),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pengaturan',
                                style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text(
                                'Perusahaan, cabang, pengguna, custom field',
                                style: TextStyle(
                                    color: AppColors.muted, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Icon(IconsaxPlusLinear.arrow_right_3,
                          size: 16, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.inkDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(IconsaxPlusLinear.logout, size: 18),
                label: const Text('Keluar dari sesi demo',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PeriodChips(
                controller: _pc, items: _labels, onTap: _goto),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              allowImplicitScrolling: true,
              itemCount: _periods.length,
              itemBuilder: (_, i) =>
                  _PeriodPage(_periods[i], featured: _featured),
            ),
          ),
        ],
      ),
    );
  }

  /// Header 1 baris gaya Reference Design ("Hello, Jonathan!" + lonceng + avatar).
  Widget _header(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500),
                    children: [
                      const TextSpan(text: 'Halo, '),
                      TextSpan(
                        text: 'Owner!',
                        style: numStyle(size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                if (_live)
                  const Text('Ringkasan keuangan kargo',
                      style: TextStyle(color: AppColors.muted, fontSize: 12.5))
                else
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.warning, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('Angka contoh, belum terhubung server',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12.5)),
                    ],
                  ),
              ],
            ),
          ),
          Pressable(
            semanticLabel: 'Notifikasi',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(IconsaxPlusLinear.notification,
                      color: AppColors.ink, size: 21),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
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
          ),
          const SizedBox(width: 10),
          Pressable(
            semanticLabel: 'Menu akun & keluar',
            onTap: () => _openProfileSheet(context),
            child: Container(
              width: 42,
              height: 42,
              clipBehavior: Clip.antiAlias,
              // Tanpa border putih: di atas bg abu #EFF1F3 cincin putih terbaca
              // sebagai halo yang janggal. Latar aset = greenSoft, jadi menyatu.
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(Illus.avatarOwner, fit: BoxFit.cover),
            ),
          ),
        ],
      );
}

/// Konten satu periode. Di-keep-alive agar swipe balik tak rebuild (anti-lag).
class _PeriodPage extends StatefulWidget {
  final _PData p;
  final Shipment featured;
  const _PeriodPage(this.p, {required this.featured});
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
    final feat = widget.featured;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 116),
      children: [
        HighlightCard(
          bannerLeft: 'Portofolio Laba',
          bannerRight: p.dateLabel,
          label: p.hero,
          value: p.profit,
          valueFull: p.profitFull,
          sub: p.sub,
          delta: p.pl,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    label: 'Pendapatan',
                    value: p.rev,
                    unit: p.revU,
                    delta: '8,2%',
                    deltaUp: true,
                    deltaGood: true,
                    deltaNote: '7 hari terakhir')),
            const SizedBox(width: 14),
            Expanded(
                child: StatTile(
                    label: 'Biaya',
                    value: p.cost,
                    unit: p.costU,
                    valueColor: AppColors.loss,
                    delta: '3,1%',
                    deltaUp: true,
                    deltaGood: false,
                    deltaNote: '7 hari terakhir')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    label: 'Piutang',
                    value: p.piu,
                    unit: p.piuU,
                    delta: '4,0%',
                    deltaUp: false,
                    deltaGood: true,
                    deltaNote: 'vs bulan lalu')),
            const SizedBox(width: 14),
            Expanded(
                child: StatTile(
                    label: 'Hutang',
                    value: p.hut,
                    unit: p.hutU,
                    delta: '6,0%',
                    deltaUp: false,
                    deltaGood: true,
                    deltaNote: 'vs bulan lalu')),
          ],
        ),
        const SizedBox(height: 16),
        const _InteractiveTrendCard(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: Text('Sorotan Pengiriman', style: numStyle(size: 16))),
            Pressable(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ShipmentDetailScreen(feat)),
              ),
              child: const Text('Lihat detail',
                  style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FeaturedShipmentNote(
          shipment: feat,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ShipmentDetailScreen(feat)),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Angka contoh, belum terhubung data.',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

/// Kartu berita/sorotan bawah Dashboard mengikuti "Recent Market News" di
/// layar tengah Reference Design.
class _FeaturedShipmentNote extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const _FeaturedShipmentNote({required this.shipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: numStyle(size: 15),
                    children: [
                      TextSpan(text: '${shipment.id} '),
                      TextSpan(
                        text: '(${shipment.client})',
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              ModeIcon(shipment.type, size: 34),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rute ${shipment.route} (${shipment.type}) mencatat laba kotor ${shipment.profit} dari pendapatan ${shipment.revenue}.',
            style: const TextStyle(
                color: AppColors.inkSoft, fontSize: 13, height: 1.4),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            children: [
              const Text('9 Nov 2026',
                  style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(shipment.status,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Segmented control periode tanpa track dengan pill aktif gelap mengikuti swipe.
class _PeriodChips extends StatelessWidget {
  final PageController controller;
  final List<String> items;
  final ValueChanged<int> onTap;
  const _PeriodChips(
      {required this.controller, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final segW = c.maxWidth / items.length;
        return SizedBox(
          height: 36,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final page = (controller.hasClients &&
                      controller.positions.isNotEmpty &&
                      controller.page != null)
                  ? controller.page!.clamp(0.0, (items.length - 1).toDouble())
                  : controller.initialPage.toDouble();
              return Stack(
                children: [
                  Positioned(
                    left: page * segW + 6,
                    top: 0,
                    bottom: 0,
                    width: segW - 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.inkDeep,
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
    );
  }
}

/// Grafik tren interaktif gaya layar kanan Reference Design:
/// kurva halus + crosshair garis putus-putus + tooltip gelap berisi
/// Pendapatan & Biaya per bulan (tap bulan untuk ganti sorotan).
class _InteractiveTrendCard extends StatefulWidget {
  const _InteractiveTrendCard();

  @override
  State<_InteractiveTrendCard> createState() => _InteractiveTrendCardState();
}

class _InteractiveTrendCardState extends State<_InteractiveTrendCard> {
  static const _months = ['Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov'];
  static const _rev = [1.9, 2.4, 1.8, 2.6, 2.2, 3.2];
  static const _cost = [1.4, 1.8, 1.5, 1.9, 1.7, 2.4];
  int _selected = 4; // default Okt (seperti posisi crosshair di Reference Design)

  @override
  Widget build(BuildContext context) {
    final revStr = 'Rp ${_rev[_selected].toStringAsFixed(1).replaceAll('.', ',')} M';
    final costStr = 'Rp ${_cost[_selected].toStringAsFixed(1).replaceAll('.', ',')} M';
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Tren Pendapatan & Biaya',
                      style: numStyle(size: 15))),
              Text('Ketuk bulan', style: labelStyle().copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 196,
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) {
                          final step = box.maxWidth / _months.length;
                          final idx = (d.localPosition.dx / step)
                              .floor()
                              .clamp(0, _months.length - 1);
                          setState(() => _selected = idx);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ReferenceChartPainter(
                                  values: _rev,
                                  selectedIndex: _selected,
                                ),
                              ),
                            ),
                            Positioned(
                              left: (_selected <= 2) ? 8 : null,
                              right: (_selected > 2) ? 38 : null,
                              bottom: 28,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B2D31),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppShadows.soft,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _tooltipRow(
                                        'Masuk', true, revStr, AppColors.greenBright),
                                    const SizedBox(height: 5),
                                    _tooltipRow(
                                        'Biaya', false, costStr, AppColors.loss),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('3,5M',
                        style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('3,0M',
                        style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('2,5M',
                        style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('2,0M',
                        style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('1,5M',
                        style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 34),
            child: Row(
              children: List.generate(_months.length, (i) {
                final active = i == _selected;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selected = i),
                    child: Center(
                      child: Text(
                        _months[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w500,
                          color: active ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tooltipRow(String label, bool up, String val, Color arrowColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          child: Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500)),
        ),
        Icon(up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            size: 16, color: arrowColor),
        const SizedBox(width: 6),
        Text(val,
            style: numStyle(
                size: 12, weight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}

class _ReferenceChartPainter extends CustomPainter {
  final List<double> values;
  final int selectedIndex;

  const _ReferenceChartPainter({
    required this.values,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const minV = 1.4;
    const maxV = 3.5;
    const padTop = 10.0;
    const padBottom = 10.0;
    final h = size.height - padTop - padBottom;

    double px(int i) =>
        (size.width / values.length) * (i + 0.5);
    double py(double v) =>
        padTop + h * (1 - ((v - minV) / (maxV - minV)).clamp(0.0, 1.0));

    // Grid halus
    final gridPaint = Paint()
      ..color = AppColors.line.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    for (var r = 0; r < 4; r++) {
      final y = padTop + (h / 3) * r;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Kurva cubic mulus
    final path = Path()..moveTo(px(0), py(values[0]));
    for (var i = 0; i < values.length - 1; i++) {
      final x0 = px(i);
      final y0 = py(values[i]);
      final x1 = px(i + 1);
      final y1 = py(values[i + 1]);
      final cx = (x0 + x1) / 2;
      path.cubicTo(cx, y0, cx, y1, x1, y1);
    }

    final fill = Path.from(path)
      ..lineTo(px(values.length - 1), size.height)
      ..lineTo(px(0), size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.green.withValues(alpha: 0.18),
            AppColors.green.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Crosshair garis putus-putus pada titik terpilih (ikut Reference Design)
    final sx = px(selectedIndex);
    final sy = py(values[selectedIndex]);
    final dashPaint = Paint()
      ..color = AppColors.inkSoft.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(sx, y), Offset(sx, (y + 4).clamp(0, size.height)),
          dashPaint);
    }
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, sy), Offset((x + 4).clamp(0, size.width), sy),
          dashPaint);
    }

    // Titik aktif hijau + cincin putih
    canvas.drawCircle(Offset(sx, sy), 6.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(sx, sy), 4.5, Paint()..color = AppColors.green);
  }

  @override
  bool shouldRepaint(covariant _ReferenceChartPainter old) =>
      old.selectedIndex != selectedIndex || old.values != values;
}
