import 'package:flutter/material.dart';
import '../../core/services/vibration_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/habit_icons.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_record.dart';
import 'animations/animated_count_up.dart';
import 'horizontal_energy_wave_bar.dart';

/// Flat Design Habit Card:
/// - Pure 2D aesthetic: zero blur drop shadows, clean 1px hairline borders
/// - Horizontal swipe reveals flat solid action buttons: [V] (Emerald) and [X] (Coral Red)
/// - Clean completion state with flat emerald accents and badge
/// - Smooth micro-bounce and state transitions
class HabitCard extends StatefulWidget {
  final Goal goal;
  final GoalRecord? record;
  final int streakDays;
  final VoidCallback onToggle;
  final VoidCallback? onCardTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Function(String note)? onSaveNote;
  final VoidCallback? onEdit;
  final bool showTopTab;

  const HabitCard({
    super.key,
    required this.goal,
    this.record,
    this.streakDays = 0,
    required this.onToggle,
    this.onCardTap,
    this.onIncrement,
    this.onDecrement,
    this.onSaveNote,
    this.onEdit,
    this.showTopTab = true,
  });

  static String getParentCategory(Goal goal) {
    final cat = goal.category.trim().toLowerCase();
    final title = goal.title.trim().toLowerCase();

    if (cat == 'sport' || cat == 'thể thao' ||
        title.contains('thể dục') || title.contains('chạy') ||
        title.contains('gym') || title.contains('vận động') ||
        title.contains('bơi') || title.contains('đạp xe')) {
      return 'THỂ THAO';
    }
    if (cat == 'health' || cat == 'sức khỏe' || cat == 'diet' ||
        cat == 'ăn uống' || cat == 'water' || cat == 'nước' ||
        title.contains('ngọt') || title.contains('nước') ||
        title.contains('ăn') || title.contains('ngủ')) {
      return 'SỨC KHỎE';
    }
    if (cat == 'study' || cat == 'học tập' || cat == 'work' ||
        cat == 'công việc' || title.contains('sách') ||
        title.contains('đọc') || title.contains('học')) {
      return 'HỌC TẬP';
    }
    if (cat == 'mind' || cat == 'tâm trí' || title.contains('thiền') ||
        title.contains('thư giãn') || title.contains('tịnh')) {
      return 'TÂM TRÍ';
    }
    if (cat == 'finance' || cat == 'tài chính' || title.contains('tiết kiệm') ||
        title.contains('chi tiêu') || title.contains('tiền')) {
      return 'TÀI CHÍNH';
    }
    return goal.category.toUpperCase();
  }

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _cardBounceController;
  late Animation<double> _cardBounceAnimation;

  @override
  void initState() {
    super.initState();
    _cardBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _cardBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.97).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.015).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.015, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_cardBounceController);
  }

  @override
  void dispose() {
    _cardBounceController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    final isCompleted = widget.record?.completed ?? false;
    if (isCompleted) {
      VibrationService.taskUncheck();
    } else {
      VibrationService.taskComplete();
    }
    _cardBounceController.forward(from: 0.0);
    widget.onToggle();
  }

  Color _parseGoalColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.isEmpty) return AppColors.getCategoryColor(widget.goal.category);
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.getCategoryColor(widget.goal.category);
    }
  }

  IconData _getGoalIcon(Goal goal) {
    return HabitIcons.getIcon(goal.icon, title: goal.title, category: goal.category);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.record?.completed ?? false;
    final currentCount = widget.record?.currentCount ?? 0;
    final targetCount = widget.goal.targetCount;
    final hasCounter = targetCount > 1;
    final goalColor = _parseGoalColor(widget.goal.color);
    final iconData = _getGoalIcon(widget.goal);

    return AnimatedBuilder(
      animation: _cardBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardBounceAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: widget.showTopTab ? 6 : 0, bottom: 12),
        child: _buildCardSurface(
          isCompleted: isCompleted,
          goalColor: goalColor,
          iconData: iconData,
          hasCounter: hasCounter,
          currentCount: currentCount,
          targetCount: targetCount,
        ),
      ),
    );
  }

  /// Foreground Neo-Brutalist Folder Card with Hard Black Drop Shadow
  Widget _buildCardSurface({
    required bool isCompleted,
    required Color goalColor,
    required IconData iconData,
    required bool hasCounter,
    required int currentCount,
    required int targetCount,
  }) {
    final parentCategoryName = HabitCard.getParentCategory(widget.goal);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Enlarged Folder Tab on top-left (Fits parent category text without clipping)
        if (widget.showTopTab)
          Positioned(
            top: 0,
            left: 18,
            child: Container(
              height: 38.0,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 10),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFCBD5E1) : goalColor,
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
              child: Text(
                parentCategoryName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

        // 2. Main White Card Body
        Container(
          margin: EdgeInsets.only(top: widget.showTopTab ? 28 : 0),
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                if (widget.onCardTap != null) {
                  widget.onCardTap!();
                } else {
                  _handleToggle();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Squircle Icon Container + Info + Action
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Squircle Icon Container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFE2E8F0) : goalColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted ? Icons.check_rounded : iconData,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title and Streak Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.goal.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isCompleted ? const Color(0xFF0F172A) : Colors.black,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.streakDays > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🔥', style: TextStyle(fontSize: 9.5)),
                                          const SizedBox(width: 2),
                                          AnimatedCountUp(
                                            count: widget.streakDays,
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Right: Completion Badge or Check Circle
                        if (isCompleted)
                          _buildCompletedBadge()
                        else if (!hasCounter)
                          _buildQuickCheckCircle(),
                      ],
                    ),

                    // Energy Streak Bar with Horizontal Rolling Wave Animation (when completed)
                    if (isCompleted) ...[
                      const SizedBox(height: 10),
                      HorizontalEnergyWaveBar(streakDays: widget.streakDays),
                    ],

                    // Stepper Progress Bar for targetCount > 1
                    if (hasCounter && !isCompleted) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Text(
                              '$currentCount / $targetCount ${widget.goal.unit}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (currentCount / targetCount).clamp(0.0, 1.0),
                                  child: Container(
                                    color: goalColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStepperButton(
                            icon: Icons.remove,
                            color: Colors.black,
                            bg: Colors.white,
                            onTap: () {
                              VibrationService.click();
                              widget.onDecrement?.call();
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildStepperButton(
                            icon: Icons.add,
                            color: Colors.black,
                            bg: goalColor,
                            onTap: () {
                              VibrationService.click();
                              widget.onIncrement?.call();
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Neo-Brutalist Stepper Button with black border & hard black shadow
  Widget _buildStepperButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
            width: 1.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  /// Neo-Brutalist Completed Badge with hard black drop shadow
  Widget _buildCompletedBadge() {
    return InkWell(
      onTap: _handleToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2.0, 2.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_rounded, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'ĐÃ XONG',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Neo-Brutalist Tactile Check Circle Button with hard black shadow
  Widget _buildQuickCheckCircle() {
    return InkWell(
      onTap: _handleToggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
