import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/goal.dart';
import '../viewmodels/habit_viewmodel.dart';
import 'stacked_habit_deck.dart';

/// Overall habit heatmap view:
/// Displays heatmaps grouped by Parent Category (Mục cha):
/// - Category icon & Name on left with sub-tasks summary
/// - Total sub-tasks badge on right
/// - 7xN dot grid (M, T, W, T, F, S, S)
/// - Completed day dots are filled with the Parent Category's signature Neo-Brutalist color
class OverallHabitHeatmap extends StatelessWidget {
  final List<CategoryInfo>? categories;
  final List<Goal>? goals;
  final HabitViewModel viewModel;
  final VoidCallback? onAddHabit;

  const OverallHabitHeatmap({
    super.key,
    this.categories,
    this.goals,
    required this.viewModel,
    this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedCategories = categories ??
        (goals != null ? StackedHabitDeck.groupGoals(goals!) : <CategoryInfo>[]);

    if (resolvedCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 52, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(
                'Chưa có dữ liệu thói quen!',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onAddHabit,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo thói quen mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: resolvedCategories.asMap().entries.map((entry) {
          return _CategoryOverallCard(
            key: ValueKey('overall_cat_${entry.value.name}'),
            category: entry.value,
            viewModel: viewModel,
            index: entry.key,
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryOverallCard extends StatelessWidget {
  final CategoryInfo category;
  final HabitViewModel viewModel;
  final int index;

  const _CategoryOverallCard({
    super.key,
    required this.category,
    required this.viewModel,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color;
    final catName = category.name;
    final subTaskCount = category.goals.length;
    final subTasksText = category.goals.map((g) => g.title.trim()).join(' • ');

    final rowLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4.0, 4.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Card Header: Category Icon badge + Category Name + Sub-tasks summary on left, Task count pill on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon badge with Category Color and Neo-brutalist border
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 19,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Sub-tasks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      catName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subTasksText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subTasksText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Task count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.black, width: 1.6),
                ),
                child: Text(
                  '$subTaskCount nhiệm vụ',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Divider line
          Container(
            height: 1.2,
            color: const Color(0xFFE2E8F0),
          ),

          const SizedBox(height: 14),

          // 2. Dot Matrix: Row labels on left + 7xN grid of dots
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row Labels (M, T, W, T, F, S, S)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: rowLabels.map((lbl) {
                    return SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          lbl,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Responsive matrix of dots that spans edge-to-edge with zero scroll conflict
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    // Compute optimal number of weeks that fits cleanly (~17.5dp per column)
                    final int numWeeks = (availableWidth / 17.5).floor().clamp(12, 18);
                    final double colWidth = availableWidth / numWeeks;

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final currentMonday = today.subtract(Duration(days: now.weekday - 1));

                    // List of weeks from (numWeeks - 1) weeks ago up to currentMonday
                    final List<DateTime> weekMondays = [];
                    for (int i = numWeeks - 1; i >= 0; i--) {
                      weekMondays.add(currentMonday.subtract(Duration(days: i * 7)));
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekMondays.map((weekMonday) {
                        return SizedBox(
                          width: colWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(7, (rowIndex) {
                              final targetDate = weekMonday.add(Duration(days: rowIndex));
                              final isFuture = targetDate.isAfter(today);
                              final dateStr = AppDateUtils.formatDate(targetDate);

                              // Find scheduled goals for this category on targetDate
                              final scheduledGoals = category.goals
                                  .where((g) => g.isScheduledForDate(targetDate))
                                  .toList();

                              final completedCount = scheduledGoals.where((g) {
                                final record = viewModel.allRecordsMap['${g.id}_$dateStr'];
                                return record?.completed ?? false;
                              }).length;

                              final bool isScheduled = scheduledGoals.isNotEmpty;
                              final bool isFullyDone = isScheduled && completedCount == scheduledGoals.length;
                              final bool isPartiallyDone = isScheduled && completedCount > 0 && !isFullyDone;

                              Color dotColor;
                              if (isFuture) {
                                dotColor = AppColors.border.withAlpha(90);
                              } else if (isFullyDone) {
                                dotColor = catColor;
                              } else if (isPartiallyDone) {
                                dotColor = catColor.withValues(alpha: 0.40);
                              } else if (!isScheduled) {
                                dotColor = const Color(0xFFF1F5F9);
                              } else {
                                dotColor = const Color(0xFFE2E8F0);
                              }

                              return SizedBox(
                                width: colWidth,
                                height: 18,
                                child: Center(
                                  child: Container(
                                    width: 11.5,
                                    height: 11.5,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
