import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight custom painter for manga/sports energy particles and sparks.
/// Emits 6-8 sharp geometric sparks radiating outward.
class MangaSparkPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0
  final Color color;
  final int particleCount;
  final double maxRadius;

  MangaSparkPainter({
    required this.progress,
    required this.color,
    this.particleCount = 6,
    this.maxRadius = 26.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withAlpha(((1.0 - progress) * 255).clamp(0, 255).toInt())
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = color.withAlpha(((1.0 - progress) * 240).clamp(0, 255).toInt())
      ..strokeWidth = 2.2 * (1.0 - progress * 0.5)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i * (2 * math.pi / particleCount)) + (i.isEven ? 0.1 : -0.1);
      final currentDist = maxRadius * progress;
      final x = center.dx + math.cos(angle) * currentDist;
      final y = center.dy + math.sin(angle) * currentDist;

      // Draw sharp directional spark
      final sparkLength = 4.0 * (1.0 - progress);
      final tailX = center.dx + math.cos(angle) * (currentDist - sparkLength);
      final tailY = center.dy + math.sin(angle) * (currentDist - sparkLength);
      canvas.drawLine(Offset(tailX, tailY), Offset(x, y), linePaint);

      // Spark tip dot
      final dotRadius = (1.8 * (1.0 - progress)).clamp(0.5, 2.0);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MangaSparkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Subtle radial speed lines for manga power-up milestones.
class MangaSpeedLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  MangaSpeedLinesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final innerDist = 60.0 + (30.0 * (1.0 - progress));

    final paint = Paint()
      ..color = color.withAlpha((progress * 35).clamp(0, 50).toInt())
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const lineCount = 18;
    for (int i = 0; i < lineCount; i++) {
      final angle = i * (2 * math.pi / lineCount);
      final p1 = Offset(center.dx + math.cos(angle) * innerDist, center.dy + math.sin(angle) * innerDist);
      final p2 = Offset(center.dx + math.cos(angle) * maxDist, center.dy + math.sin(angle) * maxDist);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MangaSpeedLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
