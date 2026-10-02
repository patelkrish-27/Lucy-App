import 'dart:math' as math;
import 'package:flutter/material.dart';

class LucyGlow extends StatelessWidget {
  const LucyGlow({super.key, this.size = 120, this.child});

  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .92, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      builder: (context, value, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFB58CFF).withValues(alpha: .28),
              const Color(0xFF7C4DFF).withValues(alpha: .06),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class Sparkles extends StatefulWidget {
  const Sparkles({super.key, this.color = const Color(0xFFC77CFF)});

  final Color color;

  @override
  State<Sparkles> createState() => _SparklesState();
}

class _SparklesState extends State<Sparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
      builder: (_, __) {
        final t = _controller.value * math.pi * 2;
        return CustomPaint(
          painter: _SparklePainter(widget.color, t),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color, this.t);
  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .55);
    final points = [
      Offset(size.width * .12, size.height * (.25 + .03 * math.sin(t))),
      Offset(size.width * .84, size.height * (.20 + .04 * math.cos(t))),
      Offset(size.width * .78, size.height * (.78 + .03 * math.sin(t * 1.4))),
      Offset(size.width * .22, size.height * (.72 + .04 * math.cos(t * 1.2))),
    ];
    for (final p in points) {
      canvas.drawCircle(p, 2.4 + math.sin(t + p.dx) * 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}

class LucyPageHeader extends StatelessWidget {
  const LucyPageHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LucyCard extends StatelessWidget {
  const LucyCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
