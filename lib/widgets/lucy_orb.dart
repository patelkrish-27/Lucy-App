import 'package:flutter/material.dart';

class LucyOrb extends StatelessWidget {
  const LucyOrb({super.key, this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFE5D8FF),
            Color(0xFFB58CFF),
            Color(0xFF6841B5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B70FF).withValues(alpha: .28),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * .42,
          height: size * .42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .92),
          ),
        ),
      ),
    );
  }
}
