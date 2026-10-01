import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurvedNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const CurvedNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Floating bottom navigation bar with a smooth scoop notch and an animated
/// floating circular button that slides seamlessly to the active tab.
class CurvedScoopNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CurvedNavItem> items;

  const CurvedScoopNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CurvedScoopNavBar> createState() => _CurvedScoopNavBarState();
}

class _CurvedScoopNavBarState extends State<CurvedScoopNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _slideAnimation;
  double _currentSlideIndex = 0.0;

  @override
  void initState() {
    super.initState();
    _currentSlideIndex = widget.currentIndex.toDouble();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<double>(
      begin: _currentSlideIndex,
      end: _currentSlideIndex,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant CurvedScoopNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final oldPos = _currentSlideIndex;
      final newPos = widget.currentIndex.toDouble();
      _slideAnimation = Tween<double>(begin: oldPos, end: newPos).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        ),
      );
      _animController.forward(from: 0.0).then((_) {
        _currentSlideIndex = newPos;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 66.0;
    const double circleRadius = 25.0;
    const double circleYOffset = 4.0; // Distance of circle center from top of bar
    const double topProtrusion = 24.0; // Space above the bar for the floating circle
    const double totalHeight = barHeight + topProtrusion;
    const double cradleGap = 6.5; // Exact uniform gap around the button
    const double filletRadius = 10.0;
    const double barRadius = 20.0;
    const double insetX = 20.0;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final animatedIndex = _animController.isAnimating
            ? _slideAnimation.value
            : widget.currentIndex.toDouble();

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final usableW = w - insetX * 2;
            final tabW = usableW / widget.items.length;
            final activeXc = insetX + (animatedIndex + 0.5) * tabW;

            return SizedBox(
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. White Bar Container with Perfect Concentric Scoop Notch
                  Positioned(
                    top: topProtrusion,
                    left: 0,
                    right: 0,
                    height: barHeight,
                    child: CustomPaint(
                      painter: _ScoopNavBarPainter(
                        activeXc: activeXc,
                        circleYc: circleYOffset,
                        circleRadius: circleRadius,
                        gap: cradleGap,
                        filletRadius: filletRadius,
                        barRadius: barRadius,
                      ),
                    ),
                  ),

                  // 2. Elevated Floating Circular Action Button
                  Positioned(
                    top: topProtrusion + circleYOffset - circleRadius,
                    left: activeXc - circleRadius,
                    child: Container(
                      width: circleRadius * 2,
                      height: circleRadius * 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3F3F46),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Color(0x20000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            widget.items[widget.currentIndex].selectedIcon,
                            key: ValueKey(widget.currentIndex),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Tab Items (Icons & Text Labels)
                  Positioned(
                    top: topProtrusion,
                    left: insetX,
                    right: insetX,
                    bottom: 0,
                    child: Row(
                      children: List.generate(widget.items.length, (index) {
                        final isSelected = widget.currentIndex == index;
                        final item = widget.items[index];

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (widget.currentIndex != index) {
                                HapticFeedback.selectionClick();
                                widget.onTap(index);
                              }
                            },
                            child: SizedBox(
                              height: barHeight,
                              child: isSelected
                                  ? // Selected Tab: Label placed below the scooped notch
                                  Align(
                                      alignment: const Alignment(0, 0.62),
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                      ),
                                    )
                                  : // Unselected Tab: Normal Icon + Label layout
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          item.icon,
                                          size: 22,
                                          color: const Color(0xFFA1A1AA),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFA1A1AA),
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Custom painter that draws the floating capsule navbar with an exact concentric cradle notch
class _ScoopNavBarPainter extends CustomPainter {
  final double activeXc;
  final double circleYc;
  final double circleRadius;
  final double gap;
  final double filletRadius;
  final double barRadius;

  _ScoopNavBarPainter({
    required this.activeXc,
    required this.circleYc,
    required this.circleRadius,
    required this.gap,
    required this.filletRadius,
    required this.barRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rc = circleRadius + gap;
    final rf = filletRadius;
    final yc = circleYc;

    // Distance from activeXc to the tangency point with the top flat line (y=0)
    // dX = sqrt((rc + rf)^2 - (rf - yc)^2)
    final dX = math.sqrt(math.pow(rc + rf, 2) - math.pow(rf - yc, 2));
    final t = rf / (rc + rf);
    final dXt = (1.0 - t) * dX;
    final yt = rf - t * (rf - yc);

    final xlTop = activeXc - dX;
    final xrTop = activeXc + dX;
    final xtLeft = activeXc - dXt;
    final xtRight = activeXc + dXt;

    final path = Path();
    path.moveTo(barRadius, 0);

    // Left flat edge to scoop top tangency
    if (xlTop > barRadius) {
      path.lineTo(xlTop, 0);
    }

    // 1. Left fillet (curves smoothly into the cradle)
    path.arcToPoint(
      Offset(xtLeft, yt),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    // 2. Concentric circular cradle arc (hugs the circle with exact uniform gap everywhere)
    path.arcToPoint(
      Offset(xtRight, yt),
      radius: Radius.circular(rc),
      clockwise: false,
    );

    // 3. Right fillet (curves smoothly out to top edge)
    path.arcToPoint(
      Offset(xrTop, 0),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    // Right flat edge to corner radius
    if (xrTop < w - barRadius) {
      path.lineTo(w - barRadius, 0);
    }

    // Top-right rounded corner
    path.arcToPoint(
      Offset(w, barRadius),
      radius: Radius.circular(barRadius),
    );

    // Right vertical edge
    path.lineTo(w, h - barRadius);

    // Bottom-right rounded corner
    path.arcToPoint(
      Offset(w - barRadius, h),
      radius: Radius.circular(barRadius),
    );

    // Bottom flat edge
    path.lineTo(barRadius, h);

    // Bottom-left rounded corner
    path.arcToPoint(
      Offset(0, h - barRadius),
      radius: Radius.circular(barRadius),
    );

    // Left vertical edge
    path.lineTo(0, barRadius);

    // Top-left rounded corner
    path.arcToPoint(
      Offset(barRadius, 0),
      radius: Radius.circular(barRadius),
    );
    path.close();

    // Soft ambient floating shadow
    final ambientShadow = Paint()
      ..color = const Color(0x28000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 5)), ambientShadow);

    // Crisp directional shadow
    final keyShadow = Paint()
      ..color = const Color(0x14000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(0, 2)), keyShadow);

    // Black navbar body fill
    final fillPaint = Paint()
      ..color = const Color(0xFF18181B)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle dark border
    final borderPaint = Paint()
      ..color = const Color(0xFF27272A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoopNavBarPainter oldDelegate) {
    return oldDelegate.activeXc != activeXc ||
        oldDelegate.circleYc != circleYc ||
        oldDelegate.circleRadius != circleRadius ||
        oldDelegate.gap != gap ||
        oldDelegate.filletRadius != filletRadius ||
        oldDelegate.barRadius != barRadius;
  }
}
