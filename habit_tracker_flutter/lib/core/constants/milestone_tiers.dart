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
      label: 'Huyền thoại (≥ 365 ngày)',
      color: Color(0xFF4F46E5),
      badgeBg: Color(0xFFEEF2FF),
      badgeBorder: Color(0xFFC7D2FE),
      icon: '💎',
      colorName: 'Kim Cương',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
    ),
    MilestoneTier(
      minDays: 200,
      nextDays: 365,
      label: 'Siêu Kỷ Luật (≥ 200 ngày)',
      color: Color(0xFFDB2777),
      badgeBg: Color(0xFFFDF2F8),
      badgeBorder: Color(0xFFFBCFE8),
      icon: '💖',
      colorName: 'Hồng Ngọc',
      gradientColors: [Color(0xFFDB2777), Color(0xFFF43F5E)],
    ),
    MilestoneTier(
      minDays: 100,
      nextDays: 200,
      label: 'Bậc Thầy (≥ 100 ngày)',
      color: Color(0xFFD97706),
      badgeBg: Color(0xFFFFFBEB),
      badgeBorder: Color(0xFFFDE68A),
      icon: '🟡',
      colorName: 'Vàng Kim',
      gradientColors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    ),
    MilestoneTier(
      minDays: 60,
      nextDays: 100,
      label: 'Kiên Định (≥ 60 ngày)',
      color: Color(0xFF0D9488),
      badgeBg: Color(0xFFF0FDFA),
      badgeBorder: Color(0xFF99F6E4),
      icon: '🩵',
      colorName: 'Pastel Teal',
      gradientColors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
    MilestoneTier(
      minDays: 30,
      nextDays: 60,
      label: 'Thói Quen Thép (≥ 30 ngày)',
      color: Color(0xFF8B5CF6),
      badgeBg: Color(0xFFF5F3FF),
      badgeBorder: Color(0xFFDDD6FE),
      icon: '🟣',
      colorName: 'Màu Tím',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    ),
    MilestoneTier(
      minDays: 10,
      nextDays: 30,
      label: 'Quyết Tâm (≥ 10 ngày)',
      color: Color(0xFFEF4444),
      badgeBg: Color(0xFFFEF2F2),
      badgeBorder: Color(0xFFFECACA),
      icon: '🔴',
      colorName: 'Màu Đỏ',
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    MilestoneTier(
      minDays: 5,
      nextDays: 10,
      label: 'Bắt Nhịp (≥ 5 ngày)',
      color: Color(0xFFF97316),
      badgeBg: Color(0xFFFFF7ED),
      badgeBorder: Color(0xFFFED7AA),
      icon: '🟠',
      colorName: 'Màu Cam',
      gradientColors: [Color(0xFFF97316), Color(0xFFEA580C)],
    ),
    MilestoneTier(
      minDays: 0,
      nextDays: 5,
      label: 'Khởi Đầu (< 5 ngày)',
      color: Color(0xFF10B981),
      badgeBg: Color(0xFFECFDF5),
      badgeBorder: Color(0xFFA7F3D0),
      icon: '🟢',
      colorName: 'Xanh Lá',
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
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
