import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/milestone_tiers.dart';

class StreakFlame extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onTap;

  const StreakFlame({
    super.key,
    required this.streakDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tier = MilestoneConstants.getTier(streakDays);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tier.badgeBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tier.badgeBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tier.color.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: const TextStyle(fontSize: 18),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.15, 1.15),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(width: 6),
            Text(
              '$streakDays ngày',
              style: TextStyle(
                color: tier.color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              tier.icon,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
