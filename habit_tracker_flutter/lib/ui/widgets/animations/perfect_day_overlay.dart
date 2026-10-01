import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';
import '../../../core/animations/manga_particles.dart';

/// Manga/Sports "PERFECT DAY" celebration overlay.
/// Triggers when 100% of daily habits are checked.
/// Snappy 1200ms duration, smooth scale + fade, non-blinding.
class PerfectDayOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const PerfectDayOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  State<PerfectDayOverlay> createState() => _PerfectDayOverlayState();
}

class _PerfectDayOverlayState extends State<PerfectDayOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _particleProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimationConstants.perfectDay,
    );

    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.75, end: 1.08).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
    ]).animate(_controller);

    _particleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutQuad),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppAnimationConstants.isReduceMotion(context)) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            _controller.stop();
            widget.onDismiss();
          },
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: _fade.value.clamp(0.0, 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle Backdrop blur
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.black.withAlpha((_fade.value * 70).toInt()),
                    ),
                  ),

                  // Radiating sparks
                  if (_particleProgress.value > 0.0)
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: MangaSparkPainter(
                        progress: _particleProgress.value,
                        color: const Color(0xFF10B981),
                        particleCount: 10,
                        maxRadius: 130.0,
                      ),
                    ),

                  // Center Achievement Card
                  Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1726),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF10B981), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withAlpha(100),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha(160),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Trophy / Crown Icon Box
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF34D399), width: 2),
                            ),
                            child: const Center(
                              child: Text('🏆', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'PERFECT DAY',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hoàn thành 100% mục tiêu hôm nay!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF34D399),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
