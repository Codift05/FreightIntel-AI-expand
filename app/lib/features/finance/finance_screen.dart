import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../customers/customers_screen.dart';
import '../reports/report_screen.dart';
import '../vendors/vendors_screen.dart';
import 'invoice_ocr_screen.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/sparkline.dart';
import 'finance_repository.dart';
import 'record_transaction_screen.dart';
import '../shipments/shipment_repository.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _repo = FinanceRepository.instance;
  final _searchCtrl = TextEditingController();
  List<Invoice> _inv = const [];
  bool _loading = true;
  bool _fullBalance = true;
  String _query = '';
  String _filter = 'Semua'; // Semua | Belum lunas | Lunas

  @override
  void initState() {
    super.initState();
    if (_repo.hasCache) {
      _inv = _repo.cached;
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _repo.fetch();
    if (!mounted) return;
    setState(() {
      _inv = data;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    final type = await showModalBottomSheet<FinanceEntryType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('choose-revenue'),
              leading: const Icon(
                IconsaxPlusBold.trend_up,
                color: AppColors.green,
              ),
              title: const Text('Pemasukan'),
              onTap: () => Navigator.of(context).pop(FinanceEntryType.revenue),
            ),
            ListTile(
              key: const Key('choose-cost'),
              leading: const Icon(
                IconsaxPlusBold.trend_down,
                color: AppColors.loss,
              ),
              title: const Text('Biaya'),
              onTap: () => Navigator.of(context).pop(FinanceEntryType.cost),
            ),
          ],
        ),
      ),
    );
    if (type == null || !mounted) return;
    await _createForType(type);
  }

  Future<void> _openPayment(Invoice e) async {
    final ctrl =
        TextEditingController(text: '${e.totalJt - (e.paidRupiah ?? 0)}');
    final amt = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catat pembayaran', style: numStyle(size: 17)),
            const SizedBox(height: 4),
            Text('${e.no} · sisa Rp ${e.totalJt - (e.paidRupiah ?? 0)} jt',
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah bayar (jt)',
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.input),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill)),
                ),
                onPressed: () =>
                    Navigator.of(ctx).pop(int.tryParse(ctrl.text.trim()) ?? 0),
                child: const Text('Simpan',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (amt == null || amt <= 0 || !mounted) return;
    _repo.recordPayment(e.no, amt);
    setState(() => _inv = _repo.cached);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran dicatat.')),
    );
  }

  Future<void> _createForType(FinanceEntryType type) async {
    final shipmentRepository = ShipmentRepository.instance;
    final entry = await Navigator.of(context).push<Invoice>(
      MaterialPageRoute(
        builder: (_) => RecordTransactionScreen(
          type: type,
          loadShipments: () => shipmentRepository.hasCache
              ? Future.value(shipmentRepository.cached)
              : shipmentRepository.fetchPage(0),
        ),
      ),
    );
    if (entry == null || !mounted) return;
    _repo.add(entry);
    setState(() => _inv = _repo.cached);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi contoh ditambahkan.')),
    );
  }

  void _cycleFilter() {
    const opts = ['Semua', 'Belum lunas', 'Lunas'];
    final next = opts[(opts.indexOf(_filter) + 1) % opts.length];
    setState(() => _filter = next);
  }

  List<Invoice> get _filtered {
    final q = _query.trim().toLowerCase();
    return _inv.where((e) {
      final okQ = q.isEmpty ||
          e.no.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q) ||
          (e.counterparty?.toLowerCase().contains(q) ?? false);
      final okF = switch (_filter) {
        'Belum lunas' => !e.paid,
        'Lunas' => e.paid,
        _ => true,
      };
      return okQ && okF;
    }).toList();
  }

  // Dummy agar skeleton punya bentuk.
  static const _ghost = [
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_loading && _inv.isEmpty) {
      return SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: EmptyState(
                asset: Illus.emptyFinance,
                title: 'Belum ada transaksi',
                message: 'Catat pemasukan atau biaya shipment pertama.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  onPressed: _openCreate,
                  icon: const Icon(IconsaxPlusBold.add),
                  label: const Text('Catat transaksi'),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final rows = _loading ? _ghost : _filtered;
    return SafeArea(
      child: Skeletonizer(
        enabled: _loading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 116),
          children: [
            _buildBalanceVault(),
            const SizedBox(height: 16),
            _quickLinks(),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari mis. "INV/2610" atau "Ocean"',
                hintStyle:
                    const TextStyle(color: AppColors.muted, fontSize: 13.5),
                prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1,
                    color: AppColors.ink, size: 19),
                isDense: true,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child:
                        Text('Aktivitas Transaksi', style: numStyle(size: 16))),
                Pressable(
                  semanticLabel: 'Filter status invoice',
                  onTap: _cycleFilter,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_filter,
                          style: const TextStyle(
                              color: AppColors.inkSoft,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(IconsaxPlusLinear.arrow_down,
                          size: 14, color: AppColors.inkSoft),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text('Tidak ada transaksi yang cocok.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                ),
              )
            else
              for (var i = 0; i < rows.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InvoiceRow(
                    rows[i],
                    index: i,
                    onTap: (_loading || rows[i].paid)
                        ? null
                        : () => _openPayment(rows[i]),
                  ),
                ),
            const SizedBox(height: 4),
            const Text(
                'Ketuk invoice belum lunas untuk catat pembayaran. Angka contoh.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _openOcr() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const InvoiceOcrScreen()),
    );
    if (ok == true && mounted) setState(() => _inv = _repo.cached);
  }

  /// Pintasan ke modul keuangan lain yang tidak punya tab sendiri.
  Widget _quickLinks() => SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _link(IconsaxPlusLinear.document_text, 'Laporan',
                () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReportScreen()))),
            _link(IconsaxPlusLinear.profile_2user, 'Customer',
                () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CustomersScreen()))),
            _link(IconsaxPlusLinear.truck, 'Vendor',
                () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const VendorsScreen()))),
            _link(IconsaxPlusLinear.scan, 'Scan invoice', _openOcr,
                lime: true),
          ],
        ),
      );

  Widget _link(IconData icon, String label, VoidCallback onTap,
          {bool lime = false}) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Pressable(
          semanticLabel: label,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: lime ? AppColors.lime : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              boxShadow: lime ? null : AppShadows.soft,
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.ink),
                const SizedBox(width: 7),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );

  /// Kartu saldo gelap di atas + dock 3 tombol aksi bulat (Deposit/Withdraw/Transfer)
  /// mengikuti layar kiri Reference Design.
  Widget _buildBalanceVault() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDeep.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -10,
          ),
        ],
      ),
      child: CustomPaint(
        painter: const _VaultArcsPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            children: [
              Text('Laba Bersih (DPP)',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => _fullBalance = !_fullBalance),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _fullBalance ? 'Rp 789.300.000' : 'Rp 789 jt',
                    style: numStyle(
                        size: 32,
                        weight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Masuk Rp 3,2 M  ·  Biaya Rp 2,4 M  ·  Margin 24,6%',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF232529),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _vaultAction(
                      label: 'Pemasukan',
                      icon: IconsaxPlusLinear.card_receive,
                      highlight: false,
                      onTap: () {
                        if (!_loading) _createForType(FinanceEntryType.revenue);
                      },
                    ),
                    _vaultAction(
                      label: 'Biaya',
                      icon: IconsaxPlusLinear.card_send,
                      highlight: false,
                      onTap: () {
                        if (!_loading) _createForType(FinanceEntryType.cost);
                      },
                    ),
                    _vaultAction(
                      key: const Key('add-transaction'),
                      label: 'Catat Baru',
                      icon: IconsaxPlusLinear.convert_card,
                      highlight: true,
                      onTap: () {
                        if (!_loading) _openCreate();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vaultAction({
    Key? key,
    required String label,
    required IconData icon,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return Pressable(
      key: key,
      semanticLabel: label,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlight ? AppColors.lime : const Color(0xFF2F3237),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 21,
              color: highlight
                  ? AppColors.ink
                  : Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: highlight ? 0.95 : 0.68),
              fontSize: 12,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultArcsPainter extends CustomPainter {
  const _VaultArcsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 1.05, size.height * 0.42);
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    for (final r in const [68.0, 108.0, 148.0]) {
      canvas.drawCircle(c, r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InvoiceRow extends StatelessWidget {
  final Invoice e;
  final int index;
  final VoidCallback? onTap;
  const _InvoiceRow(this.e, {required this.index, this.onTap});

  static const _upTrends = [
    [0.35, 0.55, 0.42, 0.78, 0.64, 0.92],
    [0.25, 0.48, 0.62, 0.52, 0.85, 0.95],
  ];
  static const _downTrends = [
    [0.85, 0.62, 0.74, 0.42, 0.50, 0.25],
  ];

  @override
  Widget build(BuildContext context) {
    final isCost = e.type == FinanceEntryType.cost;
    final positive = !isCost && e.paid;
    final trendColor = positive ? AppColors.green : AppColors.loss;
    final status = e.paid ? 'Lunas' : (e.partial ? 'Cicilan' : 'Belum lunas');
    final deltaColor = e.paid
        ? AppColors.green
        : (e.partial ? AppColors.warning : AppColors.loss);
    final iconBg = isCost
        ? AppColors.lossSoft
        : (e.paid ? AppColors.greenSoft : AppColors.warningSoft);
    final iconFg = isCost
        ? AppColors.loss
        : (e.paid ? AppColors.green : AppColors.warning);
    final sparkData = positive
        ? _upTrends[index % _upTrends.length]
        : _downTrends[0];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      shadow: AppShadows.soft,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCost
                  ? IconsaxPlusBold.card_send
                  : IconsaxPlusBold.receipt_item,
              size: 20,
              color: iconFg,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.no,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: numStyle(size: 14)),
                const SizedBox(height: 3),
                Text(
                    e.counterparty == null
                        ? e.note
                        : '${e.counterparty} · ${e.shipmentNo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            height: 28,
            child: Sparkline(
              data: sparkData,
              color: trendColor,
              strokeWidth: 2.0,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.amount,
                  style: numStyle(size: 14, color: AppColors.ink)),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    e.paid
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: deltaColor,
                  ),
                  Text(status,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: deltaColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
