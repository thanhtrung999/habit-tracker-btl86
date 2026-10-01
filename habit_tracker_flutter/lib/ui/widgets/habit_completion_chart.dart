import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/date_utils.dart';
import '../viewmodels/habit_viewmodel.dart';

class HabitChartPoint {
  final String label;
  final double percentage;
  final DateTime date;
  final bool hasRealData;

  const HabitChartPoint({
    required this.label,
    required this.percentage,
    required this.date,
    required this.hasRealData,
  });
}

class HabitCompletionChart extends StatefulWidget {
  final HabitViewModel viewModel;

  const HabitCompletionChart({
    super.key,
    required this.viewModel,
  });

  @override
  State<HabitCompletionChart> createState() => _HabitCompletionChartState();
}

class _HabitCompletionChartState extends State<HabitCompletionChart>
    with SingleTickerProviderStateMixin {
  String _selectedRange = 'Last 6 Months';
  int _selectedIndex = 3; // Default to Oct or clamped in build
  late AnimationController _animController;
  late Animation<double> _animCurve;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (now.month >= 7 && now.month <= 12) {
      _selectedIndex = now.month - 7;
    } else {
      _selectedIndex = 0;
    }
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
  void didUpdateWidget(covariant HabitCompletionChart oldWidget) {
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

  /// Calculates actual monthly completion rate from records, or returns 0.0 if no data or future
  double _calculateRealMonthRate(int year, int month) {
    int total = 0;
    int completed = 0;
    final daysInMonth = AppDateUtils.getDaysInMonth(year, month);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final d = DateTime(year, month, day);
      if (d.isAfter(today)) continue;
      final dateStr = AppDateUtils.formatDate(d);
      final scheduled = widget.viewModel.goals
          .where((g) => g.isScheduledForDate(d))
          .toList();
      if (scheduled.isEmpty) continue;

      total += scheduled.length;
      for (final g in scheduled) {
        final rec = widget.viewModel.allRecordsMap['${g.id}_$dateStr'];
        if (rec != null && rec.completed) {
          completed++;
        }
      }
    }

    if (total == 0) return 0.0;
    return (completed / total) * 100.0;
  }

  List<HabitChartPoint> _getDataPoints() {
    final now = DateTime.now();
    final currentYear = now.year;

    // Default 6-month layout: Jul, Aug, Sep, Oct, Nov, Dec
    final monthNames = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final List<HabitChartPoint> points = [];

    if (_selectedRange == 'Last 6 Months') {
      for (int i = 0; i < 6; i++) {
        final monthNum = 7 + i; // 7=Jul ... 12=Dec
        final date = DateTime(currentYear, monthNum, 1);
        final realRate = _calculateRealMonthRate(currentYear, monthNum);

        points.add(
          HabitChartPoint(
            label: monthNames[i],
            percentage: realRate.clamp(0.0, 100.0),
            date: date,
            hasRealData: realRate > 0,
          ),
        );
      }
    } else if (_selectedRange == 'Last 30 Days') {
      // 5 intervals of 6 days across the last 30 days
      for (int i = 4; i >= 0; i--) {
        final d = now.subtract(Duration(days: i * 6));
        final dateStr = AppDateUtils.formatDate(d);
        final scheduled = widget.viewModel.goals
            .where((g) => g.isScheduledForDate(d))
            .toList();
        int completed = 0;
        for (final g in scheduled) {
          final rec = widget.viewModel.allRecordsMap['${g.id}_$dateStr'];
          if (rec != null && rec.completed) completed++;
        }
        final rate = scheduled.isNotEmpty
            ? (completed / scheduled.length) * 100.0
            : 0.0;
        points.add(
          HabitChartPoint(
            label: '${d.day}/${d.month}',
            percentage: rate.clamp(0.0, 100.0),
            date: d,
            hasRealData: rate > 0,
          ),
        );
      }
    } else {
      // This Year: 6 bi-monthly periods
      final biMonthLabels = ['Feb', 'Apr', 'Jun', 'Aug', 'Oct', 'Dec'];
      final biMonthNumbers = [2, 4, 6, 8, 10, 12];
      for (int i = 0; i < 6; i++) {
        final m = biMonthNumbers[i];
        final realRate = _calculateRealMonthRate(currentYear, m);
        points.add(
          HabitChartPoint(
            label: biMonthLabels[i],
            percentage: realRate.clamp(0.0, 100.0),
            date: DateTime(currentYear, m, 1),
            hasRealData: realRate > 0,
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
                'Thời gian thống kê',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              _buildRangeOption('Last 6 Months', '6 tháng gần nhất (Mặc định)'),
              _buildRangeOption('Last 30 Days', '30 ngày gần nhất'),
              _buildRangeOption('This Year', 'Cả năm nay'),
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
              const Expanded(
                child: Text(
                  'Habit Completion Rate',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _showRangePicker,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 2),
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

          // 3. Chart with Interactive Touch
          AnimatedBuilder(
            animation: _animCurve,
            builder: (context, _) {
              return SizedBox(
                height: 240,
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
                        size: Size(constraints.maxWidth, 240),
                        painter: _HabitLineChartPainter(
                          points: points,
                          selectedIndex: _selectedIndex,
                          animationProgress: _animCurve.value,
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

  void _handleTouch(Offset localPos, double totalWidth, List<HabitChartPoint> points) {
    const yAxisWidth = 38.0;
    const rightMargin = 22.0;
    final plotLeft = yAxisWidth + 12.0;
    final plotRight = totalWidth - rightMargin;
    final plotWidth = plotRight - plotLeft;

    final n = points.length;
    if (n < 2) return;

    int closestIdx = 0;
    double minDist = double.infinity;

    for (int i = 0; i < n; i++) {
      final x = plotLeft + (i / (n - 1)) * plotWidth;
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

class _HabitLineChartPainter extends CustomPainter {
  final List<HabitChartPoint> points;
  final int selectedIndex;
  final double animationProgress;

  _HabitLineChartPainter({
    required this.points,
    required this.selectedIndex,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const yAxisWidth = 38.0;
    const rightMargin = 22.0;
    const topMargin = 52.0; // Ample headroom for the pin tooltip
    const bottomMargin = 28.0; // Space for X-axis labels

    final plotLeft = yAxisWidth + 12.0;
    final plotRight = size.width - rightMargin;
    final plotTop = topMargin;
    final plotBottom = size.height - bottomMargin;
    final plotWidth = plotRight - plotLeft;
    final plotHeight = plotBottom - plotTop;

    // 1. Draw Y-axis labels: 100%, 80%, 60%, 40%, 20%, 0%
    final yLabels = ['100%', '80%', '60%', '40%', '20%', '0%'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = plotTop + (i / (yLabels.length - 1)) * plotHeight;
      final textPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(yAxisWidth - textPainter.width, y - textPainter.height / 2),
      );
    }

    final n = points.length;
    if (n == 0) return;

    // Calculate (x, y) for each data point
    final List<Offset> computedPoints = [];
    for (int i = 0; i < n; i++) {
      final x = plotLeft + (i / (n - 1)) * plotWidth;
      final targetY = plotBottom - ((points[i].percentage / 100.0) * plotHeight);
      // Animate from baseline plotBottom up to targetY
      final currentY = plotBottom - (plotBottom - targetY) * animationProgress;
      computedPoints.add(Offset(x, currentY));
    }

    // 2. Draw Month Labels at the bottom
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
        Offset(x - textPainter.width / 2, plotBottom + 10),
      );
    }

    // Extrapolate endpoints to extend slightly past the first and last dots
    final extStart = Offset(
      plotLeft - 10.0,
      computedPoints[0].dy + (computedPoints[0].dy - computedPoints[1].dy) * 0.15,
    );
    final extEnd = Offset(
      plotRight + 10.0,
      computedPoints[n - 1].dy + (computedPoints[n - 1].dy - computedPoints[n - 2].dy) * 0.15,
    );

    final allSplinePoints = [extStart, ...computedPoints, extEnd];

    // 3. Draw Gradient Fill Under Curve
    final fillPath = Path();
    fillPath.moveTo(extStart.dx, plotBottom);
    fillPath.lineTo(extStart.dx, extStart.dy);
    _drawSmoothSpline(fillPath, allSplinePoints);
    fillPath.lineTo(extEnd.dx, plotBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7B78EE).withValues(alpha: 0.25),
          const Color(0xFF7B78EE).withValues(alpha: 0.01),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTRB(plotLeft - 10, plotTop, plotRight + 10, plotBottom));
    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Line Stroke
    final linePath = Path();
    linePath.moveTo(extStart.dx, extStart.dy);
    _drawSmoothSpline(linePath, allSplinePoints);

    final strokePaint = Paint()
      ..color = const Color(0xFF7B78EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, strokePaint);

    // 5. Draw Circular Node Dots
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

    // 6. Draw Active Pin Tooltip on selected point
    if (selectedIndex >= 0 && selectedIndex < n && animationProgress > 0.5) {
      final selPt = computedPoints[selectedIndex];
      _drawPinTooltip(canvas, selPt, points[selectedIndex].percentage);
    }
  }

  void _drawSmoothSpline(Path path, List<Offset> pts) {
    if (pts.length < 2) return;
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i < pts.length - 2 ? pts[i + 2] : p2;

      const tension = 0.25;
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * tension,
        p1.dy + (p2.dy - p0.dy) * tension,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * tension,
        p2.dy - (p3.dy - p1.dy) * tension,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  void _drawPinTooltip(Canvas canvas, Offset nodePt, double percentage) {
    const pinRadius = 18.5;
    final pinCenter = Offset(nodePt.dx, nodePt.dy - 35.0);
    final tip = Offset(nodePt.dx, nodePt.dy - 8.5);

    final pinPath = Path();
    pinPath.moveTo(tip.dx, tip.dy);
    // Left edge of beak up to circle
    pinPath.lineTo(pinCenter.dx - 8.5, pinCenter.dy + pinRadius * 0.82);
    // Circular arc over the top of the pin
    pinPath.arcToPoint(
      Offset(pinCenter.dx + 8.5, pinCenter.dy + pinRadius * 0.82),
      radius: const Radius.circular(pinRadius),
      clockwise: true,
      largeArc: true,
    );
    // Right edge of beak back to tip
    pinPath.lineTo(tip.dx, tip.dy);
    pinPath.close();

    // 1. Draw fill
    final pinFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinFillPaint);

    // 2. Draw border
    final pinBorderPaint = Paint()
      ..color = const Color(0xFF7B78EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(pinPath, pinBorderPaint);

    // 3. Draw percentage text inside circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${percentage.round()}%',
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        pinCenter.dx - textPainter.width / 2,
        pinCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _HabitLineChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points;
  }
}
