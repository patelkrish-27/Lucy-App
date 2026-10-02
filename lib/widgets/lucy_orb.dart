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
  late final AnimationController _breath;
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant LucyMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _motion
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _motion.dispose();
    super.dispose();
  }

  double get _tilt {
    switch (widget.state) {
      case LucyMascotState.listening:
        return -0.035;
      case LucyMascotState.thinking:
        return 0.045;
      case LucyMascotState.working:
        return -0.018;
      case LucyMascotState.error:
        return 0;
      default:
        return 0;
    }
  }

  double get _lift {
    switch (widget.state) {
      case LucyMascotState.listening:
        return 2;
      case LucyMascotState.thinking:
        return -4;
      case LucyMascotState.working:
        return 3;
      case LucyMascotState.success:
        return -12;
      default:
        return 0;
    }
  }

  Color get _glow {
    switch (widget.state) {
      case LucyMascotState.listening:
        return const Color(0xFFB58CFF);
      case LucyMascotState.thinking:
        return const Color(0xFF8F7CFF);
      case LucyMascotState.working:
        return const Color(0xFF7B61FF);
      case LucyMascotState.success:
        return const Color(0xFFFF77D9);
      case LucyMascotState.error:
        return const Color(0xFFFF6B8A);
      default:
        return const Color(0xFF9B70FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _motion]),
        builder: (context, child) {
          final breathe = math.sin(_breath.value * math.pi) * 0.018;
          final shake = widget.state == LucyMascotState.error
              ? math.sin(_motion.value * math.pi * 8) * 0.035
              : 0.0;
          final successJump = widget.state == LucyMascotState.success
              ? math.sin(_motion.value * math.pi) * 0.06
              : 0.0;

          return SizedBox(
            width: widget.size * 1.28,
            height: widget.size * 1.28,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: widget.size * 0.82,
                  height: widget.size * 0.16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: _glow.withValues(alpha: .22),
                        blurRadius: widget.state == LucyMascotState.working ? 34 : 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _lift + successJump * widget.size),
                  child: Transform.rotate(
                    angle: _tilt + shake,
                    child: Transform.scale(
                      scale: 1 + breathe + successJump,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/lucy/lucy.webp',
                            width: widget.size,
                            height: widget.size,
                            fit: BoxFit.contain,
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LucyInteractionPainter(
                                state: widget.state,
                                pulse: _breath.value,
                                motion: _motion.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LucyInteractionPainter extends CustomPainter {
  const _LucyInteractionPainter({
    required this.state,
    required this.pulse,
    required this.motion,
  });

  final LucyMascotState state;
  final double pulse;
  final double motion;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 210;
    final sy = size.height / 210;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final pupil = Paint()..color = const Color(0xFF32135F);
    final shine = Paint()..color = Colors.white;
    final eyelid = Paint()..color = const Color(0xFFD0B8F3);
    final accent = Paint()
      ..color = const Color(0xFFC77CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // The source mascot has fixed pupils. These overlays give Lucy directional
    // eye movement without changing the original character art.
    var eyeDx = 0.0;
    var eyeDy = 0.0;
    switch (state) {
      case LucyMascotState.listening:
        eyeDx = 2.8;
      case LucyMascotState.thinking:
        eyeDy = -3.5;
        eyeDx = -2;
      case LucyMascotState.working:
        eyeDx = -2.5;
      default:
        eyeDx = math.sin(pulse * math.pi * 2) * 1.2;
    }

    canvas.drawCircle(p(78 + eyeDx, 91 + eyeDy).translate(0, 0), 7.2 * sx, pupil);
    canvas.drawCircle(p(132 + eyeDx, 91 + eyeDy).translate(0, 0), 7.2 * sx, pupil);
    canvas.drawCircle(p(75.5 + eyeDx, 88.5 + eyeDy), 2.1 * sx, shine);
    canvas.drawCircle(p(129.5 + eyeDx, 88.5 + eyeDy), 2.1 * sx, shine);

    if (state == LucyMascotState.working) {
      // Focused eyes.
      canvas.drawLine(p(69, 82), p(86, 79), accent);
      canvas.drawLine(p(124, 79), p(141, 82), accent);
    }

    if (state == LucyMascotState.listening) {
      final r = 78 + math.sin(pulse * math.pi * 2) * 6;
      canvas.drawCircle(p(105, 98), r * sx, accent..strokeWidth = 1.5);
    }

    if (state == LucyMascotState.thinking) {
      canvas.drawCircle(p(165, 46), 10 * sx, accent);
      canvas.drawCircle(p(165, 46), 3 * sx, accent..style = PaintingStyle.fill);
    }

    if (state == LucyMascotState.success) {
      for (final offset in [
        p(42, 68),
        p(168, 70),
        p(54, 126),
        p(158, 126),
      ]) {
        canvas.drawCircle(offset, 2.4 * sx, accent..style = PaintingStyle.fill);
      }
    }

    if (state == LucyMascotState.error) {
      // Soft eyelid overlays for a sad/concerned reaction.
      canvas.drawOval(
        Rect.fromCenter(center: p(78, 91), width: 30 * sx, height: 13 * sy),
        eyelid,
      );
      canvas.drawOval(
        Rect.fromCenter(center: p(132, 91), width: 30 * sx, height: 13 * sy),
        eyelid,
      );
    }

    // Hand-area gesture accents: wave/listen/thinking/success feedback follows
    // the mascot's fixed arms instead of introducing a mismatched second model.
    if (state == LucyMascotState.listening) {
      canvas.drawArc(
        Rect.fromCircle(center: p(41, 126), radius: 13 * sx),
        -1.4,
        1.2,
        false,
        accent,
      );
      canvas.drawArc(
        Rect.fromCircle(center: p(169, 126), radius: 13 * sx),
        1.0,
        1.2,
        false,
        accent,
      );
    }

    if (state == LucyMascotState.success) {
      final heart = Paint()
        ..color = const Color(0xFFFF78D4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p(47, 123), 4 * sx, heart);
      canvas.drawCircle(p(163, 123), 4 * sx, heart);
    }
  }

  @override
  bool shouldRepaint(covariant _LucyInteractionPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.pulse != pulse ||
      oldDelegate.motion != motion;
}
