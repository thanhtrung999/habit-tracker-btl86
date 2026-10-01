import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../viewmodels/habit_viewmodel.dart';
import 'animations/burning_streak_number.dart';
import 'stacked_habit_deck.dart';

/// Neo-Brutalist Concentric Multi-Ring Habit Chart:
/// - Displays concentric circular progress rings corresponding to each Parent Category.
/// - Outermost ring = Category 1, working inward for each subsequent category.
/// - In the center: Completed / Total tasks count (e.g., "5/6") with clear status label.
/// - On the right: Streak badge (inside frame) + Parent tasks with text colored matching their parent cards.
/// - Supports reactive pulse animation when stars from a completed category arrive at the chart.
class ConcentricHabitRings extends StatefulWidget {
  final List<CategoryInfo> categories;
  final HabitViewModel viewModel;
  final int completedGoals;
  final int totalGoals;
  final int streakDays;
  final VoidCallback? onStreakTap;
  final GlobalKey<BurningStreakNumberState>? streakKey;
  final VoidCallback? onTap;
  final double collapseProgress;

  const ConcentricHabitRings({
    super.key,
    required this.categories,
    required this.viewModel,
    required this.completedGoals,
    required this.totalGoals,
    this.streakDays = 0,
    this.onStreakTap,
    this.streakKey,
    this.onTap,
    this.collapseProgress = 0.0,
  });

  @override
  State<ConcentricHabitRings> createState() => ConcentricHabitRingsState();
}

class ConcentricHabitRingsState extends State<ConcentricHabitRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  Color? _highlightColor;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 65,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Triggers a celebratory pulse and flash effect when stars hit this chart
  void pulse({Color? highlightColor}) {
    if (mounted) {
      setState(() {
        _highlightColor = highlightColor;
      });
      _pulseController.forward(from: 0.0);
    }
  }

  static Color _getCategoryTextColor(String cat, Color fallback) {
    switch (cat.toUpperCase()) {
      case 'SỨC KHỎE':
        return const Color(0xFF16A34A); // Rich green
      case 'THỂ THAO':
        return const Color(0xFFD97706); // Rich amber/orange
      case 'HỌC TẬP':
        return const Color(0xFF0284C7); // Rich sky blue
      case 'TÂM TRÍ':
        return const Color(0xFF7C3AED); // Rich purple
      case 'TÀI CHÍNH':
        return const Color(0xFFCA8A04); // Rich gold/amber (Yellow 600)
      case 'CÔNG VIỆC':
        return const Color(0xFFDB2777); // Rich pink
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalGoals == 0) {
      return const SizedBox.shrink();
    }

    final p = widget.collapseProgress.clamp(0.0, 1.0);
    final chartSize = lerpDouble(98.0, 72.0, p)!;
    final vertPadding = lerpDouble(9.0, 6.5, p)!;
    final horizPadding = lerpDouble(14.0, 12.0, p)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizPadding,
            vertical: vertPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black,
              width: 2.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(3.5, 3.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Shrunk Concentric Multi-Ring with Bold Center Ratio
              AnimatedBuilder(
                animation: _pulseScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScale.value,
                    child: child,
                  );
                },
                child: RepaintBoundary(
                  child: SizedBox(
                    width: chartSize,
                    height: chartSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(chartSize, chartSize),
                          painter: _ConcentricRingsPainter(
                            categories: widget.categories,
                            viewModel: widget.viewModel,
                            pulseValue: _pulseController.value,
                            highlightColor: _highlightColor,
                          ),
                        ),
                        _buildCenterContent(chartSize),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: lerpDouble(13.0, 11.0, p)!),

              // 2. Right Column:
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top: Label on left + Burning Streak badge flying into the frame on right!
                    SizedBox(
                      height: lerpDouble(16.0, 26.0, p)!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            p > 0.35 ? 'TIẾN TRÌNH' : 'TIẾN TRÌNH HÔM NAY',
                            style: TextStyle(
                              fontSize: lerpDouble(10.5, 9.8, p)!,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.4,
                            ),
                          ),
                          // Burning Streak Badge: clean compact pill without text clipping
                          if (p > 0.05)
                            Opacity(
                              opacity: p,
                              child: BurningStreakNumber(
                                key: widget.streakKey,
                                streakDays: widget.streakDays,
                                onTap: widget.onStreakTap,
                                isCompact: true,
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: lerpDouble(4.0, 6.0, p)!),

                    // Category items: Detailed 1-Col list when unscrolled, compact 2-Col grid (no numbers) when scrolled!
                    p > 0.35
                        ? _buildCompactCategoryGrid()
                        : _buildDetailedCategoryList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedCategoryList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.categories.take(6).map((cat) {
        final completed = cat.getCompletedCount(widget.viewModel);
        final total = cat.goals.length;
        final isDone = total > 0 && completed == total;
        final textColor = _getCategoryTextColor(cat.name, cat.color);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.2),
          child: Row(
            children: [
              // Category ring color dot
              Container(
                width: 6.5,
                height: 6.5,
                decoration: BoxDecoration(
                  color: cat.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 0.9),
                ),
              ),
              const SizedBox(width: 5),

              // Category Name (Colored by parent card color!)
              Expanded(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 4),

              // Fraction e.g. 2/2 or 0/1
              Text(
                '$completed/$total',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                  color: isDone
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ),

              if (isDone) ...[
                const SizedBox(width: 2.5),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 10.5,
                  color: Color(0xFF16A34A),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactCategoryGrid() {
    final cats = widget.categories.take(6).toList();

    return Wrap(
      spacing: 12.0,
      runSpacing: 4.5,
      children: cats.map((cat) => _buildCompactCategoryItem(cat)).toList(),
    );
  }

  Widget _buildCompactCategoryItem(CategoryInfo cat) {
    final textColor = _getCategoryTextColor(cat.name, cat.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 5.5,
          height: 5.5,
          decoration: BoxDecoration(
            color: cat.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 0.9),
          ),
        ),
        const SizedBox(width: 4.5),
        Text(
          cat.name,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent(double chartSize) {
    final scale = (chartSize / 98.0).clamp(0.65, 1.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${widget.completedGoals}',
          style: TextStyle(
            fontSize: 18.5 * scale,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          '/${widget.totalGoals}',
          style: TextStyle(
            fontSize: 14.0 * scale,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for rendering concentric circular progress rings
class _ConcentricRingsPainter extends CustomPainter {
  final List<CategoryInfo> categories;
  final HabitViewModel viewModel;
  final double pulseValue;
  final Color? highlightColor;

  _ConcentricRingsPainter({
    required this.categories,
    required this.viewModel,
    required this.pulseValue,
    this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = categories.length;
    if (n == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final isCompact = size.width < 80;
    final effMaxRadius = size.width * 0.47;
    final effInnerRadius = size.width * 0.22;
    final radialSpan = effMaxRadius - effInnerRadius;

    // Calculate dynamic strokeWidth and gap based on number of categories
    final double gap = isCompact ? 0.9 : (n > 4 ? 1.8 : 2.4);
    final double strokeWidth = ((radialSpan - (n - 1) * gap) / n)
        .clamp(isCompact ? 1.6 : 2.8, isCompact ? 3.0 : 8.0);

    // Optional highlight halo when stars hit the chart
    if (pulseValue > 0 && highlightColor != null) {
      final haloPaint = Paint()
        ..color = highlightColor!.withValues(alpha: (1.0 - pulseValue) * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCompact ? 3.5 : 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(center, effMaxRadius + (isCompact ? 1.5 : 3.0), haloPaint);
    }

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < n; i++) {
      final cat = categories[i];
      final r = effMaxRadius - (strokeWidth / 2) - i * (strokeWidth + gap);

      // 1. Draw Background Track (Muted Category Color)
      trackPaint.color = cat.color.withValues(alpha: 0.20);
      canvas.drawCircle(center, r, trackPaint);

      // 2. Draw Active Progress Arc
      final progress = cat.getProgress(viewModel);
      if (progress > 0) {
        progressPaint.color = cat.color;

        if (progress >= 0.999) {
          // Closed full circle
          canvas.drawCircle(center, r, progressPaint);
        } else {
          final sweepAngle = progress.clamp(0.0, 1.0) * 2 * pi;
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: r),
            -pi / 2, // Start at 12 o'clock
            sweepAngle,
            false,
            progressPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return true;
  }
}

/// Compact Concentric Multi-Ring Habit Chart for the Sticky Top Header:
/// - Displays when user scrolls past the main chart card.
/// - Minimalist Neo-Brutalist circular badge (50x50).
/// - Displays identical concentric rings in miniature + bold fraction in center.
/// - Supports pulse animation from star particles.
class CompactConcentricHabitRings extends StatefulWidget {
  final List<CategoryInfo> categories;
  final HabitViewModel viewModel;
  final int completedGoals;
  final int totalGoals;
  final VoidCallback? onTap;
  final double size;

  const CompactConcentricHabitRings({
    super.key,
    required this.categories,
    required this.viewModel,
    required this.completedGoals,
    required this.totalGoals,
    this.onTap,
    this.size = 70.0,
  });

  @override
  State<CompactConcentricHabitRings> createState() => CompactConcentricHabitRingsState();
}

class CompactConcentricHabitRingsState extends State<CompactConcentricHabitRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  Color? _highlightColor;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.16)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.16, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 65,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void pulse({Color? highlightColor}) {
    if (mounted) {
      setState(() {
        _highlightColor = highlightColor;
      });
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalGoals == 0) return const SizedBox.shrink();

    const chartSize = 140.0;
    const padH = 14.0;
    const padV = 12.0;

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black,
                width: 2.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3.5, 3.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: SizedBox(
              width: chartSize,
              height: chartSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(chartSize, chartSize),
                    painter: _ConcentricRingsPainter(
                      categories: widget.categories,
                      viewModel: widget.viewModel,
                      pulseValue: _pulseController.value,
                      highlightColor: _highlightColor,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.completedGoals}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '/${widget.totalGoals}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

