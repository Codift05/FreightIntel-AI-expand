import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import 'shipment_repository.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final _repo = ShipmentRepository.instance;
  final _scroll = ScrollController();
  final _items = <Shipment>[];
  int _page = 0;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    // Cache: kalau data sudah pernah dimuat, tampil langsung tanpa skeleton.
    if (_repo.hasCache) {
      _items.addAll(_repo.cached);
      _page = (_items.length / ShipmentRepository.pageSize).ceil();
      _initialLoading = false;
    } else {
      _loadMore();
    }
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 320) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _end) return;
    setState(() => _loadingMore = true);
    final batch = await _repo.fetchPage(_page);
    if (!mounted) return;
    setState(() {
      if (batch.isEmpty) {
        _end = true;
      } else {
        _items.addAll(batch);
        _page++;
      }
      _loadingMore = false;
      _initialLoading = false;
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Dummy untuk skeleton (bentuk mengikuti kartu asli).
  static const _ghost = Shipment(
      'FI-0000-0000', 'PT Contoh Nama', 'Kota → Kota', 'Trucking',
      'Rp 000 jt', 'Rp 00 jt', true);

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return SafeArea(
        child: Skeletonizer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              Text('Shipments', style: numStyle(size: 22)),
              const SizedBox(height: 14),
              for (var i = 0; i < 5; i++)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _ShipmentCard(_ghost),
                ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        itemCount: _items.length + 2, // judul + footer
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text('Shipments', style: numStyle(size: 22)),
            );
          }
          if (i == _items.length + 1) return _Footer(end: _end);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShipmentCard(_items[i - 1]),
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool end;
  const _Footer({required this.end});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: end
            ? Text('Semua shipment sudah dimuat',
                style: labelStyle().copyWith(letterSpacing: 0))
            : const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: AppColors.green),
              ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Shipment s;
  const _ShipmentCard(this.s);

  @override
  Widget build(BuildContext context) {
    final air = s.type == 'Air Freight';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                    color: AppColors.greenSoft, shape: BoxShape.circle),
                child: Icon(
                    air ? IconsaxPlusBold.airplane : IconsaxPlusBold.truck,
                    size: 19,
                    color: AppColors.greenInk),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.id, style: numStyle(size: 15)),
                    Text(s.client,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(IconsaxPlusBold.routing,
                  size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(s.route,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.ink))),
            ],
          ),
          const Divider(height: 20, color: AppColors.line),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kv('TYPE', s.type, AppColors.ink),
              _kv('REVENUE', s.revenue, AppColors.ink),
              _kv('PROFIT', s.profit,
                  s.profitUp ? AppColors.green : AppColors.loss),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: labelStyle().copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: c, fontSize: 13)),
        ],
      );
}
