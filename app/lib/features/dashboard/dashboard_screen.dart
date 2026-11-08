import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                    color: AppColors.greenSoft, shape: BoxShape.circle),
                child: Image.asset(Illus.avatarOwner, fit: BoxFit.cover),
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
              Pressable(
                semanticLabel: 'Notifikasi',
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft),
                  child: const Icon(IconsaxPlusBold.notification,
                      color: AppColors.ink, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _PeriodChips(),
          const SizedBox(height: 18),
          const HighlightCard(
            label: 'Profit bulan ini',
            value: 'Rp 789 jt',
            sub: 'Margin 24,6% · naik dari bulan lalu',
            progress: 0.62,
            progressLabel: '+12%',
          ).animate().fadeIn(duration: 380.ms).slideY(
              begin: 0.10, end: 0, curve: kEaseOut),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                  child: StatTile(
                      label: 'Revenue',
                      value: 'Rp 3,2',
                      unit: 'M',
                      icon: IconsaxPlusBold.trend_up,
                      trend: [2.4, 2.6, 2.5, 2.8, 2.9, 3.0, 3.2],
                      delta: '8,2%',
                      deltaUp: true,
                      deltaGood: true,
                      sparkColor: AppColors.green)),
              SizedBox(width: 14),
              Expanded(
                  child: StatTile(
                      label: 'Cost',
                      value: 'Rp 2,4',
                      unit: 'M',
                      valueColor: AppColors.loss,
                      icon: IconsaxPlusBold.trend_down,
                      trend: [2.1, 2.2, 2.15, 2.3, 2.35, 2.3, 2.4],
                      delta: '3,1%',
                      deltaUp: true,
                      deltaGood: false,
                      sparkColor: AppColors.loss)),
            ],
          ).animate(delay: 90.ms).fadeIn(duration: 380.ms).slideY(
              begin: 0.10, end: 0, curve: kEaseOut),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                  child: StatTile(
                      label: 'Piutang',
                      value: 'Rp 636',
                      unit: 'jt',
                      icon: IconsaxPlusBold.receive_square,
                      trend: [720, 700, 690, 672, 658, 645, 636],
                      delta: '4,0%',
                      deltaUp: false,
                      deltaGood: true,
                      sparkColor: AppColors.green)),
              SizedBox(width: 14),
              Expanded(
                  child: StatTile(
                      label: 'Hutang',
                      value: 'Rp 1,8',
                      unit: 'M',
                      icon: IconsaxPlusBold.money_send,
                      trend: [2.4, 2.3, 2.2, 2.1, 2.0, 1.9, 1.8],
                      delta: '6,0%',
                      deltaUp: false,
                      deltaGood: true,
                      sparkColor: AppColors.green)),
            ],
          ).animate(delay: 150.ms).fadeIn(duration: 380.ms).slideY(
              begin: 0.10, end: 0, curve: kEaseOut),
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
                    Text('6 bulan', style: labelStyle()),
                  ],
                ),
                const SizedBox(height: 20),
                const _MiniBars(),
              ],
            ),
          ).animate(delay: 210.ms).fadeIn(duration: 380.ms).slideY(
              begin: 0.10, end: 0, curve: kEaseOut),
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
          child: Pressable(
            semanticLabel: _items[i],
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

/// Bar chart: label nilai + batang tumbuh beranimasi; bulan terakhir hijau.
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
                        fontSize: 11,
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
                ).animate().scaleY(
                      begin: 0,
                      end: 1,
                      alignment: Alignment.bottomCenter,
                      duration: 550.ms,
                      delay: (250 + i * 70).ms,
                      curve: kEaseOut,
                    ),
                const SizedBox(height: 8),
                Text(_months[i], style: labelStyle().copyWith(fontSize: 11)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
