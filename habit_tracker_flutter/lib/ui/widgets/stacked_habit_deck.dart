import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../core/services/vibration_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/goal.dart';
import '../viewmodels/habit_viewmodel.dart';
import 'animations/flying_sparkle_overlay.dart';
import 'habit_card.dart';

/// Information holder for a Parent Category folder
class CategoryInfo {
  final String name;
  final Color color;
  final IconData icon;
  final List<Goal> goals;

  CategoryInfo({
    required this.name,
    required this.color,
    required this.icon,
    required this.goals,
  });

  int getCompletedCount(HabitViewModel vm) {
    return goals.where((g) => vm.getRecordForGoal(g.id)?.completed == true).length;
  }

  double getProgress(HabitViewModel vm) {
    if (goals.isEmpty) return 0.0;
    return (getCompletedCount(vm) / goals.length).clamp(0.0, 1.0);
  }

  bool isCompleted(HabitViewModel vm) {
    return goals.isNotEmpty && getCompletedCount(vm) == goals.length;
  }
}

/// Renders habit cards grouped by Parent Category (Mục cha):
/// - All folder tabs (Tai kẹp hồ sơ) are aligned at the SAME position (left: 18.0).
/// - Each folder card overlaps the card above it ("đè lên thẻ trên").
/// - Tabs protrude 28px above the card body with generous padding so text and icons are 100% visible with zero clipping.
/// - Pulling/swiping down or tapping a specific Parent Category expands that folder to reveal its sub-items (mục con).
/// - Pulling/swiping up or tapping collapses it back into the overlapping stack.
class StackedHabitDeck extends StatefulWidget {
  final List<Goal> goals;
  final HabitViewModel viewModel;
  final VoidCallback? onAddHabit;
  final void Function(CategoryInfo category, Offset headerPos)? onCategoryCompleted;
  final Set<String>? expandedCategories;
  final ValueChanged<String>? onToggleCategory;
  final Map<String, GlobalKey>? categoryKeys;
  final bool hideFirstCardTab;
  final Widget? firstCardHeaderTrailing;

  const StackedHabitDeck({
    super.key,
    required this.goals,
    required this.viewModel,
    this.onAddHabit,
    this.onCategoryCompleted,
    this.expandedCategories,
    this.onToggleCategory,
    this.categoryKeys,
    this.hideFirstCardTab = false,
    this.firstCardHeaderTrailing,
  });

  static List<CategoryInfo> groupGoals(List<Goal> goals) =>
      _StackedHabitDeckState.groupGoals(goals);

  static Color getCategoryColor(String cat) =>
      _StackedHabitDeckState.getCategoryColor(cat);

  @override
  State<StackedHabitDeck> createState() => _StackedHabitDeckState();
}

class _StackedHabitDeckState extends State<StackedHabitDeck> {
  // Set of currently expanded category names.
  final Set<String> _internalExpandedCategories = {};

  Set<String> get _expandedCategories =>
      widget.expandedCategories ?? _internalExpandedCategories;

  void _toggleCategory(String name) {
    if (widget.onToggleCategory != null) {
      widget.onToggleCategory!(name);
    } else {
      VibrationService.click();
      setState(() {
        if (_internalExpandedCategories.contains(name)) {
          _internalExpandedCategories.remove(name);
        } else {
          _internalExpandedCategories.add(name);
        }
      });
    }
  }

  static List<CategoryInfo> groupGoals(List<Goal> goals) {
    final Map<String, List<Goal>> groups = {};

    for (final goal in goals) {
      final parentCat = HabitCard.getParentCategory(goal);
      groups.putIfAbsent(parentCat, () => []).add(goal);
    }

    // Preferred sort order for standard parent categories
    const order = ['SỨC KHỎE', 'THỂ THAO', 'HỌC TẬP', 'TÂM TRÍ', 'TÀI CHÍNH', 'CÔNG VIỆC'];

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        final indexA = order.indexOf(a);
        final indexB = order.indexOf(b);
        if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
        return a.compareTo(b);
      });

    return sortedKeys.map((key) {
      return CategoryInfo(
        name: key,
        color: getCategoryColor(key),
        icon: _getCategoryIcon(key),
        goals: groups[key]!,
      );
    }).toList();
  }

  static Color getCategoryColor(String cat) {
    switch (cat) {
      case 'SỨC KHỎE':
        return const Color(0xFF4ADE80); // Vibrant Green
      case 'THỂ THAO':
        return const Color(0xFFFBBF24); // Warm Amber
      case 'HỌC TẬP':
        return const Color(0xFF38BDF8); // Sky Blue
      case 'TÂM TRÍ':
        return const Color(0xFFA78BFA); // Lavender Purple
      case 'TÀI CHÍNH':
        return const Color(0xFFFACC15); // Vibrant Yellow
      case 'CÔNG VIỆC':
        return const Color(0xFFF472B6); // Pop Pink
      default:
        return const Color(0xFFFB923C); // Orange
    }
  }

  static IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'SỨC KHỎE':
        return Icons.health_and_safety_rounded;
      case 'THỂ THAO':
        return Icons.fitness_center_rounded;
      case 'HỌC TẬP':
        return Icons.menu_book_rounded;
      case 'TÂM TRÍ':
        return Icons.self_improvement_rounded;
      case 'TÀI CHÍNH':
        return Icons.savings_rounded;
      case 'CÔNG VIỆC':
        return Icons.work_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.goals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.folder_open_rounded, size: 52, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(
                'Chưa có thói quen nào hôm nay!',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: widget.onAddHabit,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm thói quen mới'),
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

    final categoryGroups = groupGoals(widget.goals);

    // Overlap offset: each subsequent card is translated up to overlap the card above it ("đè lên thẻ trên")
    const double overlap = 22.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: categoryGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final catInfo = entry.value;
          final isExpanded = _expandedCategories.contains(catInfo.name);
          final double topOffset = index == 0 ? 0.0 : -overlap * index;

          final Key itemKey = widget.categoryKeys?[catInfo.name] ??
              ValueKey('folder_${catInfo.name}_${widget.viewModel.selectedDateStr}');

          return Transform.translate(
            offset: Offset(0, topOffset),
            child: CategoryFolderItem(
              key: itemKey,
              index: index,
              category: catInfo,
              viewModel: widget.viewModel,
              isExpanded: isExpanded,
              onToggle: () => _toggleCategory(catInfo.name),
              onAddHabit: widget.onAddHabit,
              onCategoryCompleted: widget.onCategoryCompleted,
              hideTab: index == 0 && widget.hideFirstCardTab,
              headerTrailing: index == 0 ? widget.firstCardHeaderTrailing : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A Neo-Brutalist Parent Category Folder:
/// - Elevated Folder Tab (Tai kẹp hồ sơ) nhô cao 28px phía trên thân thẻ, chữ và icon 100% rõ ràng, không khuyết.
/// - All tabs placed at the SAME position (left: 18.0) as requested.
/// - Progress Bar (Thanh ngang tiến trình) replaces title and subtitle inside the card header.
/// - Sparkling light effects fly from completed sub-items into the progress bar when finished.
/// - Pull down (drag down) or tap header to expand and show sub-items (mục con).
/// - Pull up (drag up) or tap header to collapse back into the overlapping stack.
class CategoryFolderItem extends StatefulWidget {
  final int index;
  final CategoryInfo category;
  final HabitViewModel viewModel;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onAddHabit;
  final void Function(CategoryInfo category, Offset headerPos)? onCategoryCompleted;
  final bool hideTab;
  final Widget? headerTrailing;

  const CategoryFolderItem({
    super.key,
    required this.index,
    required this.category,
    required this.viewModel,
    required this.isExpanded,
    required this.onToggle,
    this.onAddHabit,
    this.onCategoryCompleted,
    this.hideTab = false,
    this.headerTrailing,
  });

  @override
  State<CategoryFolderItem> createState() => _CategoryFolderItemState();
}

class _CategoryFolderItemState extends State<CategoryFolderItem>
    with SingleTickerProviderStateMixin {
  final GlobalKey _progressBarKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};
  bool _isGlimmering = false;
  late AnimationController _shimmerController;

  Color get _categoryDarkAccent {
    switch (widget.category.name) {
      case 'SỨC KHỎE':
        return const Color(0xFF16A34A); // Green 600
      case 'THỂ THAO':
        return const Color(0xFFD97706); // Amber 600
      case 'HỌC TẬP':
        return const Color(0xFF0284C7); // Sky 600
      case 'TÂM TRÍ':
        return const Color(0xFF7C3AED); // Violet 600
      case 'TÀI CHÍNH':
        return const Color(0xFFCA8A04); // Yellow/Amber 600
      case 'CÔNG VIỆC':
        return const Color(0xFFDB2777); // Pink 600
      default:
        return const Color(0xFFEA580C); // Orange 600
    }
  }

  Color get _categoryTrackColor {
    return Color.lerp(Colors.white, widget.category.color, 0.28)!;
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _triggerGlimmer() {
    if (!mounted) return;
    setState(() {
      _isGlimmering = true;
    });
    VibrationService.taskComplete();
    _shimmerController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() {
          _isGlimmering = false;
        });
      }
    });
  }

  void _launchCategoryCompletion() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final progressBox = _progressBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (progressBox != null && progressBox.hasSize) {
        final pos = progressBox.localToGlobal(
          Offset(progressBox.size.width * 0.5, progressBox.size.height * 0.5),
        );
        widget.onCategoryCompleted?.call(widget.category, pos);
      }
    });
  }

  void _launchSparkleAnimation(String subGoalId, {VoidCallback? onTargetHitCallback}) {
    final cardKey = _cardKeys[subGoalId];
    final cardContext = cardKey?.currentContext;
    final progressContext = _progressBarKey.currentContext;

    if (cardContext != null && progressContext != null) {
      final cardBox = cardContext.findRenderObject() as RenderBox?;
      final progressBox = progressContext.findRenderObject() as RenderBox?;

      if (cardBox != null && progressBox != null && cardBox.hasSize && progressBox.hasSize) {
        final cardPos = cardBox.localToGlobal(
          Offset(cardBox.size.width * 0.82, cardBox.size.height * 0.5),
        );
        final progressPos = progressBox.localToGlobal(
          Offset(progressBox.size.width * 0.5, progressBox.size.height * 0.5),
        );

        FlyingSparkleOverlay.show(
          context,
          from: cardPos,
          to: progressPos,
          color: widget.category.color,
          onTargetHit: () {
            if (mounted) {
              _triggerGlimmer();
              onTargetHitCallback?.call();
            }
          },
        );
        return;
      }
    }

    // Fallback if context not immediately ready
    _triggerGlimmer();
    onTargetHitCallback?.call();
  }

  void _handleSubGoalToggle(Goal subGoal) {
    final record = widget.viewModel.getRecordForGoal(subGoal.id);
    final wasCompleted = record?.completed ?? false;
    final willComplete = !wasCompleted;

    final currentCompleted = widget.category.goals.where((g) {
      final r = widget.viewModel.getRecordForGoal(g.id);
      return r?.completed ?? false;
    }).length;
    final willCompleteCategory = willComplete && (currentCompleted + 1 == widget.category.goals.length);

    if (willComplete) {
      _launchSparkleAnimation(
        subGoal.id,
        onTargetHitCallback: () {
          if (willCompleteCategory) {
            _launchCategoryCompletion();
          }
        },
      );
    }
    widget.viewModel.toggleGoal(subGoal);
  }

  void _handleSubGoalIncrement(Goal subGoal) {
    final record = widget.viewModel.getRecordForGoal(subGoal.id);
    final wasCompleted = record?.completed ?? false;
    final currentCount = record?.currentCount ?? 0;
    final willComplete = (currentCount + 1 >= subGoal.targetCount) && !wasCompleted;

    final currentCompleted = widget.category.goals.where((g) {
      final r = widget.viewModel.getRecordForGoal(g.id);
      return r?.completed ?? false;
    }).length;
    final willCompleteCategory = willComplete && (currentCompleted + 1 == widget.category.goals.length);

    if (willComplete) {
      _launchSparkleAnimation(
        subGoal.id,
        onTargetHitCallback: () {
          if (willCompleteCategory) {
            _launchCategoryCompletion();
          }
        },
      );
    }
    widget.viewModel.incrementGoal(subGoal);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.category.goals.where((g) {
      final r = widget.viewModel.getRecordForGoal(g.id);
      return r?.completed ?? false;
    }).length;
    final totalCount = widget.category.goals.length;
    final allDone = totalCount > 0 && completedCount == totalCount;
    final progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      // When expanded, add bottom spacing so the next card does not overlap the expanded sub-items
      padding: EdgeInsets.only(bottom: widget.isExpanded ? 24.0 : 0.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Folder Tab on top-left (Cùng 1 vị trí left: 18.0, nhô cao 28px không khuyết chữ)
          if (!widget.hideTab)
            Positioned(
              top: 0,
              left: 18.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggle,
                child: Container(
                  height: 38.0,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 10),
                  decoration: BoxDecoration(
                    color: widget.category.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    border: Border.all(
                      color: Colors.black,
                      width: 2.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4.0, 0),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(widget.category.icon, size: 14, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Main Folder Card Body (Bắt đầu từ top: 28px, hoặc top: 0px nếu tab đã ở dock bar)
          Container(
            margin: EdgeInsets.only(top: widget.hideTab ? 0.0 : 28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.black,
                width: 2.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4.5, 4.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Interactive Folder Header: Tap to toggle expand/collapse
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onToggle,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.fromLTRB(16, 12, 16, widget.isExpanded ? 12 : 26),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Squircle icon container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.category.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2.0),
                          ),
                          child: Center(
                            child: Icon(
                              widget.category.icon,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Horizontal Progress Bar replaces Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Progress label row: "TIẾN TRÌNH" on left, "completed/total (percent%)" on right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        allDone ? 'HOÀN THÀNH' : 'TIẾN TRÌNH',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                          color: allDone
                                              ? _categoryDarkAccent
                                              : (progress > 0 ? _categoryDarkAccent : const Color(0xFF64748B)),
                                        ),
                                      ),
                                      if (allDone) ...[
                                        const SizedBox(width: 4),
                                        const Text('✨', style: TextStyle(fontSize: 11)),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '$completedCount/$totalCount (${(progress * 100).round()}%)',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w900,
                                      color: allDone
                                          ? _categoryDarkAccent
                                          : (progress > 0 ? Colors.black : const Color(0xFF475569)),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // The tactile horizontal progress bar matching parent category color
                              Container(
                                key: _progressBarKey,
                                height: 14.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  // Track background tinted with parent category color (opaque so shadow doesn't darken it)
                                  color: _categoryTrackColor,
                                  borderRadius: BorderRadius.circular(7.0),
                                  border: Border.all(
                                    color: _isGlimmering
                                        ? _categoryDarkAccent
                                        : Colors.black,
                                    width: 1.8,
                                  ),
                                  boxShadow: _isGlimmering
                                      ? [
                                          BoxShadow(
                                            color: widget.category.color.withValues(alpha: 0.75),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : const [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(1.5, 1.5),
                                            blurRadius: 0,
                                          ),
                                        ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Stack(
                                    children: [
                                      // Animated fill portion matching parent category color
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.0, end: progress),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, _) {
                                          return FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: value.clamp(0.0, 1.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _categoryDarkAccent,
                                                    widget.category.color,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // Shimmer wave sweeps across on sparkle landing
                                      if (_isGlimmering)
                                        _ShimmerGlowWave(animation: _shimmerController),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Expand/Collapse Icon Button with Animated Arrow (Icon only, no text)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.isExpanded ? Colors.black : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(1.5, 1.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedRotation(
                              turns: widget.isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: widget.isExpanded ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sub-items List (Mục con xổ ra khi kéo hoặc bấm vào mục cha)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      children: [
                        const Divider(color: Colors.black, thickness: 1.5, height: 16),
                        const SizedBox(height: 6),
                        ...widget.category.goals.map((subGoal) {
                          final record = widget.viewModel.getRecordForGoal(subGoal.id);
                          final streak = widget.viewModel.getStreakForGoal(subGoal.id);
                          final cardKey = _cardKeys.putIfAbsent(subGoal.id, () => GlobalKey());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HabitCard(
                              key: cardKey,
                              goal: subGoal,
                              record: record,
                              streakDays: streak,
                              showTopTab: false, // clean sub-card inside folder
                              onToggle: () => _handleSubGoalToggle(subGoal),
                              onIncrement: () => _handleSubGoalIncrement(subGoal),
                              onDecrement: () => widget.viewModel.decrementGoal(subGoal),
                              onSaveNote: (note) => widget.viewModel.saveNote(subGoal.id, note),
                              onEdit: widget.onAddHabit,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 450),
                  sizeCurve: Curves.easeInOutCubic,
                  firstCurve: Curves.easeInQuad,
                  secondCurve: Curves.easeOutQuad,
                ),
              ],
            ),
          ),

          // 3. Trailing button on header (e.g. Expand/Collapse all on Card 0)
          if (widget.headerTrailing != null)
            Positioned(
              top: 0,
              right: 0,
              child: widget.headerTrailing!,
            ),
        ],
      ),
    );
  }
}

/// Sweeping light shimmer wave across the progress bar
class _ShimmerGlowWave extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerGlowWave({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return FractionallySizedBox(
          widthFactor: 0.45,
          alignment: Alignment(lerpDouble(-2.5, 2.5, animation.value)!, 0.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.85),
                  Colors.amberAccent.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
