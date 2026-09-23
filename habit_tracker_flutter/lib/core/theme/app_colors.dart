import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette: Sage Green, Forest & Warm Neutrals
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primarySubtle = Color(0xFFD8F3DC);
  static const Color primaryDark = Color(0xFF1B4332);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardCompleted = Color(0xFFF1F5F9);
  static const Color elevated = Color(0xFFF1F5F9);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderCompleted = Color(0xFFCBD5E1);

  // Typography
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Categories
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleBg = Color(0xFFF5F3FF);

  // Streak Milestones
  static const Color streakStarter = Color(0xFF10B981); // Starter (< 5 days)
  static const Color streakOrange = Color(0xFFF97316);  // >= 5 days
  static const Color streakRed = Color(0xFFEF4444);     // >= 10 days
  static const Color streakPurple = Color(0xFF8B5CF6);  // >= 30 days
  static const Color streakPastel = Color(0xFF0D9488);  // >= 60 days
  static const Color streakGold = Color(0xFFD97706);    // >= 100 days
  static const Color streakRuby = Color(0xFFDB2777);    // >= 200 days
  static const Color streakDiamond = Color(0xFF4F46E5); // >= 365 days

  // Category Color Map
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'sức khỏe':
        return const Color(0xFF10B981);
      case 'study':
      case 'học tập':
        return const Color(0xFF3B82F6);
      case 'work':
      case 'công việc':
        return const Color(0xFFF59E0B);
      case 'finance':
      case 'tài chính':
        return const Color(0xFF0D9488);
      case 'mind':
      case 'tâm trí':
      case 'phát triển':
        return const Color(0xFF8B5CF6);
      default:
        return primary;
    }
  }

  static Color getCategoryBg(String category) {
    return getCategoryColor(category).withAlpha(35);
  }
}
