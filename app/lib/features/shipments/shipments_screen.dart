import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mode_icon.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import 'shipment_repository.dart';
import 'shipment_detail_screen.dart';
import 'create_shipment_screen.dart';
import 'status_chip.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final _repo = ShipmentRepository.instance;
  final _scroll = ScrollController();
  final _items = <Shipment>[];
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _status; // null = semua
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
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Shipment> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((s) {
      final okQ = q.isEmpty ||
          s.id.toLowerCase().contains(q) ||
          s.client.toLowerCase().contains(q) ||
          s.route.toLowerCase().contains(q);
      final okS = _status == null || s.status == _status;
      return okQ && okS && !s.arsip; // yang diarsipkan disembunyikan
    }).toList();
  }

  /// Buka detail; saat kembali, ambil versi terbaru dari repo (status/arsip
  /// bisa berubah di layar Ubah shipment).
  Future<void> _openDetail(Shipment s) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShipmentDetailScreen(s)),
    );
    if (!mounted) return;
    final fresh = _repo.cached.firstWhere((e) => e.id == s.id, orElse: () => s);
    final i = _items.indexWhere((e) => e.id == s.id);
    if (i >= 0) setState(() => _items[i] = fresh);
  }

  Future<void> _openCreate() async {
    final s = await Navigator.of(context).push<Shipment>(
      MaterialPageRoute(builder: (_) => const CreateShipmentScreen()),
    );
    if (s == null || !mounted) return;
    setState(() => _items.insert(0, s));
  }

  // Dummy untuk skeleton (bentuk mengikuti kartu asli).
  static const _ghost = Shipment(
      'FI-0000-0000', 'PT Contoh Nama', 'Kota → Kota', 'Trucking',
      'Rp 000 jt', 'Rp 00 jt', true, 'Booking');

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return SafeArea(
        child: Skeletonizer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
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

    if (_items.isEmpty && _end) {
      return SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: EmptyState(
                asset: Illus.emptyShipments,
                title: 'Belum ada shipment',
                message: 'Shipment yang kamu buat akan tampil di sini.',
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
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: _openCreate,
                  icon: const Icon(IconsaxPlusBold.add),
                  label: const Text('Buat shipment'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final list = _filtered;
    return SafeArea(
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
        itemCount: list.length + 2, // header + footer
        itemBuilder: (context, i) {
          if (i == 0) return _header();
          if (i == list.length + 1) {
            return list.isEmpty ? _noResult() : _Footer(end: _end);
          }
          final s = list[i - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShipmentCard(
              s,
              onTap: () => _openDetail(s),
            ),
          );
        },
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Shipments', style: numStyle(size: 22))),
                _AddButton(onTap: _openCreate),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari ID, customer, atau rute',
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
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in ['Semua', ...kShipmentStatuses]) _chip(f),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _chip(String label) {
    final sel = (label == 'Semua' && _status == null) || _status == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: () =>
            setState(() => _status = label == 'Semua' ? null : label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: kEaseOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? AppColors.ink : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: sel ? null : AppShadows.soft,
          ),
          child: Text(label,
              style: TextStyle(
                  color: sel ? Colors.white : AppColors.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _noResult() => const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text('Tidak ada shipment yang cocok.',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
        ),
      );
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: 'Buat shipment',
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: AppColors.lime, shape: BoxShape.circle),
        child: const Icon(IconsaxPlusBold.add, color: AppColors.ink, size: 24),
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
                    strokeWidth: 2.4, color: AppColors.ink),
              ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Shipment s;
  final VoidCallback? onTap;
  const _ShipmentCard(this.s, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ModeIcon(s.type, size: 46),
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
              StatusChip(s.status),
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
              _kv('Moda', s.type, AppColors.ink),
              _kv('Pendapatan', s.revenue, AppColors.ink),
              _kv('Laba', s.profit,
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
          Text(k, style: labelStyle().copyWith(fontSize: 12)),
          const SizedBox(height: 2),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: c, fontSize: 13)),
        ],
      );
}
