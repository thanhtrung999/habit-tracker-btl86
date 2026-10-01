import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';

/// Animated count-up / roll transition for streaks, counters, and milestone numbers.
/// Flips smoothly vertically from old number to new number.
class AnimatedCountUp extends StatelessWidget {
  final int count;
  final TextStyle style;
  final String suffix;

  const AnimatedCountUp({
    super.key,
    required this.count,
    required this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    if (AppAnimationConstants.isReduceMotion(context)) {
      return Text('$count$suffix', style: style);
    }

    return AnimatedSwitcher(
      duration: AppAnimationConstants.countUp,
      transitionBuilder: (child, animation) {
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.45),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: inAnimation,
            child: child,
          ),
        );
      },
      child: Text(
        '$count$suffix',
        key: ValueKey<int>(count),
        style: style,
      ),
    );
  }
}
