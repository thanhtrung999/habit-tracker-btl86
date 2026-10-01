import 'package:flutter/material.dart';

/// Single item representation in the Habit Icon picker
class HabitIconItem {
  final String id;
  final String label;
  final IconData icon;

  const HabitIconItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Curated icon collection for atomic habits across health, fitness,
/// study, work, mind, nutrition, hobbies, and finance.
class HabitIcons {
  static const List<HabitIconItem> all = [
    // Health & Fitness
    HabitIconItem(id: 'fitness', label: 'Tập gym', icon: Icons.fitness_center_rounded),
    HabitIconItem(id: 'run', label: 'Chạy bộ', icon: Icons.directions_run_rounded),
    HabitIconItem(id: 'walk', label: 'Đi bộ', icon: Icons.directions_walk_rounded),
    HabitIconItem(id: 'bike', label: 'Đạp xe', icon: Icons.directions_bike_rounded),
    HabitIconItem(id: 'swim', label: 'Bơi lội', icon: Icons.pool_rounded),
    HabitIconItem(id: 'sport', label: 'Thể thao', icon: Icons.sports_soccer_rounded),
    HabitIconItem(id: 'yoga', label: 'Yoga / Thiền', icon: Icons.self_improvement_rounded),
    HabitIconItem(id: 'heart', label: 'Sức khỏe', icon: Icons.favorite_rounded),

    // Nutrition & Lifestyle
    HabitIconItem(id: 'water', label: 'Uống nước', icon: Icons.water_drop_rounded),
    HabitIconItem(id: 'food', label: 'Ăn uống', icon: Icons.restaurant_rounded),
    HabitIconItem(id: 'apple', label: 'Trái cây', icon: Icons.apple_rounded),
    HabitIconItem(id: 'sleep', label: 'Giấc ngủ', icon: Icons.bedtime_rounded),
    HabitIconItem(id: 'alarm', label: 'Dậy sớm', icon: Icons.alarm_rounded),
    HabitIconItem(id: 'medication', label: 'Uống thuốc', icon: Icons.medication_rounded),
    HabitIconItem(id: 'no_drinks', label: 'Kiêng bia', icon: Icons.no_drinks_rounded),
    HabitIconItem(id: 'smoke_free', label: 'Bỏ thuốc lá', icon: Icons.smoke_free_rounded),
    HabitIconItem(id: 'coffee', label: 'Cà phê', icon: Icons.local_cafe_rounded),

    // Study & Mind
    HabitIconItem(id: 'book', label: 'Đọc sách', icon: Icons.menu_book_rounded),
    HabitIconItem(id: 'study', label: 'Học tập', icon: Icons.school_rounded),
    HabitIconItem(id: 'language', label: 'Ngoại ngữ', icon: Icons.translate_rounded),
    HabitIconItem(id: 'journal', label: 'Nhật ký', icon: Icons.edit_note_rounded),
    HabitIconItem(id: 'brain', label: 'Tư duy', icon: Icons.psychology_rounded),
    HabitIconItem(id: 'idea', label: 'Sáng tạo', icon: Icons.lightbulb_rounded),

    // Work, Focus & Finance
    HabitIconItem(id: 'work', label: 'Công việc', icon: Icons.laptop_chromebook_rounded),
    HabitIconItem(id: 'code', label: 'Lập trình', icon: Icons.code_rounded),
    HabitIconItem(id: 'task', label: 'Nhiệm vụ', icon: Icons.check_circle_outline_rounded),
    HabitIconItem(id: 'focus', label: 'Tập trung', icon: Icons.timer_rounded),
    HabitIconItem(id: 'savings', label: 'Tiết kiệm', icon: Icons.savings_rounded),
    HabitIconItem(id: 'finance', label: 'Tài chính', icon: Icons.attach_money_rounded),

    // Hobbies & Home
    HabitIconItem(id: 'music', label: 'Âm nhạc', icon: Icons.music_note_rounded),
    HabitIconItem(id: 'art', label: 'Hội họa', icon: Icons.palette_rounded),
    HabitIconItem(id: 'camera', label: 'Nhiếp ảnh', icon: Icons.photo_camera_rounded),
    HabitIconItem(id: 'plant', label: 'Trồng cây', icon: Icons.yard_rounded),
    HabitIconItem(id: 'pet', label: 'Thú cưng', icon: Icons.pets_rounded),
    HabitIconItem(id: 'clean', label: 'Dọn dẹp', icon: Icons.cleaning_services_rounded),
    HabitIconItem(id: 'star', label: 'Mục tiêu', icon: Icons.star_rounded),
  ];

  /// Resolves an IconData from an icon identifier, with smart fallback to title/category.
  static IconData getIcon(String? iconId, {String? title, String? category}) {
    if (iconId != null && iconId.trim().isNotEmpty) {
      final match = all.where((item) => item.id == iconId.trim());
      if (match.isNotEmpty) return match.first.icon;
    }

    final t = (title ?? '').toLowerCase();
    final c = (category ?? '').toLowerCase();

    if (t.contains('thể dục') || t.contains('gym') || t.contains('chạy') || c == 'sport' || c == 'thể thao') {
      return Icons.fitness_center_rounded;
    } else if (t.contains('sách') || t.contains('đọc') || c == 'study' || c == 'học tập') {
      return Icons.menu_book_rounded;
    } else if (t.contains('nước') || c == 'water') {
      return Icons.water_drop_rounded;
    } else if (t.contains('thiền') || t.contains('thư giãn') || c == 'mind' || c == 'tâm trí') {
      return Icons.self_improvement_rounded;
    } else if (t.contains('ngọt') || t.contains('ăn') || c == 'diet') {
      return Icons.restaurant_rounded;
    } else if (c == 'finance' || c == 'tài chính' || t.contains('tiền') || t.contains('tiết kiệm')) {
      return Icons.savings_rounded;
    } else if (c == 'work' || c == 'công việc' || t.contains('việc') || t.contains('code')) {
      return Icons.laptop_chromebook_rounded;
    }

    return Icons.star_rounded;
  }

  /// Get human-readable label for an icon id
  static String getLabel(String? iconId) {
    if (iconId == null || iconId.isEmpty) return 'Mặc định';
    final match = all.where((item) => item.id == iconId.trim());
    if (match.isNotEmpty) return match.first.label;
    return 'Mặc định';
  }

  /// Suggests a default icon for a given category
  static String getDefaultIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'sức khỏe':
        return 'heart';
      case 'sport':
      case 'thể thao':
        return 'fitness';
      case 'study':
      case 'học tập':
        return 'book';
      case 'work':
      case 'công việc':
        return 'work';
      case 'mind':
      case 'tâm trí':
        return 'yoga';
      case 'finance':
      case 'tài chính':
        return 'savings';
      case 'water':
      case 'nước':
        return 'water';
      case 'diet':
      case 'ăn uống':
        return 'food';
      default:
        return 'star';
    }
  }
}
