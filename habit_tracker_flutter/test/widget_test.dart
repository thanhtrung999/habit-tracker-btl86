import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_flutter/core/constants/milestone_tiers.dart';
import 'package:habit_tracker_flutter/core/utils/date_utils.dart';
import 'package:habit_tracker_flutter/data/models/day_progress.dart';
import 'package:habit_tracker_flutter/data/models/goal.dart';
import 'package:habit_tracker_flutter/data/models/goal_record.dart';
import 'package:habit_tracker_flutter/ui/widgets/habit_card.dart';

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
      expect(MilestoneConstants.getTier(0).colorName, 'Đỏ Rực Lửa');
      expect(MilestoneConstants.getTier(6).colorName, 'Đỏ Rực Lửa');
      expect(MilestoneConstants.getTier(7).colorName, 'Cam Bốc Lửa');
      expect(MilestoneConstants.getTier(14).colorName, 'Vàng Hổ Phách');
      expect(MilestoneConstants.getTier(30).colorName, 'Hồng Ruby Neon');
      expect(MilestoneConstants.getTier(60).colorName, 'Xanh Lục Emerald');
      expect(MilestoneConstants.getTier(90).colorName, 'Xanh Lam Cyan');
      expect(MilestoneConstants.getTier(120).colorName, 'Xanh Sapphire');
      expect(MilestoneConstants.getTier(150).colorName, 'Tím Chàm Indigo');
      expect(MilestoneConstants.getTier(200).colorName, 'Tím Hoàng Gia');
      expect(MilestoneConstants.getTier(365).colorName, 'Kim Cương Đa Sắc');
      expect(MilestoneConstants.getTier(500).colorName, 'Kim Cương Đa Sắc');
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

  group('HabitCard Widget Tests', () {
    testWidgets('HabitCard displays title in header and omits redundant category/target note', (tester) async {
      final goal = Goal(
        id: 'g_water',
        title: 'Uống đủ nước',
        category: 'water',
        targetCount: 4,
        unit: 'ly',
        color: '#3B82F6',
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              goal: goal,
              streakDays: 3,
              showTopTab: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      // Title should be visible
      expect(find.text('Uống đủ nước'), findsOneWidget);
      // Streak flame count should be visible
      expect(find.text('3'), findsOneWidget);
      // Old category 'WATER' in metadata and '4 ly mỗi ngày' note should NOT be present
      expect(find.text('WATER'), findsNothing);
      expect(find.text('4 ly mỗi ngày'), findsNothing);
    });

    testWidgets('HabitCard completed displays HorizontalEnergyWaveBar with streak days and no strikethrough', (tester) async {
      final goal = Goal(
        id: 'g_water_comp',
        title: 'Uống đủ nước',
        category: 'water',
        targetCount: 4,
        unit: 'ly',
        color: '#3B82F6',
        createdAt: DateTime(2026, 1, 1),
      );
      final record = GoalRecord(
        id: 'r_comp',
        goalId: 'g_water_comp',
        date: '2026-09-29',
        completed: true,
        currentCount: 4,
        updatedAt: DateTime(2026, 9, 29),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              goal: goal,
              record: record,
              streakDays: 5,
              showTopTab: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      // Energy bar with percentage and days should be visible, milestone title removed
      expect(find.text('71%'), findsOneWidget);
      expect(find.text('(5/7 ngày)'), findsOneWidget);
      expect(find.text('MỐC 7 NGÀY'), findsNothing);

      // Verify title has NO strikethrough decoration
      final textWidget = tester.widget<Text>(find.text('Uống đủ nước'));
      expect(textWidget.style?.decoration, isNull);
    });
  });

  group('Milestone Filter & Clear Records Tests', () {
    test('Milestone tiers sorting and partitioning', () {
      final allTiersAsc = MilestoneConstants.tiers.reversed.toList();
      expect(allTiersAsc.first.minDays, 0);
      expect(allTiersAsc.last.minDays, 365);
      expect(allTiersAsc.length, 10);
    });
  });
}
