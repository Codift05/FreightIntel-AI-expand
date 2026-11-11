import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import 'customer_repository.dart';
import 'customer_detail_screen.dart';

/// Daftar customer + peringkat berdasarkan laba (FR-CAN-01, FR-CAN-02).
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

enum _Sort { laba, pendapatan, margin }

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _all = const [];
  bool _loading = true;
  String _query = '';
  _Sort _sort = _Sort.laba;

  @override
  void initState() {
    super.initState();
    CustomerRepository.instance.fetch().then((v) {
      if (mounted) setState(() => (_all = v, _loading = false));
    });
  }

  List<Customer> get _rows {
    final q = _query.trim().toLowerCase();
    final list = _all
        .where((c) =>
            q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q))
        .toList();
    list.sort(switch (_sort) {
      _Sort.laba => (a, b) => b.profitJt.compareTo(a.profitJt),
      _Sort.pendapatan => (a, b) => b.revenueJt.compareTo(a.revenueJt),
      _Sort.margin => (a, b) => b.marginPct.compareTo(a.marginPct),
    });
    return list;
  }

  static const _ghost = Customer(
    name: 'PT Contoh Nama',
    city: 'Kota',
    sejak: '-',
    shipments: 0,
    revenueJt: 0,
    profitJt: 0,
    marginPct: 0,
    tepatWaktuPct: 0,
    trend: [0, 0, 0, 0, 0, 0],
    recent: [],
  );

  @override
  Widget build(BuildContext context) {
    final rows = _loading ? List.filled(4, _ghost) : _rows;
    final top = rows.isEmpty ? null : rows.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader('Customer', subtitle: 'Analisis per pelanggan'),
            Expanded(
              child: Skeletonizer(
                enabled: _loading,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (top != null) _topCard(top),
                    const SizedBox(height: 18),
                    _search(),
                    const SizedBox(height: 12),
                    _sortRow(),
                    const SizedBox(height: 14),
                    if (rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('Tidak ada customer yang cocok.',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 13)),
                        ),
                      )
                    else
                      for (var i = 0; i < rows.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _row(rows[i], i + 1),
                        ),
                    const SizedBox(height: 4),
                    const DemoNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Temuan AI: customer paling menguntungkan (FR-CAN-03).
  Widget _topCard(Customer c) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${c.name} menyumbang laba terbesar bulan ini.',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${c.profitJt} jt dari ${c.shipments} shipment · margin ${c.marginPct.toStringAsFixed(1)}% · risiko bayar ${c.risiko.toLowerCase()}.',
              style: const TextStyle(
                  color: AppColors.onDark, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      );

  Widget _search() => TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Cari nama atau kota',
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13.5),
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
      );

  Widget _sortRow() => Row(
        children: [
          const Text('Urut',
              style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
          const SizedBox(width: 10),
          for (final s in _Sort.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pressable(
                onTap: () => setState(() => _sort = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: kEaseOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: _sort == s ? AppColors.ink : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: _sort == s ? null : AppShadows.soft,
                  ),
                  child: Text(s.name,
                      style: TextStyle(
                          color:
                              _sort == s ? Colors.white : AppColors.muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      );

  Widget _row(Customer c, int rank) => AppCard(
        onTap: _loading
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => CustomerDetailScreen(c)),
                ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.greenSoft, shape: BoxShape.circle),
              child: Text(c.initials,
                  style: numStyle(size: 15, color: AppColors.greenInk)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$rank',
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(c.name, style: numStyle(size: 14.5))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${c.city} · ${c.shipments} shipment',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp ${c.profitJt} jt',
                    style: numStyle(size: 14.5, color: AppColors.green)),
                const SizedBox(height: 2),
                Text('margin ${c.marginPct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
              ],
            ),
          ],
        ),
      );
}
