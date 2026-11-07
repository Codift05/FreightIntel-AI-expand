import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    color: AppColors.ink, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('O', style: numStyle(size: 18, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, Owner',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    Text('Ringkasan keuangan',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.ink, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _PeriodChips(),
          const SizedBox(height: 18),
          const HighlightCard(
            label: 'PROFIT BULAN INI',
            value: 'Rp 789 jt',
            sub: 'Margin 24,6% · naik dari bulan lalu',
            progress: 0.62,
            progressLabel: '+12%',
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                  child: StatTile(
                      label: 'REVENUE',
                      value: 'Rp 3,2',
                      unit: 'M',
                      icon: Icons.trending_up_rounded)),
              SizedBox(width: 14),
              Expanded(
                  child: StatTile(
                      label: 'COST',
                      value: 'Rp 2,4',
                      unit: 'M',
                      valueColor: AppColors.loss,
                      icon: Icons.trending_down_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                  child: StatTile(
                      label: 'PIUTANG',
                      value: 'Rp 636',
                      unit: 'jt',
                      icon: Icons.south_west_rounded)),
              SizedBox(width: 14),
              Expanded(
                  child: StatTile(
                      label: 'HUTANG',
                      value: 'Rp 1,8',
                      unit: 'M',
                      icon: Icons.north_east_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child:
                            Text('Revenue vs Cost', style: numStyle(size: 15))),
                    Text('6 BULAN', style: labelStyle()),
                  ],
                ),
                const SizedBox(height: 20),
                const _MiniBars(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Angka contoh, belum terhubung data.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PeriodChips extends StatefulWidget {
  const _PeriodChips();
  @override
  State<_PeriodChips> createState() => _PeriodChipsState();
}

class _PeriodChipsState extends State<_PeriodChips> {
  int _sel = 1;
  static const _items = ['Harian', 'Bulanan', 'Tahunan'];
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_items.length, (i) {
        final active = i == _sel;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _sel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.ink : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: active ? null : AppShadows.soft,
              ),
              child: Text(_items[i],
                  style: TextStyle(
                      color: active ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        );
      }),
    );
  }
}

/// Bar chart ringan: label nilai di atas, bulan terakhir di-highlight.
class _MiniBars extends StatelessWidget {
  const _MiniBars();
  static const _h = [0.5, 0.35, 0.82, 0.45, 0.6, 0.95];
  static const _val = ['1,9', '1,4', '2,6', '1,8', '2,2', '3,2'];
  static const _months = ['06', '07', '08', '09', '10', '11'];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final active = i == 5;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_val[i],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.greenInk : AppColors.muted)),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  height: 14 + _h[i] * 96,
                  decoration: BoxDecoration(
                    color: active ? AppColors.green : AppColors.greenSoft,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_months[i], style: labelStyle().copyWith(fontSize: 10)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
