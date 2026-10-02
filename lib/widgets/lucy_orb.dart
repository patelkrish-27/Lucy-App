import 'dart:math' as math;
import 'package:flutter/material.dart';

enum LucyMascotState {
  idle,
  listening,
  thinking,
  working,
  success,
  error,
}

/// Lucy is intentionally drawn from independent parts rather than rendered as
/// one flat image. This lets her eyes, arms, mouth, bow and body react to the
/// current agent state.
class LucyMascot extends StatefulWidget {
  const LucyMascot({
    super.key,
    this.size = 210,
    this.state = LucyMascotState.idle,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final double size;
  final LucyMascotState state;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  State<LucyMascot> createState() => _LucyMascotState();
}

class _LucyMascotState extends State<LucyMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _reaction;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _reaction = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant LucyMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _reaction
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _reaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _reaction]),
        builder: (context, _) {
          final t = _idle.value * math.pi * 2;
          final breathe = math.sin(t) * .018;
          final reaction = Curves.easeOutBack.transform(_reaction.value);
          final jump = widget.state == LucyMascotState.success
              ? math.sin(_reaction.value * math.pi) * .08
              : 0.0;
          final shake = widget.state == LucyMascotState.error
              ? math.sin(_reaction.value * math.pi * 8) * .025
              : 0.0;

          return SizedBox(
            width: widget.size * 1.35,
            height: widget.size * 1.35,
            child: Transform.translate(
              offset: Offset(
                shake * widget.size,
                -jump * widget.size +
                    (widget.state == LucyMascotState.thinking ? -3 : 0),
              ),
              child: Transform.rotate(
                angle: shake,
                child: Transform.scale(
                  scale: 1 + breathe + (reaction * .015),
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _LucyPainter(
                      state: widget.state,
                      t: t,
                      reaction: reaction,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LucyPainter extends CustomPainter {
  const _LucyPainter({
    required this.state,
    required this.t,
    required this.reaction,
  });

  final LucyMascotState state;
  final double t;
  final double reaction;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 210;
    final o = Offset(size.width / 2, size.height / 2);

    Offset p(double x, double y) => Offset(x * s, y * s);
    Paint fill(Color color) => Paint()..color = color;
    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fur = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFC9A2FF), Color(0xFF9361E8)],
    ).createShader(Rect.fromLTWH(35 * s, 30 * s, 140 * s, 160 * s));

    // Ground glow.
    canvas.drawOval(
      Rect.fromCenter(center: p(105, 191), width: 118 * s, height: 18 * s),
      fill(const Color(0x339B70FF)),
    );

    // Arms move independently with the state.
    var leftArm = 0.0;
    var rightArm = 0.0;
    if (state == LucyMascotState.listening) {
      leftArm = -.20;
      rightArm = .20;
    } else if (state == LucyMascotState.success) {
      leftArm = -.52;
      rightArm = .52;
    } else if (state == LucyMascotState.thinking) {
      rightArm = -.38;
    } else if (state == LucyMascotState.working) {
      leftArm = .08;
      rightArm = -.08;
    }

    void arm(double x, double y, double angle, bool left) {
      canvas.save();
      canvas.translate(x * s, y * s);
      canvas.rotate(angle);
      final armRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 35 * s, height: 72 * s),
        Radius.circular(20 * s),
      );
      canvas.drawRRect(armRect, Paint()..shader = fur);
      canvas.restore();
    }

    arm(49, 137, leftArm, true);
    arm(161, 137, rightArm, false);

    // Feet.
    canvas.drawOval(
      Rect.fromCenter(center: p(82, 178), width: 45 * s, height: 35 * s),
      Paint()..shader = fur,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(128, 178), width: 45 * s, height: 35 * s),
      Paint()..shader = fur,
    );

    // Body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(58 * s, 108 * s, 94 * s, 75 * s),
        Radius.circular(39 * s),
      ),
      Paint()..shader = fur,
    );

    // Head.
    final head = Path()
      ..moveTo(105 * s, 29 * s)
      ..cubicTo(60 * s, 28 * s, 37 * s, 56 * s, 40 * s, 92 * s)
      ..cubicTo(43 * s, 127 * s, 68 * s, 145 * s, 105 * s, 145 * s)
      ..cubicTo(142 * s, 145 * s, 167 * s, 127 * s, 170 * s, 92 * s)
      ..cubicTo(173 * s, 56 * s, 150 * s, 28 * s, 105 * s, 29 * s)
      ..close();
    canvas.drawPath(head, Paint()..shader = fur);

    // Soft cheek blush.
    canvas.drawOval(
      Rect.fromCenter(center: p(65, 111), width: 25 * s, height: 12 * s),
      fill(const Color(0x55FF7FB6)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(145, 111), width: 25 * s, height: 12 * s),
      fill(const Color(0x55FF7FB6)),
    );

    // Bow.
    final bow = fill(const Color(0xFF9D6AEF));
    canvas.drawOval(
      Rect.fromCenter(center: p(143, 38), width: 36 * s, height: 30 * s),
      bow,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(169, 38), width: 36 * s, height: 30 * s),
      bow,
    );
    canvas.drawCircle(p(156, 38), 9 * s, fill(const Color(0xFFB985FF)));

    // Eyes change expression and direction.
    final eyeY = state == LucyMascotState.working ? 87.0 : 91.0;
    var lookX = 0.0;
    var lookY = 0.0;
    if (state == LucyMascotState.listening) lookX = 3.0;
    if (state == LucyMascotState.thinking) {
      lookX = -3.5;
      lookY = -5.0;
    }
    if (state == LucyMascotState.working) lookX = -2.5;

    final eyeSize = state == LucyMascotState.listening ? 25.0 : 23.0;
    void eye(double x) {
      canvas.drawOval(
        Rect.fromCenter(
          center: p(x, eyeY),
          width: eyeSize * s,
          height: 31 * s,
        ),
        fill(Colors.white),
      );
      canvas.drawCircle(
        p(x + lookX, eyeY + lookY + 1),
        11 * s,
        fill(const Color(0xFF5B2AA6)),
      );
      canvas.drawCircle(
        p(x + lookX, eyeY + lookY + 1),
        7 * s,
        fill(const Color(0xFF24104A)),
      );
      canvas.drawCircle(
        p(x - 3 + lookX, eyeY - 4 + lookY),
        3.2 * s,
        fill(Colors.white),
      );
      canvas.drawCircle(
        p(x + 4 + lookX, eyeY + 4 + lookY),
        1.6 * s,
        fill(const Color(0xFFD9C2FF)),
      );
    }

    eye(78);
    eye(132);

    // Eyebrows.
    final brow = stroke(const Color(0xFF5B2A9F), 3);
    if (state == LucyMascotState.thinking) {
      canvas.drawArc(Rect.fromLTWH(65*s, 65*s, 25*s, 12*s), math.pi*1.05, math.pi*.65, false, brow);
      canvas.drawArc(Rect.fromLTWH(120*s, 65*s, 25*s, 12*s), math.pi*1.35, math.pi*.65, false, brow);
    }

    // Mouth changes with emotion.
    final mouth = stroke(const Color(0xFF4B217F), 3);
    if (state == LucyMascotState.success) {
      canvas.drawArc(Rect.fromLTWH(91*s, 100*s, 28*s, 18*s), 0, math.pi, false, mouth);
    } else if (state == LucyMascotState.error) {
      canvas.drawArc(Rect.fromLTWH(91*s, 108*s, 28*s, 15*s), math.pi, math.pi, false, mouth);
    } else if (state == LucyMascotState.thinking) {
      canvas.drawOval(Rect.fromLTWH(101*s, 104*s, 8*s, 11*s), mouth);
    } else {
      canvas.drawArc(Rect.fromLTWH(91*s, 101*s, 28*s, 18*s), 0, math.pi, false, mouth);
    }

    // State-specific cute details.
    final sparkle = fill(const Color(0xFFC77CFF));
    if (state == LucyMascotState.listening) {
      canvas.drawCircle(p(28, 72), 3*s, sparkle);
      canvas.drawCircle(p(181, 73), 3*s, sparkle);
      canvas.drawCircle(p(24, 84), 1.8*s, sparkle);
      canvas.drawCircle(p(185, 85), 1.8*s, sparkle);
    }

    if (state == LucyMascotState.thinking) {
      canvas.drawCircle(p(180, 49), 4*s, sparkle);
      canvas.drawCircle(p(191, 44), 3*s, sparkle);
      canvas.drawCircle(p(199, 39), 2*s, sparkle);
    }

    if (state == LucyMascotState.working) {
      canvas.drawLine(p(70, 76), p(84, 73), brow);
      canvas.drawLine(p(126, 73), p(140, 76), brow);
    }

    if (state == LucyMascotState.success) {
      for (final point in [p(29, 55), p(184, 54), p(37, 96), p(177, 97)]) {
        canvas.drawCircle(point, 3*s, sparkle);
      }
      final heart = fill(const Color(0xFFFF72C7));
      canvas.drawCircle(p(25, 112), 4*s, heart);
      canvas.drawCircle(p(31, 112), 4*s, heart);
      final path = Path()..moveTo(21*s,112*s)..lineTo(28*s,122*s)..lineTo(35*s,112*s)..close();
      canvas.drawPath(path, heart);
    }

    // Subtle fur highlight keeps the plush look.
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: p(87, 58), width: 62*s, height: 30*s),
      highlight,
    );

    // Keep the painter centred in the widget.
    canvas.drawCircle(o.translate(0, size.height * .001), 0.01, fill(Colors.transparent));
  }

  @override
  bool shouldRepaint(covariant _LucyPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.t != t ||
      oldDelegate.reaction != reaction;
}
