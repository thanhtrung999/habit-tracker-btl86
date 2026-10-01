import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/goal_record.dart';
import 'stacked_habit_deck.dart' show CategoryInfo;

class CalendarHeatmap extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<CategoryInfo> categories;
  final Map<String, GoalRecord> allRecords;
  final Function(DateTime) onSelectDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const CalendarHeatmap({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.categories,
    required this.allRecords,
    required this.onSelectDate,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final daysInMonth = AppDateUtils.getDaysInMonth(year, month);
    final firstDayOfMonth = DateTime(year, month, 1);
    // In Dart weekday: Mon=1, ..., Sun=7. We want Mon=0 ... Sun=6
    final startWeekdayOffset = (firstDayOfMonth.weekday - 1) % 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const weekdayHeaders = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    // Category colors in order
    final categoryColors = categories.map((c) => c.color).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Month Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng $month, $year',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onPrevMonth();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.black, width: 1.6),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onNextMonth();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.black, width: 1.6),
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Weekday Columns Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayHeaders.map((w) {
              final isWeekend = w == 'T7' || w == 'CN';
              return SizedBox(
                width: 38,
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isWeekend ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // 3. Calendar Days Grid with 5-Color Ring
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekdayOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekdayOffset) {
                return const SizedBox.shrink();
              }

              final dayNum = index - startWeekdayOffset + 1;
              final dayDate = DateTime(year, month, dayNum);
              final dateStr = AppDateUtils.formatDate(dayDate);
              final isToday = AppDateUtils.isToday(dateStr);
              final isSelected = dateStr == AppDateUtils.formatDate(selectedDate);
              final isFuture = dayDate.isAfter(today);

              // Compute completion state for each category on this specific day
              final completedStates = categories.map((cat) {
                if (isFuture) return false;
                final scheduled = cat.goals.where((g) => g.isScheduledForDate(dayDate)).toList();
                if (scheduled.isEmpty) return false;
                return scheduled.every((g) => allRecords['${g.id}_$dateStr']?.completed == true);
              }).toList();

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectDate(dayDate);
                },
                child: Center(
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: CustomPaint(
                      painter: _MultiCategoryRingPainter(
                        completedStates: completedStates,
                        categoryColors: categoryColors,
                        isSelected: isSelected,
                        isToday: isToday,
                        isFuture: isFuture,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isToday || isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : (isFuture
                                    ? const Color(0xFF94A3B8)
                                    : (isToday ? Colors.black : AppColors.textMain)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1.2,
            color: const Color(0xFFE2E8F0),
          ),

          const SizedBox(height: 10),

          // 4. Category Color Legend
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.5,
                    height: 8.5,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                  ),
                  const SizedBox(width: 4.5),
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that renders a 5-segment circular halo ring surrounding the day number.
/// Each segment corresponds to a parent category.
/// Completed categories glow in their signature Neo-Brutalist color.
/// Incomplete categories are left empty with a subtle light track.
class _MultiCategoryRingPainter extends CustomPainter {
  final List<bool> completedStates;
  final List<Color> categoryColors;
  final bool isSelected;
  final bool isToday;
  final bool isFuture;

  _MultiCategoryRingPainter({
    required this.completedStates,
    required this.categoryColors,
    required this.isSelected,
    required this.isToday,
    required this.isFuture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5.5) / 2;
    const strokeWidth = 2.8;
    const gapAngle = 0.14; // Radians between segments (~8 degrees)

    final n = categoryColors.isNotEmpty ? categoryColors.length : 5;
    final segmentSweep = (2 * math.pi) / n;
    final arcSweep = segmentSweep - gapAngle;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = isFuture ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0);

    // Draw the segments
    for (int i = 0; i < n; i++) {
      // Start from top (-pi / 2)
      final startAngle = -math.pi / 2 + (i * segmentSweep) + (gapAngle / 2);
      final isDone = i < completedStates.length && completedStates[i];

      if (isDone) {
        final colorPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = categoryColors[i];

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          arcSweep,
          false,
          colorPaint,
        );
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          arcSweep,
          false,
          trackPaint,
        );
      }
    }

    // Outer Selection Indicator: Sharp Neo-Brutalist solid outline
    if (isSelected) {
      final selectPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.black;

      canvas.drawCircle(center, radius + 2.5, selectPaint);
    } else if (isToday) {
      // Today subtle dark indicator dot below the number
      final todayDotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black;
      canvas.drawCircle(Offset(center.dx, center.dy + 11.5), 1.6, todayDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiCategoryRingPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isToday != isToday ||
        oldDelegate.isFuture != isFuture ||
        oldDelegate.completedStates != completedStates ||
        oldDelegate.categoryColors != categoryColors;
  }
}
