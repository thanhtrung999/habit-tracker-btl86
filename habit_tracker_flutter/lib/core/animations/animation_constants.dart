import 'package:flutter/material.dart';

/// Centralized animation durations, curves, and accessibility helpers
/// for the ATOMIC HABIT animation system.
class AppAnimationConstants {
  // Micro-interactions (toggles, button taps, icons)
  static const Duration microFast = Duration(milliseconds: 150);
  static const Duration micro = Duration(milliseconds: 220);
  static const Duration microSlow = Duration(milliseconds: 300);

  // Card & List Entrance
  static const Duration cardEntrance = Duration(milliseconds: 320);
  static const Duration cardStaggerDelay = Duration(milliseconds: 45);

  // Complex / Gamified Celebrations
  static const Duration checkActionTotal = Duration(milliseconds: 360);
  static const Duration ringProgress = Duration(milliseconds: 550);
  static const Duration countUp = Duration(milliseconds: 400);
  static const Duration milestonePowerUp = Duration(milliseconds: 950);
  static const Duration perfectDay = Duration(milliseconds: 1200);
  static const Duration pageTransition = Duration(milliseconds: 240);

  // Manga / Sports Curves
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveImpact = Curves.easeOutBack;
  static const Curve curvePulse = Curves.easeInOut;

  /// Returns adjusted duration respecting user's accessibility settings (Reduce Motion)
  static Duration getDuration(BuildContext context, Duration original) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return original;
  }

  /// Whether animations should be simplified for accessibility
  static bool isReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
