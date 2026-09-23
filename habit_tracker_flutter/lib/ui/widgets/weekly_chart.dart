import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/day_progress.dart';

class WeeklyChart extends StatelessWidget {
  final List<DayProgress> progressList;
  final String selectedDate;
  final Function(DateTime) onSelectDate;

  const WeeklyChart({
    super.key,
    required this.progressList,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Hiệu suất 7 ngày gần nhất',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Text(
                'Chạm để xem ngày',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: progressList.map((progress) {
              final date = AppDateUtils.parseDate(progress.date);
              final dayName = AppDateUtils.getDayName(date);
              final isSelected = progress.date == selectedDate;
              final isToday = AppDateUtils.isToday(progress.date);

              final percent = progress.percent;
              final barHeight = (percent / 100) * 80.0;

              Color barColor;
              if (progress.isPerfect) {
                barColor = AppColors.primary;
              } else if (progress.isPartial) {
                barColor = AppColors.primaryLight;
              } else {
                barColor = AppColors.border;
              }

              return InkWell(
                onTap: () => onSelectDate(date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySubtle.withAlpha(120) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryLight, width: 1.2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Percentage text
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Bar track container
                      Container(
                        width: 14,
                        height: 80,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          width: 14,
                          height: barHeight < 6 && percent > 0 ? 6 : barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: progress.isPerfect
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(60),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Day name
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isToday
                              ? AppColors.primary
                              : (isSelected ? AppColors.textMain : AppColors.textMuted),
                        ),
                      ),
                      // Day of month number
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? AppColors.primary : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
