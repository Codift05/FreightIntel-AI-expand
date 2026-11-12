import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import 'ask_ai_screen.dart';

typedef _Cause = ({String name, String delta, String amount, bool bad});
typedef _Rec = ({String title, String note, String impact});

/// Insight AI: temuan utama, penyebab, rekomendasi, prediksi, dan bar Tanya AI.
/// PRD FR-AI-01..04 + FR-FC. Analisis masih contoh (belum terhubung data).
class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  bool _loading = true;
  String _headline =
      'Profit naik 12%, tapi margin rute Jakarta → Tokyo turun 6 poin.';
  int _predProfitJt = 820;
  int _lowBandJt = 760;
  int _highBandJt = 880;
  String _expensiveVendor = 'CV Mitra Laut';

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final res = await ApiClient.instance.get('/insights');
    if (res is Map<String, dynamic>) {
      final fc = res['forecastNextMonth'];
      final sum = res['summary'];
      if (mounted) {
        setState(() {
          if (res['headline'] is String) {
            _headline = res['headline'] as String;
          }
          if (fc is Map<String, dynamic>) {
            _predProfitJt =
                (fc['predictedProfitJt'] as num?)?.toInt() ?? _predProfitJt;
            _lowBandJt = (fc['lowBandJt'] as num?)?.toInt() ?? _lowBandJt;
            _highBandJt = (fc['highBandJt'] as num?)?.toInt() ?? _highBandJt;
          }
          if (sum is Map<String, dynamic> &&
              sum['expensiveVendor'] is String) {
            _expensiveVendor = sum['expensiveVendor'] as String;
          }
          _loading = false;
        });
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  List<_Cause> get _causes => <_Cause>[
        (name: 'Biaya trucking', delta: '+18%', amount: 'Rp 14 jt', bad: true),
        (
          name: 'Vendor $_expensiveVendor',
          delta: '+14%',
          amount: 'Rp 9 jt',
          bad: true
        ),
        (
          name: 'Handling Belawan',
          delta: '-4%',
          amount: 'Rp 2 jt',
          bad: false
        ),
      ];

  List<_Rec> get _recs => <_Rec>[
        (
          title: 'Negosiasi ulang tarif $_expensiveVendor',
          note: 'Tarif di atas rata-rata pasar vendor sejenis.',
          impact: 'hemat Rp 24 jt/bln'
        ),
        (
          title: 'Alihkan sebagian rute Jakarta → Tokyo ke jalur laut',
          note: 'Margin udara turun 6 poin, laut stabil 3 bulan terakhir.',
          impact: 'margin +4 poin'
        ),
        (
          title: 'Tagih 2 invoice yang lewat jatuh tempo',
          note: 'INV/2610/009 dan INV/2609/008.',
          impact: 'kas +Rp 130 jt'
        ),
      ];

  void _askAi() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AskAiScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Skeletonizer(
        enabled: _loading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
          children: [
            Text('Insight', style: numStyle(size: 22)),
            const SizedBox(height: 4),
            const Text('Analisis otomatis dari data perusahaan',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 18),
            _lead(),
            const SizedBox(height: 24),
            Text('Penyebab', style: numStyle(size: 15)),
            const SizedBox(height: 10),
            _causeCard(),
            const SizedBox(height: 24),
            Text('Rekomendasi', style: numStyle(size: 15)),
            const SizedBox(height: 10),
            _recCard(),
            const SizedBox(height: 24),
            Text('Prediksi bulan depan', style: numStyle(size: 15)),
            const SizedBox(height: 10),
            _forecastCard(),
            const SizedBox(height: 24),
            _askBar(),
            const SizedBox(height: 14),
            const Text('Analisis contoh dari data demo.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Temuan utama: kalimat memimpin, bukan template angka besar.
  Widget _lead() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: [
            BoxShadow(
                color: AppColors.inkDeep.withValues(alpha: 0.30),
                blurRadius: 26,
                offset: const Offset(0, 14),
                spreadRadius: -10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _headline,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.35),
            ),
            const SizedBox(height: 10),
            const Text(
              'Penurunan terbesar datang dari biaya trucking yang naik 18% bulan ini.',
              style: TextStyle(
                  color: AppColors.onDark, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(IconsaxPlusLinear.calendar,
                    size: 15, color: AppColors.onDark),
                const SizedBox(width: 6),
                Text('128 shipment · Oktober 2026',
                    style: const TextStyle(
                        color: AppColors.onDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 420.ms).slideY(
          begin: 0.08, end: 0, curve: kEaseOut);

  Widget _causeCard() => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _causes.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_causes[i].name,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(_causes[i].delta,
                        style: TextStyle(
                            color: _causes[i].bad
                                ? AppColors.loss
                                : AppColors.greenInk,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 62,
                      child: Text(_causes[i].amount,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _recCard() => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _recs.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_recs[i].title,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3)),
                    const SizedBox(height: 4),
                    Text(_recs[i].note,
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                            height: 1.4)),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(_recs[i].impact,
                          style: const TextStyle(
                              color: AppColors.greenInk,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _forecastCard() => AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp $_predProfitJt jt', style: numStyle(size: 25)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_drop_up,
                          size: 18, color: AppColors.greenInk),
                      Text('8%',
                          style: const TextStyle(
                              color: AppColors.greenInk,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Rentang prediksi: pita hijau di antara batas bawah dan atas.
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                children: [
                  const Spacer(flex: 2),
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Rp $_lowBandJt jt',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
                const Spacer(),
                Text('Rp $_highBandJt jt',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Dihitung dari tren 6 bulan terakhir.',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
          ],
        ),
      );

  /// Pintu masuk chat Tanya AI.
  Widget _askBar() => Pressable(
        semanticLabel: 'Tanya AI',
        onTap: _askAi,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              const Icon(IconsaxPlusLinear.message_question,
                  size: 19, color: AppColors.muted),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Tanya soal keuangan perusahaanmu',
                    style: TextStyle(color: AppColors.muted, fontSize: 13.5)),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: AppColors.lime, shape: BoxShape.circle),
                child: const Icon(IconsaxPlusBold.arrow_right_1,
                    size: 15, color: AppColors.ink),
              ),
            ],
          ),
        ),
      );
}
