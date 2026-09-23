import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_flutter/core/constants/milestone_tiers.dart';
import 'package:habit_tracker_flutter/core/utils/date_utils.dart';
import 'package:habit_tracker_flutter/data/models/day_progress.dart';
import 'package:habit_tracker_flutter/data/models/goal.dart';
import 'package:habit_tracker_flutter/data/models/goal_record.dart';

void main() {
  group('Goal Model Tests', () {
    test('isScheduledForDate handles daily (all) and custom weekdays', () {
      final dailyGoal = Goal(
        id: '1',
        title: 'Uống nước',
        targetFrequency: 'all',
        createdAt: DateTime(2026, 1, 1),
      );

      final date = DateTime(2026, 9, 23); // Wednesday (weekday 3)
      expect(dailyGoal.isScheduledForDate(date), isTrue);

      final customGoal = Goal(
        id: '2',
        title: 'Chạy bộ',
        targetFrequency: 'custom',
        weekdays: const [1, 3, 5], // Mon, Wed, Fri
        createdAt: DateTime(2026, 1, 1),
      );

      expect(customGoal.isScheduledForDate(DateTime(2026, 9, 23)), isTrue); // Wed
      expect(customGoal.isScheduledForDate(DateTime(2026, 9, 22)), isFalse); // Tue
    });

    test('toMap and fromMap serialize and deserialize accurately', () {
      final goal = Goal(
        id: 'test_1',
        title: 'Đọc sách',
        description: '20 trang mỗi ngày',
        category: 'study',
        color: '#10B981',
        targetFrequency: 'all',
        weekdays: const [0, 1, 2, 3, 4, 5, 6],
        targetCount: 20,
        unit: 'trang',
        createdAt: DateTime(2026, 9, 20),
      );

      final map = goal.toMap();
      final restored = Goal.fromMap(map);

      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.targetCount, 20);
      expect(restored.unit, 'trang');
    });
  });

  group('GoalRecord Model Tests', () {
    test('GoalRecord serialization', () {
      final record = GoalRecord(
        id: 'g1_2026-09-23',
        goalId: 'g1',
        date: '2026-09-23',
        completed: true,
        currentCount: 4,
        note: 'Đã hoàn thành xuất sắc!',
        updatedAt: DateTime(2026, 9, 23, 12, 0),
      );

      final map = record.toMap();
      final restored = GoalRecord.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.completed, isTrue);
      expect(restored.currentCount, 4);
      expect(restored.note, 'Đã hoàn thành xuất sắc!');
    });
  });

  group('Milestone Tier Tests', () {
    test('Calculates milestone tiers accurately by streak days', () {
      expect(MilestoneConstants.getTier(0).colorName, 'Xanh Lá');
      expect(MilestoneConstants.getTier(4).colorName, 'Xanh Lá');
      expect(MilestoneConstants.getTier(5).colorName, 'Màu Cam');
      expect(MilestoneConstants.getTier(10).colorName, 'Màu Đỏ');
      expect(MilestoneConstants.getTier(30).colorName, 'Màu Tím');
      expect(MilestoneConstants.getTier(60).colorName, 'Pastel Teal');
      expect(MilestoneConstants.getTier(100).colorName, 'Vàng Kim');
      expect(MilestoneConstants.getTier(200).colorName, 'Hồng Ngọc');
      expect(MilestoneConstants.getTier(365).colorName, 'Kim Cương');
      expect(MilestoneConstants.getTier(500).colorName, 'Kim Cương');
    });
  });

  group('DayProgress Model Tests', () {
    test('isPerfect returns true when total > 0 and percent == 100', () {
      const perfect = DayProgress(date: '2026-09-23', total: 4, completed: 4, percent: 100);
      expect(perfect.isPerfect, isTrue);
      expect(perfect.isPartial, isFalse);

      const partial = DayProgress(date: '2026-09-23', total: 4, completed: 2, percent: 50);
      expect(partial.isPerfect, isFalse);
      expect(partial.isPartial, isTrue);
    });
  });

  group('DateUtils Tests', () {
    test('formatDate and parseDate round-trip correctly', () {
      final date = DateTime(2026, 9, 23);
      final formatted = AppDateUtils.formatDate(date);
      expect(formatted, '2026-09-23');

      final parsed = AppDateUtils.parseDate(formatted);
      expect(parsed.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 23);
    });
  });
}
