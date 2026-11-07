import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/logo_mark.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            children: [
              const LogoMark(size: 32),
              const SizedBox(width: 10),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.ink, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _PeriodChips(),
          const SizedBox(height: 16),
          const HighlightCard(
            label: 'PROFIT BULAN INI',
            value: 'Rp 789 jt',
            sub: 'Margin 24,6% · naik dari bulan lalu',
            progress: 0.62,
            progressLabel: '+12%',
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: StatTile(label: 'REVENUE', value: 'Rp 3,2 M')),
              SizedBox(width: 12),
              Expanded(
                  child: StatTile(
                      label: 'COST',
                      value: 'Rp 2,4 M',
                      valueColor: AppColors.loss)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: StatTile(label: 'PIUTANG', value: 'Rp 636 jt')),
              SizedBox(width: 12),
              Expanded(child: StatTile(label: 'HUTANG', value: 'Rp 1,8 M')),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Revenue vs Cost',
                            style: numStyle(size: 15))),
                    Text('6 BULAN', style: labelStyle()),
                  ],
                ),
                const SizedBox(height: 18),
                const _MiniBars(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Angka contoh — belum terhubung data.',
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
              duration: const Duration(milliseconds: 150),
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

/// Bar chart ringan (rounded top) — bulan terakhir di-highlight hijau.
class _MiniBars extends StatelessWidget {
  const _MiniBars();
  static const _data = [0.5, 0.35, 0.82, 0.45, 0.6, 0.95];
  static const _months = ['06', '07', '08', '09', '10', '11'];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final active = i == 5;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 14 + _data[i] * 104,
                  decoration: BoxDecoration(
                    color: active ? AppColors.green : AppColors.greenSoft,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(7)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_months[i], style: labelStyle()),
              ],
            ),
          );
        }),
      ),
    );
  }
}
