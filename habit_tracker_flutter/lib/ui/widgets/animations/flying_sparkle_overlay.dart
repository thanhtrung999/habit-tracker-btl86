import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Represents a single magical flying particle (star, sparkle, or light orb)
class _ParticleData {
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final double curvature;
  final double delay; // Normalized delay between 0.0 and 0.25
  final double size;
  final Color color;
  final int type; // 0: Sparkle icon, 1: Star icon, 2: Glowing orb
  final double rotationSpeed;

  _ParticleData({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.curvature,
    required this.delay,
    required this.size,
    required this.color,
    required this.type,
    required this.rotationSpeed,
  });
}

/// Overlay controller for launching flying sparkle / light animations from a completed sub-item
/// directly into the parent category's progress bar or up to the circular chart/streak pill.
class FlyingSparkleOverlay {
  static void show(
    BuildContext context, {
    required Offset from,
    required Offset to,
    required Color color,
    int particleCount = 18,
    Duration duration = const Duration(milliseconds: 1400),
    double targetSpreadX = 60.0,
    double targetSpreadY = 8.0,
    VoidCallback? onTargetHit,
  }) {
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) {
      onTargetHit?.call();
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FlyingSparklesWidget(
        from: from,
        to: to,
        baseColor: color,
        particleCount: particleCount,
        duration: duration,
        targetSpreadX: targetSpreadX,
        targetSpreadY: targetSpreadY,
        onTargetHit: onTargetHit,
        onComplete: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlayState.insert(entry);
  }
}

class _FlyingSparklesWidget extends StatefulWidget {
  final Offset from;
  final Offset to;
  final Color baseColor;
  final int particleCount;
  final Duration duration;
  final double targetSpreadX;
  final double targetSpreadY;
  final VoidCallback? onTargetHit;
  final VoidCallback onComplete;

  const _FlyingSparklesWidget({
    required this.from,
    required this.to,
    required this.baseColor,
    this.particleCount = 18,
    this.duration = const Duration(milliseconds: 1400),
    this.targetSpreadX = 60.0,
    this.targetSpreadY = 8.0,
    this.onTargetHit,
    required this.onComplete,
  });

  @override
  State<_FlyingSparklesWidget> createState() => _FlyingSparklesWidgetState();
}

class _FlyingSparklesWidgetState extends State<_FlyingSparklesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ParticleData> _particles = [];
  bool _targetHitTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _initParticles();

    _controller.addListener(() {
      // Trigger arrival pulse at progress bar when leading particles arrive (~72% through)
      if (!_targetHitTriggered && _controller.value >= 0.72) {
        _targetHitTriggered = true;
        widget.onTargetHit?.call();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  void _initParticles() {
    final random = Random();
    final particleCount = widget.particleCount;

    final colors = [
      widget.baseColor,
      widget.baseColor,
      Color.lerp(widget.baseColor, Colors.white, 0.45)!,
      const Color(0xFFFDE047), // Sparkle gold highlight
      Colors.white,
    ];

    for (int i = 0; i < particleCount; i++) {
      final delay = (i / particleCount) * 0.26;
      final angle = random.nextDouble() * 2 * pi;
      final dist = random.nextDouble() * 22;
      final startOffset = Offset(cos(angle) * dist, sin(angle) * dist);

      // Target variation
      final targetSpread = (random.nextDouble() - 0.5) * widget.targetSpreadX;
      final targetOffset = Offset(targetSpread, (random.nextDouble() - 0.5) * widget.targetSpreadY);

      // Curvature: arc outwards gently
      final curveDir = (i % 2 == 0 ? 1.0 : -1.0);
      final curveAmount = (35.0 + random.nextDouble() * 45.0) * curveDir;

      _particles.add(
        _ParticleData(
          startX: widget.from.dx + startOffset.dx,
          startY: widget.from.dy + startOffset.dy,
          targetX: widget.to.dx + targetOffset.dx,
          targetY: widget.to.dy + targetOffset.dy,
          curvature: curveAmount,
          delay: delay,
          size: 11.0 + random.nextDouble() * 12.0,
          color: colors[random.nextInt(colors.length)],
          type: i % 3,
          rotationSpeed: (random.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _SparklesPainter(
              progress: _controller.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double progress;
  final List<_ParticleData> particles;

  _SparklesPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (progress < p.delay) continue;

      // Each particle flies for a full 0.74 duration (~1036ms), maintaining a calm, uniform, slow flight
      final tNorm = ((progress - p.delay) / 0.74).clamp(0.0, 1.0);
      if (tNorm >= 1.0) continue;

      // Arc curve motion: gentle easing in and out for a graceful floating arc
      final curvedT = Curves.easeInOutCubic.transform(tNorm);
      final x = lerpDouble(p.startX, p.targetX, curvedT)! + sin(curvedT * pi) * p.curvature;
      final y = lerpDouble(p.startY, p.targetY, curvedT)!;

      // Scale & opacity life cycle:
      // Quick pop-in, stays 100% vibrant during flight, and softly fades upon hitting target
      double scale = 1.0;
      if (tNorm < 0.15) {
        scale = Curves.easeOutBack.transform(tNorm / 0.15);
      } else if (tNorm > 0.85) {
        scale = (1.0 - (tNorm - 0.85) / 0.15).clamp(0.0, 1.0);
      }

      double opacity = 1.0;
      if (tNorm < 0.12) {
        opacity = (tNorm / 0.12).clamp(0.0, 1.0);
      } else if (tNorm > 0.88) {
        opacity = (1.0 - (tNorm - 0.88) / 0.12).clamp(0.0, 1.0);
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);
      canvas.scale(scale);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (p.type == 0) {
        // 4-pointed sparkle star (✦)
        _draw4PointStar(canvas, p.size * 0.7, paint);
      } else if (p.type == 1) {
        // Glowing light orb with halo
        final haloPaint = Paint()
          ..color = p.color.withValues(alpha: opacity * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(Offset.zero, p.size * 0.55, haloPaint);

        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, p.size * 0.28, corePaint);
      } else {
        // Diamond / Rhombus sparkle (◆)
        _drawDiamond(canvas, p.size * 0.55, paint);
      }

      canvas.restore();
    }
  }

  void _draw4PointStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    final innerR = radius * 0.32;
    for (int i = 0; i < 4; i++) {
      final outerAngle = (i * pi / 2);
      final innerAngle = outerAngle + (pi / 4);

      final ox = cos(outerAngle) * radius;
      final oy = sin(outerAngle) * radius;
      final ix = cos(innerAngle) * innerR;
      final iy = sin(innerAngle) * innerR;

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();

    // Outer glow
    final glowPaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.a * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawPath(path, glowPaint);

    // Sharp star
    canvas.drawPath(path, paint);

    // Center white gleam
    final centerPaint = Paint()..color = Colors.white.withValues(alpha: paint.color.a);
    canvas.drawCircle(Offset.zero, radius * 0.22, centerPaint);
  }

  void _drawDiamond(Canvas canvas, double radius, Paint paint) {
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.65, 0)
      ..lineTo(0, radius)
      ..lineTo(-radius * 0.65, 0)
      ..close();

    final glowPaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.a * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
