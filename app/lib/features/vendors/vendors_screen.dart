import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import 'vendor_repository.dart';
import 'vendor_detail_screen.dart';

/// Daftar vendor, biaya, dan perbandingan antar vendor (FR-VAN-01, FR-VAN-02).
class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<Vendor> _all = const [];
  bool _loading = true;
  bool _banding = false; // mode perbandingan

  @override
  void initState() {
    super.initState();
    VendorRepository.instance.fetch().then((v) {
      if (mounted) setState(() => (_all = v, _loading = false));
    });
  }

  static const _ghost = Vendor(
    name: 'PT Contoh Vendor',
    kind: 'Kategori',
    city: 'Kota',
    shipments: 0,
    costJt: 0,
    tepatWaktuPct: 0,
    indeksTarif: 1,
    trend: [0, 0, 0, 0, 0, 0],
    rincian: [],
  );

  @override
  Widget build(BuildContext context) {
    final rows = (_loading ? List.filled(4, _ghost) : _all.toList())
      ..sort((a, b) => b.costJt.compareTo(a.costJt));
    final mahal = _all.isEmpty
        ? null
        : (_all.toList()
              ..sort((a, b) =>
                  b.potensiHematJt.compareTo(a.potensiHematJt)))
            .first;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Vendor',
              subtitle: 'Biaya dan performa per vendor',
              action: HeaderAction(
                icon: _banding
                    ? IconsaxPlusBold.chart_21
                    : IconsaxPlusLinear.chart_21,
                label: 'Mode perbandingan',
                onTap: () => setState(() => _banding = !_banding),
              ),
            ),
            Expanded(
              child: Skeletonizer(
                enabled: _loading,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (mahal != null && mahal.potensiHematJt > 0)
                      _savingCard(mahal),
                    const SizedBox(height: 18),
                    Text(_banding ? 'Perbandingan biaya' : 'Semua vendor',
                        style: numStyle(size: 15)),
                    const SizedBox(height: 10),
                    if (_banding)
                      _compareCard(rows)
                    else
                      for (final v in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _row(v),
                        ),
                    const SizedBox(height: 16),
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

  /// Temuan AI: vendor biaya tertinggi & potensi penghematan (FR-VAN-03).
  Widget _savingCard(Vendor v) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarif ${v.name} ${v.selisihTarifPct.toStringAsFixed(0)}% di atas rata-rata vendor sejenis.',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35),
            ),
            const SizedBox(height: 8),
            Text(
              'Kalau tarifnya turun ke rata-rata pasar, biaya bulanan berkurang sekitar Rp ${v.potensiHematJt} jt.',
              style: const TextStyle(
                  color: AppColors.onDark, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      );

  Widget _row(Vendor v) => AppCard(
        onTap: _loading
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VendorDetailScreen(v)),
                ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(v.initials, style: numStyle(size: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.name, style: numStyle(size: 14.5)),
                  const SizedBox(height: 2),
                  Text('${v.kind} · ${v.shipments} shipment',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp ${v.costJt} jt', style: numStyle(size: 14.5)),
                const SizedBox(height: 3),
                _tarifTag(v),
              ],
            ),
          ],
        ),
      );

  Widget _tarifTag(Vendor v) {
    final over = v.selisihTarifPct > 2;
    final under = v.selisihTarifPct < -2;
    final c = over
        ? AppColors.loss
        : under
            ? AppColors.green
            : AppColors.muted;
    final t = over
        ? '+${v.selisihTarifPct.toStringAsFixed(0)}% vs pasar'
        : under
            ? '${v.selisihTarifPct.toStringAsFixed(0)}% vs pasar'
            : 'setara pasar';
    return Text(t,
        style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w600));
  }

  /// Batang horizontal: biaya tiap vendor relatif terhadap yang terbesar.
  Widget _compareCard(List<Vendor> rows) {
    final maxCost =
        rows.fold<int>(1, (m, v) => v.costJt > m ? v.costJt : m);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final v in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(v.name,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text('Rp ${v.costJt} jt',
                          style: numStyle(size: 13)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: v.costJt / maxCost,
                      minHeight: 8,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation(
                        v.selisihTarifPct > 2
                            ? AppColors.loss
                            : AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                      'Tepat waktu ${v.tepatWaktuPct.toStringAsFixed(0)}% · ${v.performa.toLowerCase()}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
