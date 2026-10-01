import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/date_utils.dart';
import '../viewmodels/habit_viewmodel.dart';

class MoodTier {
  final String emoji;
  final String title;
  final Color bandColor;

  const MoodTier({
    required this.emoji,
    required this.title,
    required this.bandColor,
  });
}

class MoodDataPoint {
  final String label;
  final double rate;
  final DateTime date;
  final bool hasRealData;

  const MoodDataPoint({
    required this.label,
    required this.rate,
    required this.date,
    required this.hasRealData,
  });
}

class MoodChart extends StatefulWidget {
  final HabitViewModel viewModel;

  const MoodChart({
    super.key,
    required this.viewModel,
  });

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart>
    with SingleTickerProviderStateMixin {
  String _selectedRange = 'This Week';
  int _selectedIndex = 0; // Default to today or clamped in build
  late AnimationController _animController;
  late Animation<double> _animCurve;

  static const List<MoodTier> moodTiers = [
    MoodTier(
      emoji: '😎',
      title: 'Tuyệt vời (80-100%)',
      bandColor: Color(0xFFEDF2FE), // Soft pastel blue
    ),
    MoodTier(
      emoji: '🥰',
      title: 'Rất tốt (60-80%)',
      bandColor: Color(0xFFECF9F1), // Soft pastel mint green
    ),
    MoodTier(
      emoji: '😐',
      title: 'Bình thường (40-60%)',
      bandColor: Color(0xFFF1EFFC), // Soft pastel lilac
    ),
    MoodTier(
      emoji: '🥺',
      title: 'Cố lên (20-40%)',
      bandColor: Color(0xFFFEF8E7), // Soft pastel warm cream
    ),
    MoodTier(
      emoji: '😡',
      title: 'Chưa đạt (0-20%)',
      bandColor: Color(0xFFFDECEC), // Soft pastel pink
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedIndex = (now.weekday - 1).clamp(0, 6);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animCurve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant MoodChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.allRecordsMap != widget.viewModel.allRecordsMap) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Calculates actual daily completion rate from records, or returns 0.0 if no records or future
  double _calculateRealDayRate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    if (targetDay.isAfter(today)) return 0.0;

    final dateStr = AppDateUtils.formatDate(date);
    final scheduled = widget.viewModel.goals
        .where((g) => g.isScheduledForDate(date))
        .toList();
    if (scheduled.isEmpty) return 0.0;

    int completed = 0;
    for (final g in scheduled) {
      final rec = widget.viewModel.allRecordsMap['${g.id}_$dateStr'];
      if (rec != null && rec.completed) completed++;
    }

    return (completed / scheduled.length) * 100.0;
  }

  List<MoodDataPoint> _getDataPoints() {
    final now = DateTime.now();
    final List<MoodDataPoint> points = [];

    if (_selectedRange == 'This Week') {
      // Find Monday of current week
      final currentWeekday = now.weekday; // 1=Mon ... 7=Sun
      final monday = now.subtract(Duration(days: currentWeekday - 1));

      for (int i = 0; i < 7; i++) {
        final d = DateTime(monday.year, monday.month, monday.day + i);
        final rate = _calculateRealDayRate(d);
        final label = '${d.day}';

        points.add(
          MoodDataPoint(
            label: label,
            rate: rate.clamp(0.0, 100.0),
            date: d,
            hasRealData: rate > 0,
          ),
        );
      }
    } else if (_selectedRange == 'Last Week') {
      final currentWeekday = now.weekday;
      final lastMonday = now.subtract(Duration(days: currentWeekday + 6));

      for (int i = 0; i < 7; i++) {
        final d = DateTime(lastMonday.year, lastMonday.month, lastMonday.day + i);
        final rate = _calculateRealDayRate(d);

        points.add(
          MoodDataPoint(
            label: '${d.day}',
            rate: rate.clamp(0.0, 100.0),
            date: d,
            hasRealData: rate > 0,
          ),
        );
      }
    } else {
      // Last 14 Days (7 2-day intervals)
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i * 2));
        final rate = _calculateRealDayRate(d);

        points.add(
          MoodDataPoint(
            label: '${d.day}',
            rate: rate.clamp(0.0, 100.0),
            date: d,
            hasRealData: rate > 0,
          ),
        );
      }
    }

    return points;
  }

  void _showRangePicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.black, width: 2.2),
              left: BorderSide(color: Colors.black, width: 2.2),
              right: BorderSide(color: Colors.black, width: 2.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Thời gian xem Mood',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              _buildRangeOption('This Week', 'Tuần này (Mặc định)'),
              _buildRangeOption('Last Week', 'Tuần trước'),
              _buildRangeOption('Last 14 Days', '14 ngày gần nhất'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeOption(String value, String title) {
    final isSelected = _selectedRange == value;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedRange = value;
          _selectedIndex = 0;
        });
        _animController.forward(from: 0.0);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.black, width: 1.8)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.black : const Color(0xFF334155),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF7B78EE),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = _getDataPoints();
    if (_selectedIndex >= points.length) {
      _selectedIndex = points.length - 1;
    }

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Title + Range Filter Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Mood Chart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: _showRangePicker,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedRange,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Subtle Divider
          const Divider(
            height: 26,
            thickness: 1.0,
            color: Color(0xFFF1F5F9),
          ),

          // 3. Mood Chart Area with 5 Colored Background Bands & Emojis
          AnimatedBuilder(
            animation: _animCurve,
            builder: (context, _) {
              return SizedBox(
                height: 250,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        _handleTouch(details.localPosition, constraints.maxWidth, points);
                      },
                      onPanUpdate: (details) {
                        _handleTouch(details.localPosition, constraints.maxWidth, points);
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, 250),
                        painter: _MoodLineChartPainter(
                          points: points,
                          selectedIndex: _selectedIndex,
                          animationProgress: _animCurve.value,
                          moodTiers: moodTiers,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPos, double totalWidth, List<MoodDataPoint> points) {
    const emojiWidth = 34.0;
    const bandLeftMargin = 12.0;
    const rightMargin = 16.0;
    final plotLeft = emojiWidth + bandLeftMargin;
    final plotRight = totalWidth - rightMargin;
    const paddingX = 14.0;
    final startX = plotLeft + paddingX;
    final endX = plotRight - paddingX;
    final totalSpan = endX - startX;

    final n = points.length;
    if (n < 2) return;

    int closestIdx = 0;
    double minDist = double.infinity;

    for (int i = 0; i < n; i++) {
      final x = startX + (i / (n - 1)) * totalSpan;
      final dist = (x - localPos.dx).abs();
      if (dist < minDist) {
        minDist = dist;
        closestIdx = i;
      }
    }

    if (closestIdx != _selectedIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedIndex = closestIdx;
      });
    }
  }
}

class _MoodLineChartPainter extends CustomPainter {
  final List<MoodDataPoint> points;
  final int selectedIndex;
  final double animationProgress;
  final List<MoodTier> moodTiers;

  _MoodLineChartPainter({
    required this.points,
    required this.selectedIndex,
    required this.animationProgress,
    required this.moodTiers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const emojiWidth = 34.0;
    const bandLeftMargin = 12.0;
    const rightMargin = 14.0;
    const topMargin = 10.0;
    const bottomMargin = 28.0;

    final plotLeft = emojiWidth + bandLeftMargin;
    final plotRight = size.width - rightMargin;
    final plotTop = topMargin;
    final plotBottom = size.height - bottomMargin;
    final plotHeight = plotBottom - plotTop;
    final bandHeight = plotHeight / 5.0;

    // 1. Draw 5 Colored Background Bands (Clipped with subtle rounded corners)
    final bandRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(plotLeft, plotTop, plotRight, plotBottom),
      const Radius.circular(8),
    );

    canvas.save();
    canvas.clipRRect(bandRRect);

    for (int i = 0; i < 5; i++) {
      final bandTop = plotTop + i * bandHeight;
      final bandPaint = Paint()
        ..color = moodTiers[i].bandColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTRB(plotLeft, bandTop, plotRight, bandTop + bandHeight),
        bandPaint,
      );
    }
    canvas.restore();

    // 2. Draw Left Emoji Icons centered in each band
    for (int i = 0; i < 5; i++) {
      final bandCenterY = plotTop + (i + 0.5) * bandHeight;
      final textPainter = TextPainter(
        text: TextSpan(
          text: moodTiers[i].emoji,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (emojiWidth - textPainter.width) / 2,
          bandCenterY - textPainter.height / 2,
        ),
      );
    }

    final n = points.length;
    if (n == 0) return;

    // 3. Compute Data Coordinates
    const paddingX = 14.0;
    final startX = plotLeft + paddingX;
    final endX = plotRight - paddingX;
    final totalSpan = endX - startX;

    final topCenterY = plotTop + 0.5 * bandHeight; // 100% (😎)
    final bottomCenterY = plotTop + 4.5 * bandHeight; // 0% (😡)
    final verticalSpan = bottomCenterY - topCenterY;

    final List<Offset> computedPoints = [];
    for (int i = 0; i < n; i++) {
      final x = startX + (i / (n - 1)) * totalSpan;
      final normalized = (points[i].rate / 100.0).clamp(0.0, 1.0);
      final targetY = bottomCenterY - (normalized * verticalSpan);
      final currentY = bottomCenterY - (bottomCenterY - targetY) * animationProgress;
      computedPoints.add(Offset(x, currentY));
    }

    // 4. Draw X-axis Day Labels below chart
    for (int i = 0; i < n; i++) {
      final x = computedPoints[i].dx;
      final isSelected = i == selectedIndex;
      final textPainter = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, plotBottom + 8),
      );
    }

    // 5. Draw Translucent Gradient Fill Under Line
    final fillPath = Path();
    fillPath.moveTo(plotLeft, plotBottom);
    fillPath.lineTo(plotLeft, computedPoints[0].dy);
    for (int i = 0; i < n; i++) {
      fillPath.lineTo(computedPoints[i].dx, computedPoints[i].dy);
    }
    fillPath.lineTo(plotRight, computedPoints[n - 1].dy);
    fillPath.lineTo(plotRight, plotBottom);
    fillPath.close();

    canvas.save();
    canvas.clipRRect(bandRRect);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7B78EE).withValues(alpha: 0.22),
          const Color(0xFF7B78EE).withValues(alpha: 0.02),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTRB(plotLeft, plotTop, plotRight, plotBottom));
    canvas.drawPath(fillPath, fillPaint);
    canvas.restore();

    // 6. Draw Line Stroke (Straight polyline with rounded joints like reference image)
    final linePath = Path();
    linePath.moveTo(plotLeft, computedPoints[0].dy);
    for (int i = 0; i < n; i++) {
      linePath.lineTo(computedPoints[i].dx, computedPoints[i].dy);
    }
    linePath.lineTo(plotRight, computedPoints[n - 1].dy);

    final strokePaint = Paint()
      ..color = const Color(0xFF7B78EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, strokePaint);

    // 7. Draw Circular Node Dots
    final dotFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF7B78EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    for (int i = 0; i < n; i++) {
      final pt = computedPoints[i];
      canvas.drawCircle(pt, 7.0, dotFillPaint);
      canvas.drawCircle(pt, 7.0, dotBorderPaint);
    }

    // 8. If selected point has real data or is tapped, show a small percentage pill badge
    if (selectedIndex >= 0 && selectedIndex < n && animationProgress > 0.6) {
      final selPt = computedPoints[selectedIndex];
      _drawSelectedBadge(canvas, selPt, points[selectedIndex].rate);
    }
  }

  void _drawSelectedBadge(Canvas canvas, Offset pt, double rate) {
    // Only draw a subtle highlight ring or mini badge if tapped
    final highlightPaint = Paint()
      ..color = const Color(0xFF7B78EE).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(pt, 10.5, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _MoodLineChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points;
  }
}
