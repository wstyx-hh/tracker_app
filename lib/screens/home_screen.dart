import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'transactions_screen.dart';
import 'statistics_screen.dart';
import 'budget_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;
  
  final List<Widget> _screens = [
    const TransactionsScreen(),
    const StatisticsScreen(),
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Transactions',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Statistics',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Budget',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 65,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.transparent,
            indicatorColor: theme.colorScheme.primaryContainer.withOpacity(0.7),
            destinations: _destinations,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 400),
          ),
        ),
      ),
    );
  }
}
