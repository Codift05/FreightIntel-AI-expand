import 'package:flutter/material.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../shipments/shipments_screen.dart';
import '../finance/finance_screen.dart';
import '../insight/insight_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    ShipmentsScreen(),
    FinanceScreen(),
    InsightScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onSelect: (v) => setState(() => _index = v),
        onFab: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tambah data — segera')),
        ),
      ),
    );
  }
}
