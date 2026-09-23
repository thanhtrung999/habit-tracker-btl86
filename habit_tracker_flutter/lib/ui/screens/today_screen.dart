import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/milestone_tiers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/habit_card.dart';
import '../widgets/streak_flame.dart';

class TodayScreen extends StatefulWidget {
  final VoidCallback onNavigateToGoals;

  const TodayScreen({
    super.key,
    required this.onNavigateToGoals,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late ConfettiController _confettiController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showMilestoneSheet(BuildContext context, int streakDays) {
    final currentTier = MilestoneConstants.getTier(streakDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: currentTier.badgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: currentTier.badgeBorder, width: 2),
                ),
                child: Center(
                  child: Text(
                    currentTier.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Chuỗi $streakDays Ngày Liên Tiếp',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cấp độ: ${currentTier.label}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: currentTier.color,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    if (currentTier.nextDays != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tiến trình đến cấp tiếp theo:',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          Text(
                            '$streakDays / ${currentTier.nextDays} ngày',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (streakDays / currentTier.nextDays!).clamp(0.0, 1.0),
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(currentTier.color),
                          minHeight: 8,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Bạn đã đạt đẳng cấp cao nhất: Huyền Thoại Kim Cương! 🏆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tiếp tục rèn luyện', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);

    // Trigger confetti if reached 100%
    if (vm.justReachedPerfect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
        vm.resetConfetti();
      });
    }

    final scheduledGoals = vm.scheduledGoals;
    final filteredGoals = _selectedCategory == 'all'
        ? scheduledGoals
        : scheduledGoals.where((g) => g.category == _selectedCategory).toList();

    final isToday = AppDateUtils.isToday(vm.selectedDateStr);
    final friendlyDate = AppDateUtils.getFriendlyDateString(vm.selectedDateStr);
    final progress = vm.dayProgress;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Header with Date & Streak Flame
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      friendlyDate,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMain,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    if (!isToday) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => vm.selectDate(DateTime.now()),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySubtle,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Về hôm nay',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isToday ? 'Duy trì kỷ luật mỗi ngày để thành công' : 'Xem lại lịch sử mục tiêu',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            StreakFlame(
                              streakDays: vm.overallStreak,
                              onTap: () => _showMilestoneSheet(context, vm.overallStreak),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Date Navigator (Previous day, Today, Next day)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textMain),
                                onPressed: () {
                                  vm.selectDate(vm.selectedDate.subtract(const Duration(days: 1)));
                                },
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    vm.selectedDateStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMain),
                                onPressed: () {
                                  vm.selectDate(vm.selectedDate.add(const Duration(days: 1)));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Today Progress Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(60),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        progress.isPerfect ? '🎉 Hoàn tất hôm nay' : 'Tiến trình ngày',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${progress.completed} / ${progress.total} thói quen',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD8F3DC),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress.total > 0
                                      ? (progress.completed / progress.total).clamp(0.0, 1.0)
                                      : 0,
                                  backgroundColor: Colors.white.withAlpha(50),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52B788)),
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    progress.isPerfect
                                        ? 'Xuất sắc! Bạn đã hoàn thành 100% mục tiêu!'
                                        : (progress.completed > 0
                                            ? 'Cố lên! Bạn đang đi đúng hướng!'
                                            : 'Hãy bắt đầu thói quen đầu tiên!'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD8F3DC),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${progress.percent}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Category Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildCategoryChip('all', 'Tất cả'),
                              _buildCategoryChip('health', 'Sức khỏe'),
                              _buildCategoryChip('study', 'Học tập'),
                              _buildCategoryChip('work', 'Công việc'),
                              _buildCategoryChip('mind', 'Tâm trí'),
                              _buildCategoryChip('finance', 'Tài chính'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Habits List
                if (filteredGoals.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.primarySubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không có thói quen nào!',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Chưa có mục tiêu nào được lên lịch cho ngày này hoặc danh mục này.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: widget.onNavigateToGoals,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Thêm thói quen mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = filteredGoals[index];
                          final record = vm.getRecordForGoal(goal.id);
                          final streak = vm.getStreakForGoal(goal.id);

                          return HabitCard(
                            key: ValueKey('${goal.id}_${vm.selectedDateStr}'),
                            goal: goal,
                            record: record,
                            streakDays: streak,
                            onToggle: () => vm.toggleGoal(goal),
                            onIncrement: () => vm.incrementGoal(goal),
                            onDecrement: () => vm.decrementGoal(goal),
                            onSaveNote: (note) => vm.saveNote(goal.id, note),
                            onEdit: widget.onNavigateToGoals,
                          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0);
                        },
                        childCount: filteredGoals.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
        // Confetti Celebration
        ConfettiOverlay(controller: _confettiController),
      ],
    );
  }

  Widget _buildCategoryChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = categoryId),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
