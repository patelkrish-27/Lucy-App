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

/// Face-only Lucy. The character is rendered as pixel-art from independent
/// layers so the eyes, expression, glow and head accessory can animate.
class LucyMascot extends StatefulWidget {
  const LucyMascot({
    super.key,
    this.size = 220,
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
  late final AnimationController _loop;
  late final AnimationController _reaction;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _reaction = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
    _loop.dispose();
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
        animation: Listenable.merge([_loop, _reaction]),
        builder: (context, _) {
          return SizedBox(
            width: widget.size * 1.18,
            height: widget.size * 1.18,
            child: CustomPaint(
              painter: _LucyFacePainter(
                state: widget.state,
                phase: _loop.value,
                reaction: Curves.easeOutBack.transform(_reaction.value),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _LucyAccessory { bow, star, halo, flower, catEars, heart }

class _LucyFacePainter extends CustomPainter {
  const _LucyFacePainter({
    required this.state,
    required this.phase,
    required this.reaction,
  });

  final LucyMascotState state;
  final double phase;
  final double reaction;

  // The source TUI has a deliberately chunky/pixelated character. Drawing on
  // this small logical grid and scaling it up preserves that visual language.
  static const double grid = 128;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / grid;
    canvas.scale(scale, scale);

    final time = phase * math.pi * 2;
    final pulse = (math.sin(time) + 1) / 2;
    final blinkCycle = (phase * 3.0) % 1.0;
    final blinking = blinkCycle > .91 && blinkCycle < .965;
    final accessory = _LucyAccessory.values[
        ((phase * 6).floor()) % _LucyAccessory.values.length];

    final glow = Paint()
      ..color = const Color(0x554F2A96)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 28, 108, 84),
        const Radius.circular(38),
      ),
      glow,
    );

    // Tiny idle float keeps the face alive without adding a body.
    final y = math.sin(time) * .9;

    canvas.save();
    canvas.translate(0, y);

    final fur = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE0D0FF),
          Color(0xFFB58AF2),
          Color(0xFF7650C5),
        ],
      ).createShader(const Rect.fromLTWH(15, 17, 98, 96));

    // Pixel-like face silhouette.
    final face = Path()
      ..moveTo(32, 20)
      ..lineTo(96, 20)
      ..lineTo(106, 28)
      ..lineTo(113, 42)
      ..lineTo(116, 65)
      ..lineTo(111, 87)
      ..lineTo(101, 101)
      ..lineTo(86, 109)
      ..lineTo(42, 109)
      ..lineTo(27, 101)
      ..lineTo(17, 87)
      ..lineTo(12, 65)
      ..lineTo(15, 42)
      ..lineTo(22, 28)
      ..close();
    canvas.drawPath(face, fur);

    // Chunky shadow pixels around the lower face.
    final shadow = Paint()..color = const Color(0x26704AAE);
    for (final r in <Rect>[
      const Rect.fromLTWH(23, 84, 8, 10),
      const Rect.fromLTWH(31, 97, 9, 7),
      const Rect.fromLTWH(91, 94, 10, 8),
      const Rect.fromLTWH(101, 78, 7, 10),
    ]) {
      canvas.drawRect(r, shadow);
    }

    // Blush blocks.
    final blush = Paint()..color = const Color(0x66FF8FBF);
    canvas.drawRect(const Rect.fromLTWH(25, 76, 13, 6), blush);
    canvas.drawRect(const Rect.fromLTWH(90, 76, 13, 6), blush);

    // Eye state.
    var lookX = 0.0;
    var lookY = 0.0;
    if (state == LucyMascotState.listening) lookX = 2.2;
    if (state == LucyMascotState.thinking) {
      lookX = -2.7;
      lookY = -3.0;
    }
    if (state == LucyMascotState.working) lookX = 1.8;
    if (state == LucyMascotState.success) lookY = -1.5;

    final eyeY = 61.0;
    final eyeColor = const Color(0xFF171026);
    final iris = const Color(0xFF4B238B);
    final sparkle = const Color(0xFFFFFFFF);

    void eye(double cx) {
      if (blinking) {
        canvas.drawRect(
          Rect.fromLTWH(cx - 10, eyeY - 1, 20, 4),
          Paint()..color = eyeColor,
        );
        return;
      }

      // Large blocky white eye.
      canvas.drawRect(
        Rect.fromLTWH(cx - 12, eyeY - 15, 24, 31),
        Paint()..color = const Color(0xFFF7F3FF),
      );
      canvas.drawRect(
        Rect.fromLTWH(cx - 15, eyeY - 9, 30, 19),
        Paint()..color = const Color(0xFFF7F3FF),
      );

      // Dark pixel iris.
      final ix = cx + lookX;
      final iy = eyeY + lookY;
      canvas.drawRect(
        Rect.fromLTWH(ix - 9, iy - 10, 18, 22),
        Paint()..color = iris,
      );
      canvas.drawRect(
        Rect.fromLTWH(ix - 12, iy - 6, 24, 13),
        Paint()..color = iris,
      );
      canvas.drawRect(
        Rect.fromLTWH(ix - 6, iy - 7, 13, 17),
        Paint()..color = eyeColor,
      );

      // Animated twinkle blocks.
      final twinkle = (math.sin(time * 2.5 + cx) + 1) / 2;
      if (twinkle > .22) {
        final twinkleSize = twinkle > .78 ? 5.0 : 3.0;
        canvas.drawRect(
          Rect.fromLTWH(ix - 6, iy - 8, twinkleSize, twinkleSize),
          Paint()..color = sparkle,
        );
      }
      if (twinkle > .62) {
        canvas.drawRect(
          Rect.fromLTWH(ix + 5, iy + 4, 3, 3),
          Paint()..color = const Color(0xFFBDA2FF),
        );
      }
    }

    eye(50);
    eye(78);

    // Eyebrows/expression blocks.
    final expression = Paint()..color = const Color(0xFF59308F);
    if (state == LucyMascotState.thinking) {
      canvas.drawRect(const Rect.fromLTWH(38, 43, 17, 3), expression);
      canvas.drawRect(const Rect.fromLTWH(73, 43, 17, 3), expression);
    } else if (state == LucyMascotState.error) {
      canvas.drawRect(const Rect.fromLTWH(38, 45, 14, 3), expression);
      canvas.drawRect(const Rect.fromLTWH(76, 45, 14, 3), expression);
    }

    // Mouth is deliberately tiny and expressive.
    final mouth = Paint()
      ..color = const Color(0xFF3D2169)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    if (state == LucyMascotState.success) {
      canvas.drawArc(
        const Rect.fromLTWH(56, 73, 16, 11),
        0,
        math.pi,
        false,
        mouth,
      );
    } else if (state == LucyMascotState.error) {
      canvas.drawArc(
        const Rect.fromLTWH(56, 78, 16, 9),
        math.pi,
        math.pi,
        false,
        mouth,
      );
    } else if (state == LucyMascotState.thinking) {
      canvas.drawRect(const Rect.fromLTWH(62, 77, 5, 6), Paint()..color = mouth.color);
    } else {
      canvas.drawArc(
        const Rect.fromLTWH(57, 74, 14, 9),
        0,
        math.pi,
        false,
        mouth,
      );
    }

    _paintAccessory(canvas, accessory, pulse);

    // State sparkles float around the face.
    final sparklePaint = Paint()..color = const Color(0xFFCB9BFF);
    final sparkleAlpha = .35 + pulse * .65;
    sparklePaint.color = const Color(0xFFCB9BFF).withValues(alpha: sparkleAlpha);
    _pixelSparkle(canvas, 17, 38, 3, sparklePaint);
    _pixelSparkle(canvas, 109, 49, 2.5, sparklePaint);
    if (state == LucyMascotState.listening ||
        state == LucyMascotState.success) {
      _pixelSparkle(canvas, 12, 71, 2, sparklePaint);
      _pixelSparkle(canvas, 116, 76, 2, sparklePaint);
    }

    canvas.restore();
  }

  void _paintAccessory(Canvas canvas, _LucyAccessory accessory, double pulse) {
    final purple = Paint()..color = const Color(0xFF9E69E8);
    final light = Paint()..color = const Color(0xFFC79AFF);
    final pink = Paint()..color = const Color(0xFFFF7DC7);

    switch (accessory) {
      case _LucyAccessory.bow:
        canvas.drawRect(const Rect.fromLTWH(82, 17, 17, 16), purple);
        canvas.drawRect(const Rect.fromLTWH(98, 12, 16, 21), purple);
        canvas.drawRect(const Rect.fromLTWH(92, 20, 10, 10), light);
        break;
      case _LucyAccessory.star:
        _pixelStar(canvas, 99, 20, light);
        break;
      case _LucyAccessory.halo:
        final halo = Paint()
          ..color = light
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawOval(const Rect.fromLTWH(79, 8, 35, 15), halo);
        break;
      case _LucyAccessory.flower:
        for (final o in [
          const Offset(96, 16),
          const Offset(103, 21),
          const Offset(89, 21),
          const Offset(96, 26),
        ]) {
          canvas.drawRect(Rect.fromCenter(center: o, width: 9, height: 7), pink);
        }
        canvas.drawRect(const Rect.fromLTWH(93, 18, 7, 7), light);
        break;
      case _LucyAccessory.catEars:
        final left = Path()
          ..moveTo(80, 27)
          ..lineTo(84, 7)
          ..lineTo(94, 25)
          ..close();
        final right = Path()
          ..moveTo(96, 25)
          ..lineTo(108, 7)
          ..lineTo(111, 29)
          ..close();
        canvas.drawPath(left, purple);
        canvas.drawPath(right, purple);
        break;
      case _LucyAccessory.heart:
        canvas.drawRect(const Rect.fromLTWH(88, 14, 8, 8), pink);
        canvas.drawRect(const Rect.fromLTWH(96, 14, 8, 8), pink);
        canvas.drawRect(const Rect.fromLTWH(92, 19, 9, 8), pink);
        break;
    }

    if (state == LucyMascotState.working) {
      final dot = Paint()..color = light.withValues(alpha: .45 + pulse * .55);
      canvas.drawRect(const Rect.fromLTWH(17, 94, 4, 4), dot);
      canvas.drawRect(const Rect.fromLTWH(23, 94, 4, 4), dot);
      canvas.drawRect(const Rect.fromLTWH(29, 94, 4, 4), dot);
    }
  }

  void _pixelSparkle(
    Canvas canvas,
    double x,
    double y,
    double r,
    Paint paint,
  ) {
    canvas.drawRect(Rect.fromLTWH(x - r / 2, y - r * 1.7, r, r * 3.4), paint);
    canvas.drawRect(Rect.fromLTWH(x - r * 1.7, y - r / 2, r * 3.4, r), paint);
  }

  void _pixelStar(Canvas canvas, double x, double y, Paint paint) {
    _pixelSparkle(canvas, x, y, 4, paint);
    canvas.drawRect(Rect.fromLTWH(x - 3, y - 3, 6, 6), paint);
  }

  @override
  bool shouldRepaint(covariant _LucyFacePainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.phase != phase ||
      oldDelegate.reaction != reaction;
}
