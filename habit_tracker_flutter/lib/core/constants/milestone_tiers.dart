import 'package:flutter/material.dart';

class MilestoneTier {
  final int minDays;
  final int? nextDays;
  final String label;
  final Color color;
  final Color badgeBg;
  final Color badgeBorder;
  final String icon;
  final String colorName;
  final List<Color> gradientColors;

  const MilestoneTier({
    required this.minDays,
    required this.nextDays,
    required this.label,
    required this.color,
    required this.badgeBg,
    required this.badgeBorder,
    required this.icon,
    required this.colorName,
    required this.gradientColors,
  });
}

class MilestoneConstants {
  static const List<MilestoneTier> tiers = [
    MilestoneTier(
      minDays: 365,
      nextDays: null,
      label: 'Huyền Thoại (≥ 365 ngày)',
      color: Color(0xFF312E81),
      badgeBg: Color(0xFFEEF2FF),
      badgeBorder: Color(0xFFC7D2FE),
      icon: '🏆',
      colorName: 'Kim Cương Đa Sắc',
      gradientColors: [Color(0xFF312E81), Color(0xFF7C3AED), Color(0xFFFDE047)],
    ),
    MilestoneTier(
      minDays: 200,
      nextDays: 365,
      label: 'Vô Địch (≥ 200 ngày)',
      color: Color(0xFF7C3AED),
      badgeBg: Color(0xFFF5F3FF),
      badgeBorder: Color(0xFFDDD6FE),
      icon: '👑',
      colorName: 'Tím Hoàng Gia',
      gradientColors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
    ),
    MilestoneTier(
      minDays: 150,
      nextDays: 200,
      label: 'Bản Lĩnh (≥ 150 ngày)',
      color: Color(0xFF4F46E5),
      badgeBg: Color(0xFFEEF2FF),
      badgeBorder: Color(0xFFC7D2FE),
      icon: '🔮',
      colorName: 'Tím Chàm Indigo',
      gradientColors: [Color(0xFF4338CA), Color(0xFF6366F1)],
    ),
    MilestoneTier(
      minDays: 120,
      nextDays: 150,
      label: 'Kiên Cường (≥ 120 ngày)',
      color: Color(0xFF2563EB),
      badgeBg: Color(0xFFEFF6FF),
      badgeBorder: Color(0xFFBFDBFE),
      icon: '💎',
      colorName: 'Xanh Sapphire',
      gradientColors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
    ),
    MilestoneTier(
      minDays: 90,
      nextDays: 120,
      label: 'Bứt Phá (≥ 90 ngày)',
      color: Color(0xFF0891B2),
      badgeBg: Color(0xFFECFEFF),
      badgeBorder: Color(0xFFA5F3FC),
      icon: '🌊',
      colorName: 'Xanh Lam Cyan',
      gradientColors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
    ),
    MilestoneTier(
      minDays: 60,
      nextDays: 90,
      label: 'Kiên Định (≥ 60 ngày)',
      color: Color(0xFF059669),
      badgeBg: Color(0xFFECFDF5),
      badgeBorder: Color(0xFFA7F3D0),
      icon: '🌿',
      colorName: 'Xanh Lục Emerald',
      gradientColors: [Color(0xFF047857), Color(0xFF10B981)],
    ),
    MilestoneTier(
      minDays: 30,
      nextDays: 60,
      label: 'Thói Quen Thép (≥ 30 ngày)',
      color: Color(0xFFDB2777),
      badgeBg: Color(0xFFFDF2F8),
      badgeBorder: Color(0xFFFBCFE8),
      icon: '🌸',
      colorName: 'Hồng Ruby Neon',
      gradientColors: [Color(0xFFBE185D), Color(0xFFEC4899)],
    ),
    MilestoneTier(
      minDays: 14,
      nextDays: 30,
      label: 'Vững Vàng (≥ 14 ngày)',
      color: Color(0xFFD97706),
      badgeBg: Color(0xFFFFFBEB),
      badgeBorder: Color(0xFFFDE68A),
      icon: '⚡',
      colorName: 'Vàng Hổ Phách',
      gradientColors: [Color(0xFFB45309), Color(0xFFF59E0B)],
    ),
    MilestoneTier(
      minDays: 7,
      nextDays: 14,
      label: 'Tạo Đà (≥ 7 ngày)',
      color: Color(0xFFEA580C),
      badgeBg: Color(0xFFFFF7ED),
      badgeBorder: Color(0xFFFED7AA),
      icon: '💥',
      colorName: 'Cam Bốc Lửa',
      gradientColors: [Color(0xFFC2410C), Color(0xFFF97316)],
    ),
    MilestoneTier(
      minDays: 0,
      nextDays: 7,
      label: 'Khởi Động (< 7 ngày)',
      color: Color(0xFFDC2626),
      badgeBg: Color(0xFFFEF2F2),
      badgeBorder: Color(0xFFFECACA),
      icon: '🔥',
      colorName: 'Đỏ Rực Lửa',
      gradientColors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
    ),
  ];

  static MilestoneTier getTier(int streakDays) {
    for (final tier in tiers) {
      if (streakDays >= tier.minDays) {
        return tier;
      }
    }
    return tiers.last;
  }
}
