import 'package:flutter/material.dart';
import '../../../core/animations/animation_constants.dart';

/// Wraps a habit card to provide a graceful exit animation when deleted or archived.
/// Animates scale: 1 -> 0.95, opacity: 1 -> 0, translationX: 0 -> -30.
class AnimatedDeleteWrapper extends StatefulWidget {
  final Widget child;
  final bool isDeleting;
  final VoidCallback onDeleted;

  const AnimatedDeleteWrapper({
    super.key,
    required this.child,
    this.isDeleting = false,
    required this.onDeleted,
  });

  @override
  State<AnimatedDeleteWrapper> createState() => _AnimatedDeleteWrapperState();
}

class _AnimatedDeleteWrapperState extends State<AnimatedDeleteWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _translateX;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _translateX = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDeleteWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isDeleting && widget.isDeleting) {
      if (AppAnimationConstants.isReduceMotion(context)) {
        widget.onDeleted();
      } else {
        _controller.forward().then((_) {
          widget.onDeleted();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0.0) return widget.child;

        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(_translateX.value, 0),
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
