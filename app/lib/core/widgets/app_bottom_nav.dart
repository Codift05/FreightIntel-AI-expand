import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bottom nav mengambang (pill) + FAB hijau di tengah.
class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onFab;

  const AppBottomNav({
    super.key,
    required this.index,
    required this.onSelect,
    required this.onFab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              _item(0, Icons.grid_view_rounded, 'Dashboard'),
              _item(1, Icons.local_shipping_rounded, 'Shipments'),
              _FabButton(onTap: onFab),
              _item(2, Icons.account_balance_wallet_rounded, 'Finance'),
              _item(3, Icons.auto_awesome_rounded, 'Insight'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final active = i == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 22,
                color: active ? AppColors.green : AppColors.muted),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.greenInk : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FabButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
