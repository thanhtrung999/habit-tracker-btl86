import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';
import '../../../core/animations/manga_particles.dart';
import '../../../core/constants/milestone_tiers.dart';
import '../../../core/theme/app_colors.dart';

/// Manga / Sports Power-up Milestone Celebration.
/// Plays on major milestones (7, 14, 30, 60, 100 days).
class MilestoneCelebrationOverlay extends StatefulWidget {
  final int streakDays;
  final MilestoneTier tier;
  final VoidCallback onDismiss;

  const MilestoneCelebrationOverlay({
    super.key,
    required this.streakDays,
    required this.tier,
    required this.onDismiss,
  });

  @override
  State<MilestoneCelebrationOverlay> createState() => _MilestoneCelebrationOverlayState();
}

class _MilestoneCelebrationOverlayState extends State<MilestoneCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _badgeScale;
  late Animation<double> _speedLinesProgress;
  late Animation<double> _particleProgress;
  late Animation<double> _badgeRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimationConstants.milestonePowerUp,
    );

    // Badge scale: 0.7 -> 1.15 -> 1.0
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.16).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.16, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
    ]).animate(_controller);

    // Subtle tilt: -4 deg to +4 deg to 0 deg
    _badgeRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: -0.06, end: 0.05), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: 0.0), weight: 50),
    ]).animate(_controller);

    _speedLinesProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _particleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark Backdrop
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withAlpha(160),
              ),
            ),

            // Manga Speed Lines (radiating from center)
            AnimatedBuilder(
              animation: _speedLinesProgress,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: MangaSpeedLinesPainter(
                    progress: _speedLinesProgress.value,
                    color: tier.color,
                  ),
                );
              },
            ),

            // Radiating Energy Sparks
            AnimatedBuilder(
              animation: _particleProgress,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(280, 280),
                  painter: MangaSparkPainter(
                    progress: _particleProgress.value,
                    color: tier.color,
                    particleCount: 12,
                    maxRadius: 150.0,
                  ),
                );
              },
            ),

            // Central Power-up Card
            AnimatedBuilder(
              animation: _badgeScale,
              builder: (context, _) {
                return Transform.scale(
                  scale: _badgeScale.value,
                  child: Transform.rotate(
                    angle: _badgeRotation.value,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: tier.badgeBorder, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: tier.color.withAlpha(120),
                            blurRadius: 36,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha(200),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge Avatar Icon
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: tier.badgeBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: tier.color, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: tier.color.withAlpha(90),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tier.icon,
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Text Header
                          Text(
                            'MILESTONE POWER-UP!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'CHUỖI ${widget.streakDays} NGÀY',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: tier.badgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Đẳng cấp: ${tier.label}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: tier.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: widget.onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tier.color,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 6,
                              ),
                              child: const Text(
                                'Tiếp tục rèn luyện 🔥',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }
}
