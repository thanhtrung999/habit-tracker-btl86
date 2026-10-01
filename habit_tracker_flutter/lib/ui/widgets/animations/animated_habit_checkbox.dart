import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';
import '../../../core/animations/manga_particles.dart';
import '../../../core/services/vibration_service.dart';
import '../../../core/theme/app_colors.dart';

/// Tactile, Manga/Sports check habit button with:
/// - Button press scale: 1.0 -> 0.94 -> 1.05 -> 1.0
/// - Checkbox scale: 0.7 -> 1.15 -> 1.0
/// - Animated checkmark draw
/// - Glowing ripple ring
/// - 6-8 sharp sports sparks
class AnimatedHabitCheckbox extends StatefulWidget {
  final bool isCompleted;
  final Color color;
  final VoidCallback onToggle;
  final double size;

  const AnimatedHabitCheckbox({
    super.key,
    required this.isCompleted,
    required this.color,
    required this.onToggle,
    this.size = 44.0,
  });

  @override
  State<AnimatedHabitCheckbox> createState() => _AnimatedHabitCheckboxState();
}

class _AnimatedHabitCheckboxState extends State<AnimatedHabitCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _buttonScale;
  late Animation<double> _innerScale;
  late Animation<double> _checkProgress;
  late Animation<double> _rippleProgress;
  late Animation<double> _particleProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimationConstants.checkActionTotal,
    );

    // 1. Button scale: 1.0 -> 0.94 -> 1.05 -> 1.0
    _buttonScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.94).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.94, end: 1.06).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 2. Checkbox scale: 0.7 -> 1.15 -> 1.0
    _innerScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // 3. Checkmark draw: 0.0 -> 1.0
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    );

    // 4. Ripple glow: 0.0 -> 1.0
    _rippleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.95, curve: Curves.easeOutQuad),
    );

    // 5. Particles: 0.0 -> 1.0
    _particleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );

    if (widget.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedHabitCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (AppAnimationConstants.isReduceMotion(context)) {
      if (!widget.isCompleted) {
        VibrationService.taskComplete();
      } else {
        VibrationService.taskUncheck();
      }
      widget.onToggle();
      return;
    }

    if (!widget.isCompleted) {
      VibrationService.taskComplete();
      _controller.forward(from: 0.0);
      // Allow user to clearly see the squash-stretch, sparks, and checkmark draw before re-sorting
      Future.delayed(const Duration(milliseconds: 240), () {
        if (mounted) widget.onToggle();
      });
    } else {
      VibrationService.taskUncheck();
      _controller.reverse();
      widget.onToggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isChecking = _controller.value > 0.1 || widget.isCompleted;

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: SizedBox(
              width: widget.size + 24,
              height: widget.size + 24,
              child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 5. Particles explosion (6-8 sparks)
                if (_particleProgress.value > 0.0 && _particleProgress.value < 1.0)
                  CustomPaint(
                    size: Size(widget.size + 24, widget.size + 24),
                    painter: MangaSparkPainter(
                      progress: _particleProgress.value,
                      color: activeColor,
                      particleCount: 7,
                      maxRadius: 28.0,
                    ),
                  ),

                // 4. Subtle glowing expanding ripple ring
                if (_rippleProgress.value > 0.0 && _rippleProgress.value < 1.0)
                  Container(
                    width: widget.size + (_rippleProgress.value * 16),
                    height: widget.size + (_rippleProgress.value * 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activeColor.withAlpha(((1.0 - _rippleProgress.value) * 160).toInt()),
                        width: 1.8 * (1.0 - _rippleProgress.value),
                      ),
                    ),
                  ),

                // 1. Scalable button container
                Transform.scale(
                  scale: _buttonScale.value,
                  child: InkWell(
                    onTap: _handleTap,
                    borderRadius: BorderRadius.circular(widget.size),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: isChecking
                            ? activeColor.withAlpha((_controller.value * 255).clamp(0, 255).toInt())
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecking ? activeColor : AppColors.border,
                          width: 2.0,
                        ),
                        boxShadow: isChecking
                            ? [
                                BoxShadow(
                                  color: activeColor.withAlpha((_controller.value * 95).clamp(0, 95).toInt()),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: isChecking ? _innerScale.value : 1.0,
                          child: Opacity(
                            opacity: _checkProgress.value.clamp(0.0, 1.0),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
