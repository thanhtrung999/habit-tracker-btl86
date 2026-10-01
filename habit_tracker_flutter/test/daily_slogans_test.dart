import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_flutter/core/constants/daily_slogans.dart';

void main() {
  group('DailySlogans Tests', () {
    test('Should have at least 100 slogans', () {
      expect(DailySlogans.slogans.length, greaterThanOrEqualTo(100));
    });

    test('All slogans should be unique and non-empty', () {
      final set = <String>{};
      for (final slogan in DailySlogans.slogans) {
        expect(slogan.trim().isNotEmpty, isTrue);
        expect(set.contains(slogan), isFalse, reason: 'Duplicate slogan found: "$slogan"');
        set.add(slogan);
      }
    });

    test('Different days should produce different slogans', () {
      final day1 = DateTime(2026, 10, 1);
      final day2 = DateTime(2026, 10, 2);
      final day3 = DateTime(2026, 10, 3);

      final slogan1 = DailySlogans.getSloganForDate(day1);
      final slogan2 = DailySlogans.getSloganForDate(day2);
      final slogan3 = DailySlogans.getSloganForDate(day3);

      expect(slogan1, isNot(equals(slogan2)));
      expect(slogan2, isNot(equals(slogan3)));
      expect(slogan1, isNot(equals(slogan3)));
    });

    test('Offset shuffling should cycle through slogans', () {
      final today = DateTime(2026, 10, 1);
      final slogan0 = DailySlogans.getSloganWithOffset(today, 0);
      final slogan1 = DailySlogans.getSloganWithOffset(today, 1);
      final slogan2 = DailySlogans.getSloganWithOffset(today, 2);

      expect(slogan0, isNot(equals(slogan1)));
      expect(slogan1, isNot(equals(slogan2)));
    });
  });
}
