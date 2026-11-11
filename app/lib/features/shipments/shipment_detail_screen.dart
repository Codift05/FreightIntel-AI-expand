import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../finance/finance_repository.dart';
import '../finance/record_transaction_screen.dart';
import 'shipment_repository.dart';
import 'edit_shipment_screen.dart';
import 'status_chip.dart';

/// Detail shipment (gaya layar kanan Reference Design):
/// header tengah + tombol bulat, kartu hero gelap ringkas dengan delta pill,
/// rincian pendapatan/biaya Bahasa Indonesia, dan tombol aksi ganda di bawah
/// (Catat Biaya [gelap] + Catat Masuk [lime]).
class ShipmentDetailScreen extends StatefulWidget {
  final Shipment shipment;
  const ShipmentDetailScreen(this.shipment, {super.key});

  @override
  State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  late Shipment s = widget.shipment;

  /// Buka layar ubah; hasilnya menggantikan data yang tampil.
  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Shipment>(
      MaterialPageRoute(builder: (_) => EditShipmentScreen(s)),
    );
    if (updated != null && mounted) setState(() => s = updated);
  }

  int get _rev => _num(s.revenue);
  int get _profit => _num(s.profit);
  int get _cost => _rev - _profit;
  double get _margin => _rev == 0 ? 0 : _profit / _rev * 100;

  Future<void> _recordForShipment(
      BuildContext context, FinanceEntryType type) async {
    final repo = ShipmentRepository.instance;
    final entry = await Navigator.of(context).push<Invoice>(
      MaterialPageRoute(
        builder: (_) => RecordTransactionScreen(
          type: type,
          initialShipmentNo: s.id,
          loadShipments: () =>
              repo.hasCache ? Future.value(repo.cached) : repo.fetchPage(0),
        ),
      ),
    );
    if (entry == null || !context.mounted) return;
    FinanceRepository.instance.add(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loss = _profit < 0;
    final profitStr = '${loss ? '-' : ''}Rp ${_profit.abs()} jt';
    final marginStr =
        '${_margin >= 0 ? '+' : ''}${_margin.toStringAsFixed(1).replaceAll('.', ',')}%';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _topBar(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  HighlightCard(
                    label: '${s.route}  ·  ${s.type}',
                    value: profitStr,
                    sub: 'Pendapatan Rp $_rev jt  ·  Biaya Rp $_cost jt',
                    delta: marginStr,
                    deltaUp: !loss,
                  ),
                  const SizedBox(height: 18),
                  _title('Status pengiriman'),
                  const SizedBox(height: 10),
                  _Timeline(current: s.status),
                  const SizedBox(height: 20),
                  _title('Rincian pendapatan'),
                  const SizedBox(height: 10),
                  _items(
                      _split(
                          _rev,
                          const [
                            'Ongkos angkut utama',
                            'Penanganan & muat',
                            'Dokumen & administrasi'
                          ],
                          const ['Lunas', 'Cicilan', 'Belum lunas']),
                      AppColors.green),
                  const SizedBox(height: 16),
                  _title('Rincian biaya'),
                  const SizedBox(height: 10),
                  _items(
                      _split(
                          _cost,
                          const [
                            'Vendor pelayaran/maskapai',
                            'Armada darat',
                            'Kepabeanan & pelabuhan'
                          ],
                          const ['Lunas', 'Belum lunas', 'Lunas']),
                      AppColors.loss),
                  const SizedBox(height: 20),
                  _title('Informasi kargo'),
                  const SizedBox(height: 10),
                  _customFields(),
                  const SizedBox(height: 14),
                  const Text('Rincian contoh, belum terhubung data.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  /// Header atas gaya layar kanan Reference Design:
  /// tombol bulat kiri (kembali), judul+subjudul di tengah, status/aksi kanan.
  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Pressable(
          semanticLabel: 'Kembali',
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(IconsaxPlusLinear.arrow_left,
                color: AppColors.ink, size: 20),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(s.id, style: numStyle(size: 16)),
              const SizedBox(height: 2),
              Text(s.client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        StatusChip(s.status),
        const SizedBox(width: 8),
        Pressable(
          semanticLabel: 'Ubah shipment',
          onTap: _edit,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(IconsaxPlusLinear.edit_2,
                color: AppColors.ink, size: 19),
          ),
        ),
      ],
    );
  }

  /// Bar aksi bawah 2 tombol (Gelap di kiri + Lime di kanan) sesuai
  /// tombol "Sell ↗" & "Buy ↙" pada layar kanan Reference Design.
  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.bg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              semanticLabel: 'Catat biaya shipment',
              onTap: () => _recordForShipment(context, FinanceEntryType.cost),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.inkDeep,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Catat Biaya',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 6),
                    Icon(Icons.north_east_rounded,
                        size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Pressable(
              semanticLabel: 'Catat pemasukan shipment',
              onTap: () =>
                  _recordForShipment(context, FinanceEntryType.revenue),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Catat Masuk',
                        style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 6),
                    Icon(Icons.south_west_rounded,
                        size: 18, color: AppColors.ink),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Text(t, style: numStyle(size: 15));

  Widget _items(List<_Item> items, Color accent) => AppCard(
        shadow: AppShadows.soft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(items[i].label,
                            style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600))),
                    _payChip(items[i].pay),
                    const SizedBox(width: 10),
                    Text('Rp ${items[i].amount} jt',
                        style: numStyle(size: 14, color: accent)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _payChip(String pay) {
    final (Color fg, Color bg) = switch (pay) {
      'Lunas' => (AppColors.greenInk, AppColors.greenSoft),
      'Cicilan' => (AppColors.warning, AppColors.warningSoft),
      _ => (AppColors.loss, AppColors.lossSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(pay,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _customFields() {
    final fields = {
      'No. BL': 'MBL-2610-0291',
      'Kontainer': s.container,
      'Incoterm': 'CIF',
      'ETD': s.etd,
      'ETA': s.eta,
    };
    return AppCard(
      shadow: AppShadows.soft,
      child: Column(
        children: [
          for (final e in fields.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13))),
                  Text(e.value,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- util ---
  static int _num(String s) {
    final neg = s.contains('-');
    final d = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return neg ? -d : d;
  }

  List<_Item> _split(int total, List<String> labels, List<String> pays) {
    final a = (total * 0.6).round();
    final b = (total * 0.25).round();
    final c = total - a - b;
    final amts = [a, b, c];
    return [
      for (var i = 0; i < 3; i++) _Item(labels[i], amts[i], pays[i]),
    ];
  }
}

class _Item {
  final String label;
  final int amount;
  final String pay;
  _Item(this.label, this.amount, this.pay);
}

/// Timeline status vertikal (selesai = centang hijau, sekarang = titik hijau,
/// berikutnya = abu).
class _Timeline extends StatelessWidget {
  final String current;
  const _Timeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final idx = kShipmentStatuses.indexOf(current).clamp(0, 99);
    return AppCard(
      shadow: AppShadows.soft,
      child: Column(
        children: [
          for (var i = 0; i < kShipmentStatuses.length; i++)
            _row(i, idx, i == kShipmentStatuses.length - 1),
        ],
      ),
    );
  }

  Widget _row(int i, int idx, bool last) {
    final done = i < idx;
    final active = i == idx;
    final color = (done || active) ? AppColors.green : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? AppColors.green : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : (active
                        ? Center(
                            child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle)))
                        : null),
              ),
              if (!last)
                Expanded(
                  child: Container(
                      width: 2,
                      color: done ? AppColors.green : AppColors.line),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(top: 1, bottom: last ? 0 : 16),
            child: Text(
              kShipmentStatuses[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: (done || active) ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
