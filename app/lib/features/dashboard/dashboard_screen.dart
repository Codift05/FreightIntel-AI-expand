import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/logo_mark.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Row(
            children: [
              const LogoMark(size: 34),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, Owner',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy)),
                    Text('Ringkasan keuangan',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.navy, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _PeriodChips(),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'REVENUE',
                      value: 'Rp 3,2 M',
                      color: AppColors.navy)),
              SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: 'COST', value: 'Rp 2,4 M', color: AppColors.loss)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'PROFIT',
                      value: 'Rp 789 jt',
                      color: AppColors.green)),
              SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: 'MARGIN', value: '24,6%', color: AppColors.navy)),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue vs Cost',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.navy)),
                SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: Center(
                    child: Text('Grafik (placeholder)',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: _MiniCard(
                      label: 'Piutang',
                      value: 'Rp 636 jt',
                      sub: 'Outstanding')),
              SizedBox(width: 12),
              Expanded(
                  child: _MiniCard(
                      label: 'Hutang', value: 'Rp 1,8 M', sub: 'Outstanding')),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Angka contoh — belum terhubung data.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

Widget _card({required Widget child}) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(_items[i],
                  style: TextStyle(
                      color: active ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label, value, sub;
  const _MiniCard(
      {required this.label, required this.value, required this.sub});
  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          Text(sub,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}
