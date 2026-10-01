import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_completion_chart.dart';
import '../widgets/mood_chart.dart';
import '../widgets/stacked_habit_deck.dart';

class CalendarScreen extends StatelessWidget {
  final VoidCallback onNavigateToToday;

  const CalendarScreen({
    super.key,
    required this.onNavigateToToday,
  });

  static IconData _getGoalIcon(String title, String category) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('thể dục') || lowerTitle.contains('gym') || lowerTitle.contains('chạy') || lowerTitle.contains('xe đạp')) {
      return Icons.fitness_center_rounded;
    } else if (lowerTitle.contains('sách') || lowerTitle.contains('đọc') || lowerTitle.contains('học')) {
      return Icons.menu_book_rounded;
    } else if (lowerTitle.contains('nước') || lowerTitle.contains('uống')) {
      return Icons.water_drop_rounded;
    } else if (lowerTitle.contains('thiền') || lowerTitle.contains('thư giãn') || lowerTitle.contains('ngủ')) {
      return Icons.self_improvement_rounded;
    } else if (lowerTitle.contains('ngọt') || lowerTitle.contains('ăn')) {
      return Icons.restaurant_rounded;
    } else if (lowerTitle.contains('tiền') || lowerTitle.contains('chi') || lowerTitle.contains('tiết kiệm')) {
      return Icons.savings_rounded;
    }
    return Icons.star_rounded;
  }

  int _calculateMonthCompletionRate(HabitViewModel vm) {
    int total = 0;
    int completed = 0;
    for (final dp in vm.monthProgress.values) {
      total += dp.total;
      completed += dp.completed;
    }
    if (total == 0) {
      if (vm.dayProgress.total > 0) {
        return vm.dayProgress.percent;
      }
      return 0;
    }
    return ((completed / total) * 100).round();
  }

  int _calculateMonthCompletedCount(HabitViewModel vm) {
    int completed = 0;
    for (final dp in vm.monthProgress.values) {
      completed += dp.completed;
    }
    return completed;
  }

  int _calculateMonthTotalCount(HabitViewModel vm) {
    int total = 0;
    for (final dp in vm.monthProgress.values) {
      total += dp.total;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final goals = vm.goals;
    final allCategories = StackedHabitDeck.groupGoals(goals);

    final streakDays = vm.overallStreak;
    final completionRate = _calculateMonthCompletionRate(vm);
    final monthCompleted = _calculateMonthCompletedCount(vm);
    final monthTotal = _calculateMonthTotalCount(vm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP 2 METRIC CARDS: Chuỗi hiện tại & Tỷ lệ hoàn thành
            Row(
              children: [
                // Card 1: Số ngày chuỗi hiện tại (làm hết nhiệm vụ cha)
                Expanded(
                  child: _buildStreakCard(streakDays),
                ),
                const SizedBox(width: 12),
                // Card 2: Tỷ lệ hoàn thành hết tất cả nhiệm vụ
                Expanded(
                  child: _buildCompletionRateCard(
                    completionRate,
                    monthCompleted,
                    monthTotal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Month Heatmap with 5-Color Circular Halo Ring
            CalendarHeatmap(
              currentMonth: vm.calendarMonth,
              selectedDate: vm.selectedDate,
              categories: allCategories,
              allRecords: vm.allRecordsMap,
              onSelectDate: (date) {
                _handleDateClick(context, date, vm);
              },
              onPrevMonth: () => vm.changeCalendarMonth(-1),
              onNextMonth: () => vm.changeCalendarMonth(1),
            ),
            const SizedBox(height: 18),

            // 3. Habit Completion Rate Line Chart
            HabitCompletionChart(viewModel: vm),
            const SizedBox(height: 18),

            // 4. Mood Chart
            MoodChart(viewModel: vm),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void _handleDateClick(BuildContext context, DateTime dayDate, HabitViewModel vm) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final clickedDayOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
    final isFuture = clickedDayOnly.isAfter(today);

    await vm.selectDate(dayDate);
    if (!context.mounted) return;

    if (isFuture) {
      _showFutureDateWarning(context);
    } else {
      // Open modal sheet with tasks to tick/untick for this past date
      _showDateTasksSheet(context, dayDate, vm);
    }
  }

  void _showFutureDateWarning(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Không thể tích hoàn thành cho ngày trong tương lai!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDateTasksSheet(BuildContext context, DateTime dayDate, HabitViewModel vm) {
    final dateStr = AppDateUtils.formatDate(dayDate);
    final isToday = AppDateUtils.isToday(dateStr);
    final friendlyDate = isToday
        ? 'Hôm nay (${AppDateUtils.getFriendlyDateString(dateStr)})'
        : AppDateUtils.getFriendlyDateString(dateStr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<HabitViewModel>(
          builder: (context, currentVm, _) {
            final scheduledGoals = currentVm.scheduledGoals;
            final completedCount = scheduledGoals.where((g) => currentVm.isGoalCompleted(g)).length;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.78,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: const Border(
                  top: BorderSide(color: Colors.black, width: 2.5),
                  left: BorderSide(color: Colors.black, width: 2.5),
                  right: BorderSide(color: Colors.black, width: 2.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textMain.withAlpha(60),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friendlyDate,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textMain,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Đã hoàn thành $completedCount/${scheduledGoals.length} nhiệm vụ',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded, color: AppColors.textMain, size: 24),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, thickness: 1.5, color: AppColors.border),

                  // Tasks list
                  if (scheduledGoals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.event_busy_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 10),
                            Text(
                              'Không có thói quen nào trong ngày này',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                        shrinkWrap: true,
                        itemCount: scheduledGoals.length,
                        itemBuilder: (context, index) {
                          final goal = scheduledGoals[index];
                          final isDone = currentVm.isGoalCompleted(goal);
                          final parentCat = HabitCard.getParentCategory(goal);
                          final catColor = StackedHabitDeck.getCategoryColor(parentCat);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDone ? Colors.black : const Color(0xFFCBD5E1),
                                width: isDone ? 2.0 : 1.4,
                              ),
                              boxShadow: isDone
                                  ? const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(2.5, 2.5),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: InkWell(
                              onTap: () async {
                                HapticFeedback.selectionClick();
                                await currentVm.toggleGoal(goal);
                              },
                              child: Row(
                                children: [
                                  // Category color indicator / icon
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: catColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black, width: 1.8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getGoalIcon(goal.title, goal.category),
                                        size: 19,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Title and parent category tag
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDone ? Colors.black : const Color(0xFF334155),
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          parentCat,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Checkbox button
                                  GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      await currentVm.toggleGoal(goal);
                                    },
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isDone ? Colors.black : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black, width: 2.0),
                                      ),
                                      child: isDone
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 21)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Hoàn tất',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakCard(int streakDays) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.6),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CHUỖI HIỆN TẠI',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'ngày',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(int ratePercent, [int completedTasks = 0, int totalTasks = 0]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.6),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'HOÀN THÀNH',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$ratePercent',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
