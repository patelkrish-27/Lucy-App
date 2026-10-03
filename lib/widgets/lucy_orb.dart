import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum LucyMascotState { idle, listening, thinking, working, success, error }

/// Premium, smooth Lucy mascot for mobile.
///
/// Unlike the desktop TUI, this uses a high-resolution SVG plush base plus
/// animated vector layers for pupils, blinking, expressions, accessories and
/// sparkles. There are intentionally no hands or legs.
class LucyMascot extends StatefulWidget {
  const LucyMascot({
    super.key,
    this.size = 270,
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
  late final AnimationController _motion;
  late final AnimationController _reaction;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
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
    _motion.dispose();
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
        animation: Listenable.merge([_motion, _reaction]),
        builder: (context, _) {
          final t = _motion.value * math.pi * 2;
          final breathe = 1 + math.sin(t) * .012;
          final bob = math.sin(t) * 2.0;
          final reaction =
              Curves.easeOutBack.transform(_reaction.value.clamp(0.0, 1.0));

          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.scale(
              scale: breathe + reaction * .012,
              child: SizedBox(
                width: widget.size,
                height: widget.size * .83,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/lucy/lucy_smooth.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LucyOverlayPainter(
                          state: widget.state,
                          phase: _motion.value,
                          reaction: reaction,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _Accessory { bow, catEars, halo, flower, heart, crown, star }

class _LucyOverlayPainter extends CustomPainter {
  const _LucyOverlayPainter({
    required this.state,
    required this.phase,
    required this.reaction,
  });

  final LucyMascotState state;
  final double phase;
  final double reaction;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 520;
    final sy = size.height / 430;
    canvas.save();
    canvas.scale(sx, sy);

    final time = phase * math.pi * 2;
    final accessory =
        _Accessory.values[((phase * 7.0).floor()) % _Accessory.values.length];

    var lookX = 0.0;
    var lookY = 0.0;
    switch (state) {
      case LucyMascotState.listening:
        lookX = 8;
        break;
      case LucyMascotState.thinking:
        lookX = -13;
        lookY = -9;
        break;
      case LucyMascotState.working:
        lookX = 9;
        lookY = 3;
        break;
      case LucyMascotState.success:
        lookY = -5;
        break;
      case LucyMascotState.error:
        lookY = 4;
        break;
      case LucyMascotState.idle:
        final wander = math.sin(time * .55);
        lookX = wander * 5;
        lookY = math.cos(time * .7) * 2;
        break;
    }

    final blinkPhase = (phase * 2.7) % 1.0;
    final blinking = blinkPhase > .935 && blinkPhase < .985;

    // Glossy violet pupils. These are separate from the SVG eye whites,
    // allowing Lucy to look around smoothly.
    _paintEye(canvas, const Offset(182, 213), lookX, lookY, blinking, time);
    _paintEye(canvas, const Offset(338, 213), lookX, lookY, blinking, time);

    // State expression overlays.
    final expression = Paint()
      ..color = const Color(0xFF4A226F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    if (state == LucyMascotState.success) {
      canvas.drawArc(const Rect.fromLTWH(228, 263, 64, 35), 0, math.pi,
          false, expression);
    } else if (state == LucyMascotState.error) {
      canvas.drawArc(const Rect.fromLTWH(228, 280, 64, 28), math.pi, math.pi,
          false, expression);
    } else if (state == LucyMascotState.thinking) {
      canvas.drawOval(
        const Rect.fromLTWH(252, 274, 16, 11),
        Paint()..color = const Color(0xFF4A226F),
      );
    }

    _paintAccessory(canvas, accessory, time);
    _paintSparkles(canvas, time);

    if (state == LucyMascotState.success) {
      _paintHeart(canvas, 455, 300, 1.0 + math.sin(time * 2) * .12);
    }

    canvas.restore();
  }

  void _paintEye(
    Canvas canvas,
    Offset center,
    double lookX,
    double lookY,
    bool blinking,
    double time,
  ) {
    if (blinking) {
      final lid = Paint()..color = const Color(0xFFC9A5F4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy),
          width: 108,
          height: 48,
        ),
        lid,
      );
      canvas.drawLine(
        Offset(center.dx - 47, center.dy),
        Offset(center.dx + 47, center.dy),
        Paint()
          ..color = const Color(0xFF4B216F)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final p = Offset(center.dx + lookX, center.dy + lookY);
    final iris = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFB887FF),
          Color(0xFF6331C0),
          Color(0xFF241044),
        ],
      ).createShader(
        Rect.fromCenter(center: p, width: 76, height: 86),
      );

    canvas.drawOval(
      Rect.fromCenter(center: p, width: 76, height: 86),
      iris,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(p.dx - 12, p.dy - 17),
        width: 18,
        height: 24,
      ),
      Paint()..color = Colors.white,
    );

    final twinkle = (.5 + .5 * math.sin(time * 3.0 + center.dx)) ;
    if (twinkle > .15) {
      canvas.drawCircle(
        Offset(p.dx + 15, p.dy + 18),
        4 + twinkle * 2,
        Paint()..color = const Color(0xFFDCC9FF),
      );
    }

    if (state == LucyMascotState.listening) {
      final ring = Paint()
        ..color = const Color(0xFFB87BFF).withValues(alpha: .16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 94, height: 104),
        ring,
      );
    }
  }

  void _paintAccessory(Canvas canvas, _Accessory accessory, double time) {
    final purple = Paint()..color = const Color(0xFF9D65E5);
    final light = Paint()..color = const Color(0xFFD3A8FF);
    final pink = Paint()..color = const Color(0xFFFF86C5);
    final gold = Paint()..color = const Color(0xFFFFD56A);

    switch (accessory) {
      case _Accessory.bow:
        canvas.drawOval(const Rect.fromLTWH(344, 43, 75, 82), purple);
        canvas.drawOval(const Rect.fromLTWH(397, 49, 82, 78), purple);
        canvas.drawCircle(const Offset(405, 88), 25, light);
        break;
      case _Accessory.catEars:
        final left = Path()
          ..moveTo(350, 103)
          ..lineTo(365, 25)
          ..lineTo(407, 92)
          ..close();
        final right = Path()
          ..moveTo(408, 92)
          ..lineTo(457, 25)
          ..lineTo(474, 106)
          ..close();
        canvas.drawPath(left, purple);
        canvas.drawPath(right, purple);
        break;
      case _Accessory.halo:
        final halo = Paint()
          ..color = light.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9;
        canvas.drawOval(const Rect.fromLTWH(330, 20, 145, 45), halo);
        break;
      case _Accessory.flower:
        for (final o in const [
          Offset(392, 50),
          Offset(420, 66),
          Offset(410, 96),
          Offset(378, 86),
          Offset(374, 58),
        ]) {
          canvas.drawCircle(o, 20, pink);
        }
        canvas.drawCircle(const Offset(397, 73), 13, gold);
        break;
      case _Accessory.heart:
        _paintHeart(canvas, 405, 65, 1.35);
        break;
      case _Accessory.crown:
        final crown = Path()
          ..moveTo(345, 92)
          ..lineTo(360, 25)
          ..lineTo(402, 63)
          ..lineTo(438, 23)
          ..lineTo(464, 92)
          ..close();
        canvas.drawPath(crown, gold);
        break;
      case _Accessory.star:
        _paintStar(canvas, 405, 66, light, 1.3);
        break;
    }

    // A tiny accessory shimmer makes changes feel intentional rather than
    // like a hard image swap.
    final shimmer = .25 + .25 * math.sin(time * 2);
    canvas.drawCircle(
      const Offset(465, 125),
      3 + shimmer * 5,
      Paint()..color = Colors.white.withValues(alpha: shimmer),
    );
  }

  void _paintSparkles(Canvas canvas, double time) {
    final pulse = .35 + .65 * (.5 + .5 * math.sin(time * 2.2));
    final paint = Paint()
      ..color = const Color(0xFFC99AFF).withValues(alpha: pulse);
    _sparkle(canvas, 65, 160, 7, paint);
    _sparkle(canvas, 458, 185, 6, paint);
    _sparkle(canvas, 92, 300, 4, paint);

    if (state == LucyMascotState.listening ||
        state == LucyMascotState.thinking ||
        state == LucyMascotState.working) {
      _sparkle(canvas, 475, 275, 5, paint);
      _sparkle(canvas, 40, 250, 4, paint);
    }
  }

  void _sparkle(Canvas canvas, double x, double y, double r, Paint paint) {
    canvas.drawLine(Offset(x - r, y), Offset(x + r, y), paint..strokeWidth = 3);
    canvas.drawLine(Offset(x, y - r), Offset(x, y + r), paint..strokeWidth = 3);
  }

  void _paintHeart(Canvas canvas, double x, double y, double scale) {
    final p = Path()
      ..moveTo(x, y + 24 * scale)
      ..cubicTo(
        x - 35 * scale,
        y,
        x - 18 * scale,
        y - 28 * scale,
        x,
        y - 10 * scale,
      )
      ..cubicTo(
        x + 18 * scale,
        y - 28 * scale,
        x + 35 * scale,
        y,
        x,
        y + 24 * scale,
      )
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFFF86C5));
  }

  void _paintStar(
    Canvas canvas,
    double x,
    double y,
    Paint paint,
    double scale,
  ) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = (i.isEven ? 28 : 11) * scale;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(x + math.cos(a) * r, y + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LucyOverlayPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.phase != phase ||
      oldDelegate.reaction != reaction;
}
