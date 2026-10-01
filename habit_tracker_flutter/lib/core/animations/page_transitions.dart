import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Clean sports/manga page transition: snappy Fade + subtle Slide.
/// Duration 240ms, non-distracting, buttery 60 FPS.
class SportsPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SportsPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimationConstants.pageTransition,
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (AppAnimationConstants.isReduceMotion(context)) {
              return child;
            }

            final curved = CurvedAnimation(
              parent: animation,
              curve: AppAnimationConstants.curveEnter,
              reverseCurve: AppAnimationConstants.curveExit,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
