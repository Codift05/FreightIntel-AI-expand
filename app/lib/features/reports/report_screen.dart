import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';

typedef _Period = ({
  String label,
  int pendapatan,
  int biaya,
  int kasMasuk,
  int kasKeluar,
  int saldoAwal,
  double tumbuh,
  List<({String nama, int jt})> rincianBiaya,
});

/// Laporan keuangan bulanan & tahunan + export (FR-RPT-01..05).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _tahunan = false;
  int _idx = 0;

  static const _bulanan = <_Period>[
    (
      label: 'Oktober 2026',
      pendapatan: 3400,
      biaya: 2610,
      kasMasuk: 2980,
      kasKeluar: 2440,
      saldoAwal: 1120,
      tumbuh: 12.4,
      rincianBiaya: [
        (nama: 'Trucking', jt: 920),
        (nama: 'Ocean & air freight', jt: 1040),
        (nama: 'Handling & gudang', jt: 310),
        (nama: 'Dokumen & bea', jt: 240),
        (nama: 'Operasional kantor', jt: 100),
      ],
    ),
    (
      label: 'September 2026',
      pendapatan: 3120,
      biaya: 2410,
      kasMasuk: 2760,
      kasKeluar: 2280,
      saldoAwal: 980,
      tumbuh: 6.1,
      rincianBiaya: [
        (nama: 'Trucking', jt: 780),
        (nama: 'Ocean & air freight', jt: 980),
        (nama: 'Handling & gudang', jt: 300),
        (nama: 'Dokumen & bea', jt: 250),
        (nama: 'Operasional kantor', jt: 100),
      ],
    ),
    (
      label: 'Agustus 2026',
      pendapatan: 2940,
      biaya: 2360,
      kasMasuk: 2610,
      kasKeluar: 2210,
      saldoAwal: 860,
      tumbuh: -2.3,
      rincianBiaya: [
        (nama: 'Trucking', jt: 740),
        (nama: 'Ocean & air freight', jt: 960),
        (nama: 'Handling & gudang', jt: 290),
        (nama: 'Dokumen & bea', jt: 270),
        (nama: 'Operasional kantor', jt: 100),
      ],
    ),
  ];

  static const _tahun = <_Period>[
    (
      label: '2026 (berjalan)',
      pendapatan: 31400,
      biaya: 24180,
      kasMasuk: 28900,
      kasKeluar: 23100,
      saldoAwal: 740,
      tumbuh: 18.6,
      rincianBiaya: [
        (nama: 'Trucking', jt: 8200),
        (nama: 'Ocean & air freight', jt: 10400),
        (nama: 'Handling & gudang', jt: 2900),
        (nama: 'Dokumen & bea', jt: 1880),
        (nama: 'Operasional kantor', jt: 800),
      ],
    ),
    (
      label: '2025',
      pendapatan: 26480,
      biaya: 21050,
      kasMasuk: 25100,
      kasKeluar: 20400,
      saldoAwal: 520,
      tumbuh: 9.2,
      rincianBiaya: [
        (nama: 'Trucking', jt: 7100),
        (nama: 'Ocean & air freight', jt: 9200),
        (nama: 'Handling & gudang', jt: 2500),
        (nama: 'Dokumen & bea', jt: 1650),
        (nama: 'Operasional kantor', jt: 600),
      ],
    ),
  ];

  List<_Period> get _list => _tahunan ? _tahun : _bulanan;
  _Period get _p => _list[_idx.clamp(0, _list.length - 1)];

  void _switchMode(bool tahunan) =>
      setState(() => (_tahunan = tahunan, _idx = 0));

  void _openExport() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Export ${_p.label}', style: numStyle(size: 16)),
              const SizedBox(height: 6),
              const Text(
                  'File dibuat di server. Fitur ini aktif setelah backend siap.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const SizedBox(height: 16),
              _exportRow(ctx, IconsaxPlusLinear.document_text, 'PDF',
                  'Laporan siap cetak'),
              const SizedBox(height: 10),
              _exportRow(ctx, IconsaxPlusLinear.document_download, 'Excel',
                  'Rincian baris per transaksi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exportRow(
          BuildContext ctx, IconData icon, String title, String sub) =>
      Pressable(
        onTap: () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Export $title aktif setelah backend laporan tersambung.')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.tile),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: numStyle(size: 14)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(IconsaxPlusLinear.arrow_right_3,
                  size: 16, color: AppColors.muted),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final laba = p.pendapatan - p.biaya;
    final margin = p.pendapatan == 0 ? 0.0 : laba * 100 / p.pendapatan;
    final saldoAkhir = p.saldoAwal + p.kasMasuk - p.kasKeluar;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              'Laporan keuangan',
              subtitle: _tahunan ? 'Ringkasan tahunan' : 'Ringkasan bulanan',
              action: HeaderAction(
                icon: IconsaxPlusLinear.export_1,
                label: 'Export laporan',
                onTap: _openExport,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _modeSwitch(),
                  const SizedBox(height: 12),
                  _periodChips(),
                  const SizedBox(height: 18),
                  _hero(laba, margin),
                  const SizedBox(height: 24),
                  Text('Laba rugi', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _line('Pendapatan', p.pendapatan),
                        const Divider(height: 1, color: AppColors.line),
                        _line('Biaya', -p.biaya),
                        const Divider(height: 1, color: AppColors.line),
                        _line('Laba kotor', laba, strong: true),
                        const Divider(height: 1, color: AppColors.line),
                        _lineText(
                            'Margin', '${margin.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Arus kas', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _line('Saldo awal', p.saldoAwal),
                        const Divider(height: 1, color: AppColors.line),
                        _line('Kas masuk', p.kasMasuk),
                        const Divider(height: 1, color: AppColors.line),
                        _line('Kas keluar', -p.kasKeluar),
                        const Divider(height: 1, color: AppColors.line),
                        _line('Saldo akhir', saldoAkhir, strong: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Biaya per kategori', style: numStyle(size: 15)),
                  const SizedBox(height: 10),
                  _costBars(p),
                  const SizedBox(height: 16),
                  const DemoNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeSwitch() => Row(
        children: [
          for (final (i, label) in ['Bulanan', 'Tahunan'].indexed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pressable(
                onTap: () => _switchMode(i == 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: kEaseOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_tahunan ? 1 : 0) == i
                        ? AppColors.ink
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow:
                        (_tahunan ? 1 : 0) == i ? null : AppShadows.soft,
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: (_tahunan ? 1 : 0) == i
                              ? Colors.white
                              : AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      );

  Widget _periodChips() => SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final (i, p) in _list.indexed)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pressable(
                  onTap: () => setState(() => _idx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: kEaseOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _idx == i
                          ? AppColors.lime
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: _idx == i ? null : AppShadows.soft,
                    ),
                    child: Text(p.label,
                        style: TextStyle(
                            color:
                                _idx == i ? AppColors.ink : AppColors.muted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _hero(int laba, double margin) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laba ${_p.label}',
                style: const TextStyle(
                    color: AppColors.onDark, fontSize: 12.5)),
            const SizedBox(height: 8),
            Text(_rp(laba), style: numStyle(size: 30, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_p.tumbuh >= 0
                            ? AppColors.greenBright
                            : AppColors.loss)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _p.tumbuh >= 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18,
                          color: _p.tumbuh >= 0
                              ? AppColors.greenBright
                              : AppColors.loss),
                      Text(
                          '${_p.tumbuh.abs().toStringAsFixed(1)}% vs periode lalu',
                          style: TextStyle(
                              color: _p.tumbuh >= 0
                                  ? AppColors.greenBright
                                  : AppColors.loss,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text('margin ${margin.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: AppColors.onDark, fontSize: 12)),
              ],
            ),
          ],
        ),
      );

  Widget _line(String label, int jt, {bool strong = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      fontWeight:
                          strong ? FontWeight.w700 : FontWeight.w500)),
            ),
            Text(_rp(jt),
                style: numStyle(
                    size: strong ? 15 : 13.5,
                    color: jt < 0 ? AppColors.loss : AppColors.ink)),
          ],
        ),
      );

  Widget _lineText(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500)),
            ),
            Text(value, style: numStyle(size: 13.5)),
          ],
        ),
      );

  Widget _costBars(_Period p) {
    final maks = p.rincianBiaya.fold<int>(1, (m, e) => e.jt > m ? e.jt : m);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in p.rincianBiaya)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.nama,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(_rp(e.jt), style: numStyle(size: 13)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: e.jt / maks,
                      minHeight: 8,
                      backgroundColor: AppColors.line,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Format ringkas: juta sampai 1000, selebihnya miliar 1 desimal.
  static String _rp(int jt) {
    final neg = jt < 0;
    final v = jt.abs();
    final s = v >= 1000
        ? 'Rp ${(v / 1000).toStringAsFixed(1)} M'
        : 'Rp $v jt';
    return neg ? '-$s' : s;
  }
}
