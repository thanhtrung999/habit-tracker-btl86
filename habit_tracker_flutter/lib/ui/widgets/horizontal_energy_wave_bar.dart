import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Dynamic theme configuration for each streak day
class StreakEnergyTheme {
  final Color primary;
  final Color secondary;
  final Color highlight;
  final Color glow;
  final String tierTitle;
  final String icon;
  final int targetDays;
  final int minDays;

  const StreakEnergyTheme({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.glow,
    required this.tierTitle,
    required this.icon,
    required this.targetDays,
    required this.minDays,
  });

  /// Generate a distinct, vivid, warm-to-cool color theme for the streak milestones:
  /// 7 ngày, 14 ngày, 30 ngày, 60 ngày, 90 ngày, 120 ngày, 150 ngày, 200 ngày, 365 ngày
  static StreakEnergyTheme forStreak(int streak) {
    if (streak < 7) {
      // 1. < 7 ngày: Đỏ rực lửa (Gam màu nóng cực độ - Khởi động)
      return const StreakEnergyTheme(
        primary: Color(0xFFB91C1C),
        secondary: Color(0xFFEF4444),
        highlight: Color(0xFFFCA5A5),
        glow: Color(0xFFFEE2E2),
        tierTitle: 'MỐC 7 NGÀY',
        icon: '🔥',
        targetDays: 7,
        minDays: 0,
      );
    } else if (streak < 14) {
      // 2. 7 - 13 ngày: Cam bốc lửa (Gam màu nóng bùng cháy)
      return const StreakEnergyTheme(
        primary: Color(0xFFC2410C),
        secondary: Color(0xFFF97316),
        highlight: Color(0xFFFDBA74),
        glow: Color(0xFFFFEDD5),
        tierTitle: 'MỐC 14 NGÀY',
        icon: '💥',
        targetDays: 14,
        minDays: 7,
      );
    } else if (streak < 30) {
      // 3. 14 - 29 ngày: Vàng kim hổ phách (Gam màu nóng rực rỡ)
      return const StreakEnergyTheme(
        primary: Color(0xFFB45309),
        secondary: Color(0xFFF59E0B),
        highlight: Color(0xFFFDE68A),
        glow: Color(0xFFFEF3C7),
        tierTitle: 'MỐC 30 NGÀY',
        icon: '⚡',
        targetDays: 30,
        minDays: 14,
      );
    } else if (streak < 60) {
      // 4. 30 - 59 ngày: Hồng Ruby Neon (Gam màu ấm/vibrant sắc nét)
      return const StreakEnergyTheme(
        primary: Color(0xFFBE185D),
        secondary: Color(0xFFEC4899),
        highlight: Color(0xFFF9A8D4),
        glow: Color(0xFFFCE7F3),
        tierTitle: 'MỐC 60 NGÀY',
        icon: '🌸',
        targetDays: 60,
        minDays: 30,
      );
    } else if (streak < 90) {
      // 5. 60 - 89 ngày: Xanh lục Emerald (Bắt đầu chuyển sang gam màu lạnh / tươi mát)
      return const StreakEnergyTheme(
        primary: Color(0xFF047857),
        secondary: Color(0xFF10B981),
        highlight: Color(0xFF6EE7B7),
        glow: Color(0xFFA7F3D0),
        tierTitle: 'MỐC 90 NGÀY',
        icon: '🌿',
        targetDays: 90,
        minDays: 60,
      );
    } else if (streak < 120) {
      // 6. 90 - 119 ngày: Xanh ngọc lam Cyan (Gam màu lạnh dòng nước)
      return const StreakEnergyTheme(
        primary: Color(0xFF0E7490),
        secondary: Color(0xFF06B6D4),
        highlight: Color(0xFF67E8F9),
        glow: Color(0xFFA5F3FC),
        tierTitle: 'MỐC 120 NGÀY',
        icon: '🌊',
        targetDays: 120,
        minDays: 90,
      );
    } else if (streak < 150) {
      // 7. 120 - 149 ngày: Xanh dương Sapphire (Gam màu lạnh kiên cường)
      return const StreakEnergyTheme(
        primary: Color(0xFF1D4ED8),
        secondary: Color(0xFF3B82F6),
        highlight: Color(0xFF93C5FD),
        glow: Color(0xFFBFDBFE),
        tierTitle: 'MỐC 150 NGÀY',
        icon: '💎',
        targetDays: 150,
        minDays: 120,
      );
    } else if (streak < 200) {
      // 8. 150 - 199 ngày: Tím chàm Indigo (Gam màu lạnh sâu thẳm)
      return const StreakEnergyTheme(
        primary: Color(0xFF4338CA),
        secondary: Color(0xFF6366F1),
        highlight: Color(0xFFA5B4FC),
        glow: Color(0xFFC7D2FE),
        tierTitle: 'MỐC 200 NGÀY',
        icon: '🔮',
        targetDays: 200,
        minDays: 150,
      );
    } else if (streak < 365) {
      // 9. 200 - 364 ngày: Tím hoàng gia Cosmic (Gam màu lạnh đỉnh cao)
      return const StreakEnergyTheme(
        primary: Color(0xFF6D28D9),
        secondary: Color(0xFF8B5CF6),
        highlight: Color(0xFFDDD6FE),
        glow: Color(0xFFEDE9FE),
        tierTitle: 'MỐC 365 NGÀY',
        icon: '👑',
        targetDays: 365,
        minDays: 200,
      );
    } else {
      // 10. ≥ 365 ngày: Kim cương vương miện Astral Diamond (Legend - 1 Năm)
      return const StreakEnergyTheme(
        primary: Color(0xFF312E81),
        secondary: Color(0xFF7C3AED),
        highlight: Color(0xFFFDE047),
        glow: Color(0xFFFFFFFF),
        tierTitle: '1 NĂM HUYỀN THOẠI',
        icon: '🏆',
        targetDays: 365,
        minDays: 365,
      );
    }
  }
}

/// Custom painter for Liquid Energy Progress Bar
/// Displays fluid/liquid animation with:
/// 1. Energy progress filling from left to right (0% to 100%)
/// 2. Liquid wave currents & ripples cascading from top to bottom (-verticalPhase)
/// 3. Curved dynamic liquid meniscus (surface front) on the right edge
/// 4. Liquid current ribbons, floating bubbles, and glass container specular sheen
/// 5. Dark neo-brutalist empty gauge track with subtle tick notches on the unfilled right side
class LiquidEnergyWavePainter extends CustomPainter {
  final double animationProgress; // 0.0 to 1.0 (repeating time loop)
  final double fillProgress;      // 0.0 to 1.0 (percent / 100.0)
  final StreakEnergyTheme theme;

  LiquidEnergyWavePainter({
    required this.animationProgress,
    required this.fillProgress,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;

    // 1. Draw Empty Chamber Track (Right-side unfilled container - light recessed slot)
    final trackPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [
          Color(0xFFE2E8F0), // Slate 200
          Color(0xFFF1F5F9), // Slate 100
        ],
      );
    canvas.drawRect(rect, trackPaint);

    // Subtle gauge tick marks at 20%, 40%, 60%, 80% to emphasize progress track
    final tickPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (int step = 1; step <= 4; step++) {
      final tickX = size.width * (step * 0.2);
      canvas.drawLine(Offset(tickX, 0), Offset(tickX, 4.0), tickPaint);
      canvas.drawLine(Offset(tickX, size.height - 4.0), Offset(tickX, size.height), tickPaint);
    }

    final clampedFill = fillProgress.clamp(0.06, 1.0);
    final isFull = clampedFill >= 0.99;
    final baseFillWidth = size.width * clampedFill;

    // Vertical wave phase: (-verticalPhase) causes wave crests to propagate downward (top to bottom)
    final verticalPhase = animationProgress * 2 * math.pi;

    // Helper to calculate the liquid front edge X position for any Y coordinate
    // Smooth, rounded, organic meniscus curve (less pointy / nhọn)
    double getMeniscusX(double y, double phaseShift, double ampFactor) {
      if (isFull) return size.width;
      final normY = y / size.height;
      // Gentle rounded C/S wave curvature across bar height
      final wave1 = math.sin((normY * 1.4 * math.pi) - verticalPhase + phaseShift) * (2.4 * ampFactor);
      final wave2 = math.sin((normY * 2.8 * math.pi) - (verticalPhase * 1.1) + phaseShift) * (0.8 * ampFactor);
      return (baseFillWidth + wave1 + wave2).clamp(4.0, size.width);
    }

    // 2. Secondary Liquid Layer (Slightly lagging underlayer for fluid depth)
    if (!isFull) {
      final underPath = Path();
      underPath.moveTo(0, 0);
      underPath.lineTo(getMeniscusX(0, 1.1, 0.75), 0);
      for (double y = 1; y <= size.height; y += 2) {
        underPath.lineTo(getMeniscusX(y, 1.1, 0.75), y);
      }
      underPath.lineTo(0, size.height);
      underPath.close();

      final underPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(baseFillWidth, 0),
          [
            theme.primary.withValues(alpha: 0.50),
            theme.secondary.withValues(alpha: 0.65),
          ],
        );
      canvas.drawPath(underPath, underPaint);
    }

    // 3. Main Liquid Body Path
    final mainLiquidPath = Path();
    mainLiquidPath.moveTo(0, 0);
    mainLiquidPath.lineTo(getMeniscusX(0, 0, 1.0), 0);
    for (double y = 1; y <= size.height; y += 1.5) {
      mainLiquidPath.lineTo(getMeniscusX(y, 0, 1.0), y);
    }
    mainLiquidPath.lineTo(0, size.height);
    mainLiquidPath.close();

    // Clip to liquid path for interior fluid contents
    canvas.save();
    canvas.clipPath(mainLiquidPath);

    // 3a. Main Liquid Gradient Fill (Left to Right energetic glow)
    final mainLiquidPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(baseFillWidth, 0),
        [
          theme.primary,
          theme.secondary,
          theme.highlight,
        ],
        [0.0, 0.65, 1.0],
      );
    canvas.drawRect(rect, mainLiquidPaint);

    // 3b. Downward Liquid Currents (Vertical ribbons flowing top to bottom slowly)
    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    for (int i = 0; i < 3; i++) {
      final ribbonOffset = (i + 1) * 0.28;
      if (ribbonOffset * baseFillWidth < baseFillWidth - 6) {
        final rX = ribbonOffset * baseFillWidth;
        final rPath = Path();
        rPath.moveTo(rX, 0);
        for (double y = 1; y <= size.height; y += 2) {
          final waveCurX = rX +
              math.sin((y / size.height * 2.2 * math.pi) - (verticalPhase * 0.75) + (i * 1.8)) * 2.5;
          rPath.lineTo(waveCurX, y);
        }
        ribbonPaint.shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [
            theme.highlight.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.35),
            theme.secondary.withValues(alpha: 0.20),
          ],
          const [0.0, 0.5, 1.0],
        );
        canvas.drawPath(rPath, ribbonPaint);
      }
    }

    // 3c. Downward Cascading Liquid Ripples
    for (int k = 0; k < 2; k++) {
      final rippleYProgress = ((animationProgress + (k * 0.5)) % 1.0);
      final rippleCenterY = rippleYProgress * size.height;
      final ripplePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, rippleCenterY - 4),
          Offset(0, rippleCenterY + 4),
          [
            Colors.transparent,
            theme.glow.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          const [0.0, 0.5, 1.0],
        );
      canvas.drawRect(
        Rect.fromLTWH(0, rippleCenterY - 3, baseFillWidth, 6),
        ripplePaint,
      );
    }

    // 3d. Container Glass Top Highlight (Glossy upper sheen)
    final sheenPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height * 0.35),
        [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, baseFillWidth, size.height * 0.35),
      sheenPaint,
    );

    canvas.restore(); // End clipping of liquid body
  }

  @override
  bool shouldRepaint(covariant LiquidEnergyWavePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.fillProgress != fillProgress ||
        oldDelegate.theme != theme;
  }
}

/// Neo-Brutalist Horizontal Energy Wave Bar
/// Displays continuous animated energy waves rolling horizontally from left to right
/// with rich dynamic colors changing for each streak day count.
class HorizontalEnergyWaveBar extends StatefulWidget {
  final int streakDays;
  final double height;

  const HorizontalEnergyWaveBar({
    super.key,
    required this.streakDays,
    this.height = 32.0,
  });

  @override
  State<HorizontalEnergyWaveBar> createState() => _HorizontalEnergyWaveBarState();
}

class _HorizontalEnergyWaveBarState extends State<HorizontalEnergyWaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStreak = widget.streakDays > 0 ? widget.streakDays : 1;
    final theme = StreakEnergyTheme.forStreak(effectiveStreak);
    final percent = effectiveStreak >= theme.targetDays
        ? 100
        : ((effectiveStreak / theme.targetDays) * 100).round().clamp(1, 100);
    final isRightOnLiquid = percent >= 75;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Colors.black,
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2.5, 2.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.2),
            child: Stack(
              children: [
                // 1. Liquid Energy Wave Painter (Top-to-bottom waves, left-to-right progress fill)
                Positioned.fill(
                  child: CustomPaint(
                    painter: LiquidEnergyWavePainter(
                      animationProgress: _controller.value,
                      fillProgress: percent / 100.0,
                      theme: theme,
                    ),
                  ),
                ),

                // 2. Foreground Neo-Brutalist Content (Aligned to right, no milestone title)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Right: Percentage and streak days count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: isRightOnLiquid ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: 0.4,
                                shadows: isRightOnLiquid
                                    ? const [
                                        Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(1.2, 1.2)),
                                        Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(-1.0, -1.0)),
                                        Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(1.0, -1.0)),
                                        Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(-1.0, 1.0)),
                                      ]
                                    : const [
                                        Shadow(color: Colors.white, blurRadius: 2.0, offset: Offset(0.6, 0.6)),
                                        Shadow(color: Colors.white, blurRadius: 2.0, offset: Offset(-0.6, -0.6)),
                                      ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($effectiveStreak/${theme.targetDays} ngày)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isRightOnLiquid ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF334155),
                                letterSpacing: 0.2,
                                shadows: isRightOnLiquid
                                    ? const [
                                        Shadow(color: Colors.black, blurRadius: 3.5, offset: Offset(1.0, 1.0)),
                                        Shadow(color: Colors.black, blurRadius: 3.5, offset: Offset(-0.8, -0.8)),
                                        Shadow(color: Colors.black, blurRadius: 3.5, offset: Offset(0.8, -0.8)),
                                        Shadow(color: Colors.black, blurRadius: 3.5, offset: Offset(-0.8, 0.8)),
                                      ]
                                    : const [
                                        Shadow(color: Colors.white, blurRadius: 2.0, offset: Offset(0.5, 0.5)),
                                      ],
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
        );
      },
    );
  }
}
