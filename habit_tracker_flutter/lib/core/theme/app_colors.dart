import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  // Modern Flat Design - Clean Crisp White & Light Slate Palette
  static Color get background => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC); // Deep Slate vs Slate 50
  static Color get surface => isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF); // Slate 800 vs Pure White
  static Color get card => isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get cardCompleted => isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color get cardBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get border => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get borderCompleted => isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
  static Color get bottomNav => isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);

  // Segmented Control Flat Colors
  static Color get segmentBg => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get segmentActive => isDark ? const Color(0xFF334155) : const Color(0xFFFFFFFF);
  static Color get segmentBorder => isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);

  // Typography - High Contrast, Deep Crisp Legibility
  static Color get textMain => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textMuted => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textLight => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Brand Accents (Flat, vibrant)
  static const Color primary = Color(0xFF2563EB); // Flat Royal Blue (Blue 600)
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static Color get primarySubtle => isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
  static Color get elevated => isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static const Color success = Color(0xFF059669); // Flat Emerald (Emerald 600)
  static Color get successBg => isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706); // Flat Amber (Amber 600)
  static Color get warningBg => isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626); // Flat Coral Red (Red 600)
  static Color get dangerBg => isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
  static const Color purple = Color(0xFF7C3AED); // Flat Violet (Violet 600)
  static Color get purpleBg => isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);

  // Flat Flaming Streak Accents (Light/Dark Mode High-Contrast)
  static const Color flameOrange = Color(0xFFEA580C);
  static const Color flameAmber = Color(0xFFD97706);
  static const Color flameRed = Color(0xFFDC2626);
  static Color get flameBg => isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED);

  // Category Color Map (Neo-Brutalist Pop Palette matching reference)
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'sức khỏe':
      case 'thể dục':
        return const Color(0xFF4ADE80); // Vibrant Green
      case 'sport':
      case 'thể thao':
        return const Color(0xFFFBBF24); // Warm Amber
      case 'study':
      case 'học tập':
      case 'sách':
        return const Color(0xFF38BDF8); // Sky Blue
      case 'mind':
      case 'tâm trí':
      case 'thiền':
        return const Color(0xFFA78BFA); // Lavender Purple
      case 'work':
      case 'công việc':
        return const Color(0xFFF472B6); // Pop Pink
      case 'finance':
      case 'tài chính':
        return const Color(0xFFFACC15); // Vibrant Yellow
      case 'water':
      case 'nước':
        return const Color(0xFF38BDF8); // Sky Blue
      case 'diet':
      case 'ăn uống':
      case 'hạn chế':
        return const Color(0xFFFB7185); // Pop Pink
      default:
        return const Color(0xFFFB923C); // Orange
    }
  }

  static Color getCategoryBg(String category) {
    return getCategoryColor(category).withAlpha(35);
  }
}
