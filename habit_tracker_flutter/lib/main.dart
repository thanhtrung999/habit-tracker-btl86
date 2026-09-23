import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/viewmodels/habit_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final habitViewModel = HabitViewModel();
  await habitViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitViewModel>.value(value: habitViewModel),
      ],
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomic Habit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
