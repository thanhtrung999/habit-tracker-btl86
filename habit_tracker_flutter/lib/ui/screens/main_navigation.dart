import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/navigation/curved_scoop_nav_bar.dart';
import 'calendar_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    if (index == 0) {
      Provider.of<HabitViewModel>(context, listen: false).syncTodayDate();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        onNavigateToGoals: () => _switchTab(1),
      ),
      const GoalsScreen(),
      CalendarScreen(
        onNavigateToToday: () => _switchTab(0),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: CurvedScoopNavBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
            items: const [
              CurvedNavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_outlined,
              ),
              CurvedNavItem(
                label: 'My Habit',
                icon: Icons.bar_chart_rounded,
                selectedIcon: Icons.bar_chart_rounded,
              ),
              CurvedNavItem(
                label: 'Report',
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month_outlined,
              ),
              CurvedNavItem(
                label: 'User',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
