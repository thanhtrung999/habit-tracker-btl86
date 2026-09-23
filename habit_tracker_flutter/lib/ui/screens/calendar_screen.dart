import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/milestone_tiers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/weekly_chart.dart';

class CalendarScreen extends StatelessWidget {
  final VoidCallback onNavigateToToday;

  const CalendarScreen({
    super.key,
    required this.onNavigateToToday,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final tier = vm.currentTier;
    final selectedDateStr = vm.selectedDateStr;
    final selectedDayProgress = vm.dayProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch & Tiến Trình',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Cards Strip
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Chuỗi Hiện Tại',
                    value: '${vm.overallStreak} ngày',
                    icon: '🔥',
                    color: tier.color,
                    bgColor: tier.badgeBg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Danh Hiệu',
                    value: tier.icon,
                    subtext: tier.colorName,
                    icon: '🎖️',
                    color: tier.color,
                    bgColor: tier.badgeBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Month Heatmap
            CalendarHeatmap(
              currentMonth: vm.calendarMonth,
              selectedDate: vm.selectedDate,
              monthProgress: vm.monthProgress,
              onSelectDate: (date) {
                vm.selectDate(date);
              },
              onPrevMonth: () => vm.changeCalendarMonth(-1),
              onNextMonth: () => vm.changeCalendarMonth(1),
            ),
            const SizedBox(height: 16),
            // Selected Day Quick Action Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selectedDayProgress.isPerfect
                          ? AppColors.successBg
                          : AppColors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        selectedDayProgress.isPerfect ? Icons.check_circle : Icons.event_note,
                        color: selectedDayProgress.isPerfect ? AppColors.success : AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.getFriendlyDateString(selectedDateStr),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedDayProgress.completed}/${selectedDayProgress.total} thói quen (${selectedDayProgress.percent}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNavigateToToday,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Xem ngày', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 7-day Performance Chart
            WeeklyChart(
              progressList: vm.weeklyProgress,
              selectedDate: selectedDateStr,
              onSelectDate: (date) {
                vm.selectDate(date);
              },
            ),
            const SizedBox(height: 20),
            // Milestone Tiers List
            const Text(
              'Cột Mốc & Danh Hiệu',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MilestoneConstants.tiers.length,
              itemBuilder: (context, index) {
                final t = MilestoneConstants.tiers[index];
                final isCurrent = t == tier;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrent ? t.badgeBg : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent ? t.badgeBorder : AppColors.border,
                      width: isCurrent ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(t.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                color: isCurrent ? t.color : AppColors.textMain,
                              ),
                            ),
                            Text(
                              'Huy hiệu: ${t.colorName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Hiện tại',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtext,
    required String icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Text(icon, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ],
      ),
    );
  }
}
