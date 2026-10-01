import 'package:flutter/material.dart';

/// Flat Design Burning Streak Number:
/// - Clean, high-contrast flat pill badge
/// - Sharp typography with fiery flat gradient
/// - Clean vector flame icon
/// - Zero blur glow shadows, zero particle noise
/// - Subtle flat breathing micro-animation
class BurningStreakNumber extends StatefulWidget {
  final int streakDays;
  final VoidCallback? onTap;
  final bool isCompact;

  const BurningStreakNumber({
    super.key,
    required this.streakDays,
    this.onTap,
    this.isCompact = false,
  });

  @override
  State<BurningStreakNumber> createState() => BurningStreakNumberState();
}

class BurningStreakNumberState extends State<BurningStreakNumber>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late AnimationController _igniteController;
  late Animation<double> _igniteScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _igniteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _igniteScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.24)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.24, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_igniteController);
  }

  void ignite() {
    if (mounted) {
      _igniteController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _igniteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStreak = widget.streakDays > 0;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _igniteScale]),
      builder: (context, child) {
        final scale = (hasStreak ? _scaleAnimation.value : 1.0) * _igniteScale.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.isCompact ? 9 : 12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 8 : 11,
              vertical: widget.isCompact ? 3.5 : 6,
            ),
            decoration: BoxDecoration(
              color: hasStreak ? const Color(0xFFFFF7ED) : Colors.white,
              borderRadius: BorderRadius.circular(widget.isCompact ? 9 : 12),
              border: Border.all(
                color: Colors.black,
                width: widget.isCompact ? 1.8 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: widget.isCompact ? const Offset(2.0, 2.0) : const Offset(2.8, 2.8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Clean vector flame icon
                Icon(
                  Icons.local_fire_department_rounded,
                  size: widget.isCompact ? 14.5 : 17.0,
                  color: hasStreak
                      ? const Color(0xFFEA580C)
                      : const Color(0xFF64748B),
                ),
                SizedBox(width: widget.isCompact ? 3.0 : 4.0),

                // Streak digits (bold, high-contrast)
                Text(
                  '${widget.streakDays}',
                  style: TextStyle(
                    fontSize: widget.isCompact ? 13.0 : 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: hasStreak
                        ? const Color(0xFFEA580C)
                        : const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                SizedBox(width: widget.isCompact ? 3.0 : 4.0),

                // Flat text label
                Text(
                  'NGÀY',
                  style: TextStyle(
                    fontSize: widget.isCompact ? 8.5 : 10.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: hasStreak
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
