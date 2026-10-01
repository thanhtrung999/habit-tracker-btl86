import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/services/vibration_service.dart';

/// A 3D arcade/pixel-art keycap button that indicates expand/collapse state.
/// Faithfully reproduces the retro cyan 3D keycap aesthetic with a pixelated arrow.
class ArcadeArrowButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;

  const ArcadeArrowButton({
    super.key,
    required this.isExpanded,
    required this.onTap,
    this.size = 34.0,
    this.tooltip,
  });

  @override
  State<ArcadeArrowButton> createState() => _ArcadeArrowButtonState();
}

class _ArcadeArrowButtonState extends State<ArcadeArrowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        VibrationService.click();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: widget.isExpanded ? 0.0 : 0.5,
          end: widget.isExpanded ? 0.0 : 0.5,
        ),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        builder: (context, rotationTurns, _) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: _isPressed ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOutQuad,
            builder: (context, pressProgress, _) {
              return SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _ArcadeButtonPainter(
                    pressProgress: pressProgress,
                    rotationTurns: rotationTurns,
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class _ArcadeButtonPainter extends CustomPainter {
  final double pressProgress; // 0.0 (unpressed) to 1.0 (pressed)
  final double rotationTurns; // 0.0 (UP) to 0.5 (DOWN)

  _ArcadeButtonPainter({
    required this.pressProgress,
    required this.rotationTurns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = Radius.circular(w * 0.24); // ~8.2dp on 34dp

    // 1. Draw outer 3D base bevel (the lower lip)
    final outerRect = Rect.fromLTWH(0, 0, w, h);
    final outerRRect = RRect.fromRectAndRadius(outerRect, radius);

    final bevelPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0089C5),
          Color(0xFF006F9E),
        ],
      ).createShader(outerRect);
    canvas.drawRRect(outerRRect, bevelPaint);

    // 2. Draw Top Keycap Face (elevated)
    // When unpressed: bevel is ~4.5dp tall. When pressed: keycap depresses by 2.2dp
    final pressOffset = 2.2 * pressProgress;
    final bevelHeight = 4.5 - pressOffset;
    final topFaceHeight = h - bevelHeight;

    final topFaceRect = Rect.fromLTWH(0, pressOffset, w, topFaceHeight);
    final topFaceRRect = RRect.fromRectAndCorners(
      topFaceRect,
      topLeft: radius,
      topRight: radius,
      bottomLeft: Radius.circular(w * 0.16),
      bottomRight: Radius.circular(w * 0.16),
    );

    final topFacePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1AE0FF),
          Color(0xFF00C7F8),
        ],
      ).createShader(topFaceRect);
    canvas.drawRRect(topFaceRRect, topFacePaint);

    // Subtle top inner highlight
    final topHighlightPaint = Paint()
      ..color = const Color(0xFF7CEBFF).withValues(alpha: 0.65)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(topFaceRect.left + 5.0, topFaceRect.top + 1.2),
      Offset(topFaceRect.right - 5.0, topFaceRect.top + 1.2),
      topHighlightPaint,
    );

    // Bottom highlight edge of top face (creates the 3D shelf edge)
    final bottomHighlightPaint = Paint()
      ..color = const Color(0xFF38E2F4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(topFaceRect.left + 3.0, topFaceRect.bottom - 0.5),
      Offset(topFaceRect.right - 3.0, topFaceRect.bottom - 0.5),
      bottomHighlightPaint,
    );

    // 3. Draw Arrow on the Top Face
    final arrowCenterX = w / 2;
    final arrowCenterY = pressOffset + (topFaceHeight / 2);

    canvas.save();
    canvas.translate(arrowCenterX, arrowCenterY);
    canvas.rotate(rotationTurns * 2 * math.pi);

    final arrowW = w * 0.44; // ~15.0dp on 34dp
    final arrowH = w * 0.42; // ~14.3dp on 34dp

    final hw = arrowW / 2;
    final hh = arrowH / 2;
    final hStemW = (arrowW * 0.44) / 2; // stem width ~44% of head width
    final headH = arrowH * 0.56; // triangle height ~56% of total height

    // Authentic stepped pixel-art arcade arrow path
    final arrowPath = Path();
    arrowPath.moveTo(0, -hh); // top center tip
    arrowPath.lineTo(hw * 0.20, -hh);
    arrowPath.lineTo(hw * 0.20, -hh + headH * 0.15);
    arrowPath.lineTo(hw * 0.45, -hh + headH * 0.15);
    arrowPath.lineTo(hw * 0.45, -hh + headH * 0.35);
    arrowPath.lineTo(hw * 0.75, -hh + headH * 0.35);
    arrowPath.lineTo(hw * 0.75, -hh + headH * 0.65);
    arrowPath.lineTo(hw, -hh + headH * 0.65);
    arrowPath.lineTo(hw, -hh + headH); // right wing tip
    arrowPath.lineTo(hStemW, -hh + headH); // under right wing
    arrowPath.lineTo(hStemW, hh); // bottom right of stem
    arrowPath.lineTo(-hStemW, hh); // bottom left of stem
    arrowPath.lineTo(-hStemW, -hh + headH); // under left wing
    arrowPath.lineTo(-hw, -hh + headH); // left wing tip
    arrowPath.lineTo(-hw, -hh + headH * 0.65);
    arrowPath.lineTo(-hw * 0.75, -hh + headH * 0.65);
    arrowPath.lineTo(-hw * 0.75, -hh + headH * 0.35);
    arrowPath.lineTo(-hw * 0.45, -hh + headH * 0.35);
    arrowPath.lineTo(-hw * 0.45, -hh + headH * 0.15);
    arrowPath.lineTo(-hw * 0.20, -hh + headH * 0.15);
    arrowPath.lineTo(-hw * 0.20, -hh);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = const Color(0xFF094E85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);

    canvas.restore();

    // 4. Outer dark border (crisp 1.8dp outline)
    final borderPaint = Paint()
      ..color = const Color(0xFF021622)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(outerRRect.deflate(0.9), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcadeButtonPainter oldDelegate) {
    return oldDelegate.pressProgress != pressProgress ||
        oldDelegate.rotationTurns != rotationTurns;
  }
}
