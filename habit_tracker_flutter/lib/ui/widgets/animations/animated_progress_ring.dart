import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Smooth, high-performance circular progress ring with Curves.easeOutCubic
/// and subtle energy glow when nearing or reaching 100%.
class AnimatedProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final double size;
  final double strokeWidth;
  final Color activeColor;

  const AnimatedProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 76.0,
    this.strokeWidth = 7.0,
    this.activeColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    final targetValue = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final isReduceMotion = AppAnimationConstants.isReduceMotion(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetValue),
      duration: isReduceMotion ? Duration.zero : AppAnimationConstants.ringProgress,
      curve: AppAnimationConstants.curveEnter,
      builder: (context, value, child) {
        final isPerfect = value >= 0.999 && total > 0;

        return RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isPerfect
                  ? [
                      BoxShadow(
                        color: activeColor.withAlpha(80),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Track
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: strokeWidth,
                    color: const Color(0xFF1E2B43),
                  ),
                ),

                // Animated Active Progress
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: strokeWidth,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPerfect ? const Color(0xFF34D399) : activeColor,
                    ),
                  ),
                ),

                // Center Label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completed/$total',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Hôm nay',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
