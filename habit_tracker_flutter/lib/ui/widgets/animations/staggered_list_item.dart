import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';

/// Staggered entrance animation for habit cards and list items.
/// Animates opacity 0->1, translationY 20->0, scale 0.97->1.0 with a crisp 45ms delay per item.
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayStep;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = AppAnimationConstants.cardEntrance,
    this.delayStep = AppAnimationConstants.cardStaggerDelay,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translateY;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _translateY = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimationConstants.curveEnter),
    );

    _scale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimationConstants.curveEnter),
    );

    // Stagger delay based on index (capped at 5 to keep it ultra snappy)
    final delayIndex = widget.index.clamp(0, 5);
    Future.delayed(widget.delayStep * delayIndex, () {
      if (mounted) {
        _controller.forward();
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
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
