import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/day_progress.dart';

class CalendarHeatmap extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<String, DayProgress> monthProgress;
  final Function(DateTime) onSelectDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const CalendarHeatmap({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.monthProgress,
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

    const weekdayHeaders = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng $month / $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.textMain),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: onPrevMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: onNextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekday columns header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayHeaders.map((w) {
              return SizedBox(
                width: 38,
                child: Center(
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekdayOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
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
              final progress = monthProgress[dateStr];
              final isToday = AppDateUtils.isToday(dateStr);
              final isSelected = dateStr == AppDateUtils.formatDate(selectedDate);

              Color dotColor = Colors.transparent;
              if (progress != null) {
                if (progress.isPerfect) {
                  dotColor = AppColors.primary;
                } else if (progress.isPartial) {
                  dotColor = AppColors.primaryLight;
                }
              }

              return InkWell(
                onTap: () => onSelectDate(dayDate),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySubtle
                        : (isToday ? AppColors.elevated : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : (isToday ? Border.all(color: AppColors.borderCompleted) : null),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryDark
                              : (isToday ? AppColors.primary : AppColors.textMain),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Dot indicator
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.primary, 'Hoàn thành (100%)'),
              const SizedBox(width: 14),
              _buildLegendItem(AppColors.primaryLight, 'Một phần'),
              const SizedBox(width: 14),
              _buildLegendItem(AppColors.border, 'Chưa có'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
