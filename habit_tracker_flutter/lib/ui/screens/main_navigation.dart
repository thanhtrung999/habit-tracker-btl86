import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'calendar_screen.dart';
import 'goals_screen.dart';
import 'today_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        onNavigateToGoals: () => _switchTab(2),
      ),
      CalendarScreen(
        onNavigateToToday: () => _switchTab(0),
      ),
      const GoalsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _switchTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primarySubtle,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined, size: 24),
                selectedIcon: Icon(Icons.today_rounded, size: 24, color: AppColors.primary),
                label: 'Hôm nay',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined, size: 24),
                selectedIcon: Icon(Icons.calendar_month_rounded, size: 24, color: AppColors.primary),
                label: 'Lịch & Tiến trình',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_outlined, size: 24),
                selectedIcon: Icon(Icons.track_changes_rounded, size: 24, color: AppColors.primary),
                label: 'Mục tiêu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
