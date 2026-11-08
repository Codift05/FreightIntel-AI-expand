import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
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
  List<Invoice> _inv = const [];
  bool _loading = true;

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

  Widget _createButton() => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      key: const Key('add-transaction'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      onPressed: _loading ? null : _openCreate,
      icon: const Icon(IconsaxPlusBold.add),
      label: const Text('Catat transaksi'),
    ),
  );

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
              child: _createButton(),
            ),
          ],
        ),
      );
    }
    final rows = _loading ? _ghost : _inv;
    return SafeArea(
      child: Skeletonizer(
        enabled: _loading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
          children: [
            Text('Keuangan', style: numStyle(size: 22)),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                    child: StatTile(
                        label: 'Pendapatan',
                        value: 'Rp 3,2 M',
                        icon: IconsaxPlusBold.trend_up)),
                SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'Biaya',
                        value: 'Rp 2,4 M',
                        valueColor: AppColors.loss,
                        icon: IconsaxPlusBold.trend_down)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                    child: StatTile(
                        label: 'Laba',
                        value: 'Rp 789 jt',
                        valueColor: AppColors.green,
                        icon: IconsaxPlusBold.money)),
                SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'Margin',
                        value: '24,6%',
                        icon: IconsaxPlusBold.percentage_square)),
              ],
            ),
            const SizedBox(height: 18),
            _createButton(),
            const SizedBox(height: 18),
            Text('Transaksi terbaru', style: numStyle(size: 15)),
            const SizedBox(height: 10),
            for (final e in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InvoiceRow(e),
              ),
            const SizedBox(height: 4),
            const Text('Angka contoh, belum terhubung data.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice e;
  const _InvoiceRow(this.e);

  @override
  Widget build(BuildContext context) {
    final isCost = e.type == FinanceEntryType.cost;
    final amountColor = isCost ? AppColors.loss : AppColors.green;
    final status = e.paid ? 'Lunas' : 'Belum lunas';
    return AppCard(
      shadow: AppShadows.soft,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: e.paid ? AppColors.greenSoft : AppColors.lossSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(IconsaxPlusBold.receipt_item,
                size: 18, color: amountColor),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.no, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: numStyle(size: 14)),
                Text(e.counterparty == null
                    ? e.note
                    : '${e.counterparty} · ${e.shipmentNo}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 136),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.amount, maxLines: 2, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: numStyle(size: 14, color: amountColor)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: e.paid ? AppColors.greenSoft : AppColors.lossSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: e.paid ? AppColors.greenInk : AppColors.loss)),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}
