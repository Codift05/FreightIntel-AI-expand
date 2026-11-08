import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Warna status shipment: selesai = hijau, dalam proses = amber,
/// awal = netral, batal = merah.
({Color fg, Color bg}) statusColors(String status) {
  switch (status) {
    case 'Completed':
    case 'Delivered':
      return (fg: AppColors.greenInk, bg: AppColors.greenSoft);
    case 'In Transit':
    case 'Arrived':
    case 'Customs':
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
    case 'Cancelled':
      return (fg: AppColors.loss, bg: AppColors.lossSoft);
    default: // Booking
      return (fg: AppColors.inkSoft, bg: AppColors.surfaceAlt);
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: c.bg, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(status,
          style: TextStyle(
              color: c.fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
