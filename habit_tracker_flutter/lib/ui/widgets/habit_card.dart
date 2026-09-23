import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_record.dart';

class HabitCard extends StatefulWidget {
  final Goal goal;
  final GoalRecord? record;
  final int streakDays;
  final VoidCallback onToggle;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Function(String note)? onSaveNote;
  final VoidCallback? onEdit;

  const HabitCard({
    super.key,
    required this.goal,
    this.record,
    this.streakDays = 0,
    required this.onToggle,
    this.onIncrement,
    this.onDecrement,
    this.onSaveNote,
    this.onEdit,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.lightImpact();
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onToggle();
  }

  void _showNoteDialog(BuildContext context) {
    final textController = TextEditingController(text: widget.record?.note ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Ghi chú: ${widget.goal.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú cho thói quen hôm nay...',
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Huỷ', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSaveNote?.call(textController.text);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Lưu ghi chú', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseGoalColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.record?.completed ?? false;
    final currentCount = widget.record?.currentCount ?? 0;
    final targetCount = widget.goal.targetCount;
    final hasCounter = targetCount > 1;
    final note = widget.record?.note ?? '';
    final goalColor = _parseGoalColor(widget.goal.color);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isCompleted ? 0.76 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.cardCompleted : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted ? AppColors.borderCompleted : AppColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isCompleted ? 5 : 12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  color: isCompleted ? AppColors.textLight : goalColor,
                ),
                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Category tag + streak tag + edit button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.getCategoryBg(widget.goal.category),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.goal.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getCategoryColor(widget.goal.category),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (widget.streakDays > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFED7AA), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 11)),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.streakDays}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textLight),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: widget.onEdit,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Habit Title & Checkbox Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.goal.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted ? AppColors.textMuted : AppColors.textMain,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      decorationColor: AppColors.textMuted,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                  if (widget.goal.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      widget.goal.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tactile Checkbox Button (48x48 min touch target)
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: InkWell(
                                onTap: _handleToggle,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isCompleted ? AppColors.primary : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCompleted ? AppColors.primary : AppColors.borderCompleted,
                                      width: 2,
                                    ),
                                    boxShadow: isCompleted
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withAlpha(80),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isCompleted
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Counter bar if targetCount > 1
                        if (hasCounter) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Count text
                              Text(
                                '$currentCount / $targetCount ${widget.goal.unit}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              // Stepper minus (44x44 touch target)
                              InkWell(
                                onTap: widget.onDecrement,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(Icons.remove, size: 18, color: AppColors.textMain),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Stepper plus (44x44 touch target)
                              InkWell(
                                onTap: widget.onIncrement,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primaryLight.withAlpha(80)),
                                  ),
                                  child: const Icon(Icons.add, size: 18, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Linear progress indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (currentCount / targetCount).clamp(0.0, 1.0),
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted ? AppColors.primary : goalColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                        // Note snippet or Add Note button
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _showNoteDialog(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      note.isNotEmpty ? Icons.sticky_note_2 : Icons.note_add_outlined,
                                      size: 16,
                                      color: note.isNotEmpty ? AppColors.primary : AppColors.textLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      note.isNotEmpty ? note : 'Thêm ghi chú...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: note.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
                                        color: note.isNotEmpty ? AppColors.primaryDark : AppColors.textLight,
                                        fontStyle: note.isEmpty ? FontStyle.italic : FontStyle.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
