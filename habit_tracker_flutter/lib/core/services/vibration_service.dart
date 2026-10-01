import 'package:flutter/services.dart';

class VibrationService {
  static const MethodChannel _channel =
      MethodChannel('com.antigravity.habittracker/vibration');

  /// Crisp, tactile double-pulse haptic feedback when checking/completing a habit
  static Future<void> taskComplete() async {
    try {
      await _channel.invokeMethod('taskComplete');
    } catch (_) {
      // Fallback for platforms without native custom channel
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    }
  }

  /// Subtle tactile tick when unchecking a habit
  static Future<void> taskUncheck() async {
    try {
      await _channel.invokeMethod('taskUncheck');
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  /// Short tactile click for button / stepper taps
  static Future<void> click() async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': 35, 'amplitude': 180});
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }
}
