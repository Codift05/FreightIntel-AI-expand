import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import 'settings_repository.dart';

/// Log aktivitas: login & perubahan data (FR-USR-06).
class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static String _tanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
  static String _jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final list = SettingsRepository.instance.activity;
    // Kelompokkan per tanggal supaya mudah dibaca.
    final groups = <String, List<ActivityEntry>>{};
    for (final e in list) {
      groups.putIfAbsent(_tanggal(e.waktu), () => []).add(e);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader('Log aktivitas',
                subtitle: '${list.length} kejadian terakhir'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  for (final g in groups.entries) ...[
                    Text(g.key, style: numStyle(size: 14)),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < g.value.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, color: AppColors.line),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    child: Text(_jam(g.value[i].waktu),
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${g.value[i].aktor} · ${g.value[i].aksi}',
                                            style: const TextStyle(
                                                color: AppColors.ink,
                                                fontSize: 13.5,
                                                fontWeight:
                                                    FontWeight.w600,
                                                height: 1.3)),
                                        const SizedBox(height: 2),
                                        Text(g.value[i].detail,
                                            style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 12,
                                                height: 1.35)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const DemoNote(
                      text:
                          'Log contoh. Saat backend aktif, setiap login dan perubahan data tercatat otomatis.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
