import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import 'finance_repository.dart';

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

  // Dummy agar skeleton punya bentuk.
  static const _ghost = [
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
    Invoice('INV/0000/000', 'Memuat · 0000-00-00', '+Rp 000 jt', 'PAID', true),
  ];

  @override
  Widget build(BuildContext context) {
    final rows = _loading ? _ghost : _inv;
    return SafeArea(
      child: Skeletonizer(
        enabled: _loading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Text('Finance', style: numStyle(size: 22)),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                    child: StatTile(
                        label: 'REVENUE',
                        value: 'Rp 3,2 M',
                        icon: IconsaxPlusBold.trend_up)),
                SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'COST',
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
                        label: 'PROFIT',
                        value: 'Rp 789 jt',
                        valueColor: AppColors.green,
                        icon: IconsaxPlusBold.money)),
                SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'MARGIN',
                        value: '24,6%',
                        icon: IconsaxPlusBold.percentage_square)),
              ],
            ),
            const SizedBox(height: 18),
            Text('Invoice terbaru', style: numStyle(size: 15)),
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
                size: 18, color: e.paid ? AppColors.greenInk : AppColors.loss),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.no, style: numStyle(size: 14)),
                Text(e.note,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(e.amount,
                  style: numStyle(size: 14, color: AppColors.green)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: e.paid ? AppColors.greenSoft : AppColors.lossSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e.status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: e.paid ? AppColors.greenInk : AppColors.loss)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
