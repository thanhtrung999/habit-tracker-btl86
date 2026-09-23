import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const ConfettiOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        maxBlastForce: 25,
        minBlastForce: 10,
        emissionFrequency: 0.05,
        numberOfParticles: 35,
        gravity: 0.25,
        colors: const [
          Color(0xFF2D6A4F),
          Color(0xFF52B788),
          Color(0xFFF59E0B),
          Color(0xFF3B82F6),
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
        ],
      ),
    );
  }
}
