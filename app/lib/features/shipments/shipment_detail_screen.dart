import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/illustrations.dart';
import '../../core/widgets/app_card.dart';
import 'shipment_repository.dart';
import 'status_chip.dart';

/// Detail shipment: identitas, P&L, timeline status, rincian revenue/cost,
/// dan custom field (PRD FR-SHP-04, FR-PRF). Data demo.
class ShipmentDetailScreen extends StatelessWidget {
  final Shipment s;
  const ShipmentDetailScreen(this.s, {super.key});

  int get _rev => _num(s.revenue);
  int get _profit => _num(s.profit);
  int get _cost => _rev - _profit;
  double get _margin => _rev == 0 ? 0 : _profit / _rev * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(s.id, style: numStyle(size: 17)),
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2, color: AppColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.edit_2, color: AppColors.ink),
            tooltip: 'Edit shipment',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit shipment: segera')),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _header(),
          const SizedBox(height: 16),
          _pnl(),
          const SizedBox(height: 20),
          _title('Status pengiriman'),
          const SizedBox(height: 10),
          _Timeline(current: s.status),
          const SizedBox(height: 20),
          _title('Rincian revenue'),
          const SizedBox(height: 10),
          _items(_split(_rev, const ['Freight charge', 'Handling', 'Dokumen & lain'],
              const ['Paid', 'Partial', 'Unpaid']), AppColors.greenInk),
          const SizedBox(height: 16),
          _title('Rincian cost'),
          const SizedBox(height: 10),
          _items(_split(_cost, const ['Vendor utama', 'Trucking', 'Bea & retribusi'],
              const ['Paid', 'Unpaid', 'Paid']), AppColors.loss),
          const SizedBox(height: 20),
          _title('Detail'),
          const SizedBox(height: 10),
          _customFields(),
          const SizedBox(height: 16),
          const Text('Rincian contoh, belum terhubung data.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _header() => AppCard(
        color: AppColors.greenSoft,
        shadow: AppShadows.soft,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Image.asset(Illus.mode(s.type), fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.client, style: numStyle(size: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(IconsaxPlusBold.routing,
                        size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(s.route,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.inkSoft))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    StatusChip(s.status),
                    const SizedBox(width: 8),
                    Text(s.type, style: labelStyle(color: AppColors.greenInk)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _pnl() {
    final loss = _profit < 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Laba kotor', style: labelStyle()),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${loss ? '-' : ''}Rp ${_profit.abs()} jt',
                  style: numStyle(
                      size: 28, color: loss ? AppColors.loss : AppColors.green)),
              const SizedBox(width: 10),
              Text('Margin ${_margin.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 24, color: AppColors.line),
          Row(
            children: [
              Expanded(child: _pnlCol('Revenue', 'Rp $_rev jt', AppColors.ink)),
              Container(width: 1, height: 34, color: AppColors.line),
              Expanded(child: _pnlCol('Cost', 'Rp $_cost jt', AppColors.loss)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pnlCol(String label, String value, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: labelStyle()),
          const SizedBox(height: 4),
          Text(value, style: numStyle(size: 17, color: c)),
        ],
      );

  Widget _title(String t) => Text(t, style: numStyle(size: 15));

  Widget _items(List<_Item> items, Color accent) => AppCard(
        shadow: AppShadows.soft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(items[i].label,
                            style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600))),
                    _payChip(items[i].pay),
                    const SizedBox(width: 10),
                    Text('Rp ${items[i].amount} jt',
                        style: numStyle(size: 14, color: accent)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _payChip(String pay) {
    final (Color fg, Color bg) = switch (pay) {
      'Paid' => (AppColors.greenInk, AppColors.greenSoft),
      'Partial' => (AppColors.warning, AppColors.warningSoft),
      _ => (AppColors.loss, AppColors.lossSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(pay,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _customFields() {
    const fields = {
      'No. BL': 'MBL-2610-0291',
      'Container': '1 x 40ft HC',
      'Incoterm': 'CIF',
      'ETD': '12 Okt 2026',
      'ETA': '28 Okt 2026',
    };
    return AppCard(
      shadow: AppShadows.soft,
      child: Column(
        children: [
          for (final e in fields.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13))),
                  Text(e.value,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- util ---
  static int _num(String s) {
    final neg = s.contains('-');
    final d = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return neg ? -d : d;
  }

  List<_Item> _split(int total, List<String> labels, List<String> pays) {
    final a = (total * 0.6).round();
    final b = (total * 0.25).round();
    final c = total - a - b;
    final amts = [a, b, c];
    return [
      for (var i = 0; i < 3; i++) _Item(labels[i], amts[i], pays[i]),
    ];
  }
}

class _Item {
  final String label;
  final int amount;
  final String pay;
  _Item(this.label, this.amount, this.pay);
}

/// Timeline status vertikal (selesai = centang hijau, sekarang = titik hijau,
/// berikutnya = abu).
class _Timeline extends StatelessWidget {
  final String current;
  const _Timeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final idx = kShipmentStatuses.indexOf(current).clamp(0, 99);
    return AppCard(
      shadow: AppShadows.soft,
      child: Column(
        children: [
          for (var i = 0; i < kShipmentStatuses.length; i++)
            _row(i, idx, i == kShipmentStatuses.length - 1),
        ],
      ),
    );
  }

  Widget _row(int i, int idx, bool last) {
    final done = i < idx;
    final active = i == idx;
    final color = (done || active) ? AppColors.green : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? AppColors.green : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : (active
                        ? Center(
                            child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle)))
                        : null),
              ),
              if (!last)
                Expanded(
                  child: Container(
                      width: 2,
                      color: done ? AppColors.green : AppColors.line),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(top: 1, bottom: last ? 0 : 16),
            child: Text(
              kShipmentStatuses[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: (done || active) ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
