import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// The Ramp mascot — a friendly crescent moon character.
/// Uses CustomPainter + multiple AnimationControllers for 5+ live animation states.
enum RampState {
  idle,       // gentle float up/down, waves hello
  listening,  // cups ear, listening pose
  clapping,   // claps stub arms excitedly
  stopSign,   // holds up stop-sign hand, calm expression
  breathing,  // body expands/contracts with breathing ring
  celebrating,// jumps and throws confetti
  yawning,    // yawns, stretches, looks sleepy
  sleeping,   // wears sleep cap, eyes closed, ZZZ
  waking,     // wakes up, stretches arms wide, sparkle eyes
  spinning,   // happy spin for all tasks complete
}

class RampWidget extends StatefulWidget {
  final RampState state;
  final double size;

  const RampWidget({
    super.key,
    this.state = RampState.idle,
    this.size = 100,
  });

  @override
  State<RampWidget> createState() => _RampWidgetState();
}

class _RampWidgetState extends State<RampWidget> with TickerProviderStateMixin {
  // Primary float animation (idle bob)
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Arm animation (wave, clap, stop-sign, etc.)
  late AnimationController _armController;
  late Animation<double> _armAnimation;

  // Body scale animation (breathing, celebration bounce)
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Rotation animation (spinning)
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  // Eye animation (blink, open/close)
  late AnimationController _eyeController;
  late Animation<double> _eyeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _applyState(widget.state);
  }

  void _initAnimations() {
    // Float: gentle bob 2s cycle
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Arms: 600ms for gestures
    _armController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _armAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _armController, curve: Curves.elasticOut),
    );

    // Scale: breathing 4s or bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Rotation: full spin 800ms
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Eyes: blink cycle 3s
    _eyeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _eyeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 85),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 5),
    ]).animate(_eyeController);
  }

  void _applyState(RampState state) {
    // Reset all
    _floatController.stop();
    _armController.stop();
    _scaleController.stop();
    _rotationController.stop();
    _eyeController.stop();

    switch (state) {
      case RampState.idle:
        _floatController.repeat(reverse: true);
        _eyeController.repeat();
        _armController.repeat(reverse: true);
        break;

      case RampState.listening:
        _floatController.repeat(reverse: true);
        _eyeController.repeat();
        _armController.forward();
        break;

      case RampState.clapping:
        _floatController.repeat(reverse: true);
        _eyeController.repeat();
        _armController.repeat(reverse: true);
        break;

      case RampState.stopSign:
        _floatController.value = 0;
        _eyeController.repeat();
        _armController.forward();
        break;

      case RampState.breathing:
        _scaleController.repeat(reverse: true);
        _eyeController.value = 0.5; // half-closed
        break;

      case RampState.celebrating:
        _floatController.repeat(reverse: true);
        _scaleController.duration = const Duration(milliseconds: 400);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        );
        _scaleController.repeat(reverse: true);
        _armController.repeat(reverse: true);
        _eyeController.repeat();
        break;

      case RampState.yawning:
        _floatController.repeat(reverse: true);
        _armController.forward();
        _eyeController.value = 0.3;
        break;

      case RampState.sleeping:
        _scaleController.duration = const Duration(milliseconds: 3000);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
        );
        _scaleController.repeat(reverse: true);
        _eyeController.value = 0.0; // eyes closed
        break;

      case RampState.waking:
        _floatController.repeat(reverse: true);
        _armController.forward();
        _eyeController.forward();
        _scaleController.duration = const Duration(milliseconds: 600);
        _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        );
        _scaleController.forward();
        break;

      case RampState.spinning:
        _rotationController.repeat();
        _eyeController.repeat();
        break;
    }
  }

  @override
  void didUpdateWidget(RampWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _applyState(widget.state);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _armController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _armController,
        _scaleController,
        _rotationController,
        _eyeController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RampPainter(
                  state: widget.state,
                  armProgress: _armAnimation.value,
                  eyeOpenness: _eyeAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RampPainter extends CustomPainter {
  final RampState state;
  final double armProgress;
  final double eyeOpenness;

  _RampPainter({
    required this.state,
    required this.armProgress,
    required this.eyeOpenness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Body: crescent moon
    _drawBody(canvas, center, radius, size);
    // Eyes
    _drawEyes(canvas, center, radius);
    // Blush
    _drawBlush(canvas, center, radius);
    // Arms
    _drawArms(canvas, center, radius, size);
    // Sleep cap if sleeping
    if (state == RampState.sleeping) {
      _drawSleepCap(canvas, center, radius);
      _drawZzz(canvas, center, radius);
    }
    // Sparkles when waking/celebrating
    if (state == RampState.waking || state == RampState.celebrating) {
      _drawSparkles(canvas, center, radius);
    }
  }

  void _drawBody(Canvas canvas, Offset center, double radius, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFF3D4)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFFCE8B2).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Main moon circle
    canvas.drawCircle(center, radius, bodyPaint);

    // Crescent cutout - offset circle to create crescent shape
    final cutoutPaint = Paint()
      ..color = const Color(0xFFF7F9F7)
      ..style = PaintingStyle.fill;

    // Draw the cutout for crescent effect
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.3),
      radius * 0.7,
      cutoutPaint,
    );

    // Soft glow around body
    final glowPaint = Paint()
      ..color = const Color(0xFFFFF3D4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Re-draw body on top of glow
    canvas.drawCircle(center, radius, bodyPaint);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.3),
      radius * 0.7,
      cutoutPaint,
    );
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyeColor = AppColors.textPrimary;
    final leftEyeCenter = Offset(center.dx - radius * 0.25, center.dy - radius * 0.1);
    final rightEyeCenter = Offset(center.dx + radius * 0.05, center.dy - radius * 0.1);
    final eyeRadius = radius * 0.06;

    if (state == RampState.sleeping || eyeOpenness < 0.1) {
      // Closed eyes - small arcs
      final closedPaint = Paint()
        ..color = eyeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(center: leftEyeCenter, width: eyeRadius * 3, height: eyeRadius * 1.5),
        0, pi, false, closedPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 3, height: eyeRadius * 1.5),
        0, pi, false, closedPaint,
      );
    } else {
      // Open eyes
      final eyePaint = Paint()..color = eyeColor..style = PaintingStyle.fill;
      final eyeH = eyeRadius * eyeOpenness;

      canvas.drawOval(
        Rect.fromCenter(center: leftEyeCenter, width: eyeRadius * 2, height: eyeH * 2),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 2, height: eyeH * 2),
        eyePaint,
      );

      // Sparkle in eyes for waking state
      if (state == RampState.waking || state == RampState.celebrating) {
        final sparklePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(leftEyeCenter.dx + 1, leftEyeCenter.dy - 1),
          eyeRadius * 0.4,
          sparklePaint,
        );
        canvas.drawCircle(
          Offset(rightEyeCenter.dx + 1, rightEyeCenter.dy - 1),
          eyeRadius * 0.4,
          sparklePaint,
        );
      }
    }
  }

  void _drawBlush(Canvas canvas, Offset center, double radius) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB5A7).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.35, center.dy + radius * 0.15),
        width: radius * 0.2,
        height: radius * 0.12,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.15, center.dy + radius * 0.15),
        width: radius * 0.2,
        height: radius * 0.12,
      ),
      blushPaint,
    );
  }

  void _drawArms(Canvas canvas, Offset center, double radius, Size size) {
    final armPaint = Paint()
      ..color = const Color(0xFFFFF3D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final leftStart = Offset(center.dx - radius * 0.6, center.dy + radius * 0.2);
    final rightStart = Offset(center.dx + radius * 0.3, center.dy + radius * 0.2);

    switch (state) {
      case RampState.idle:
        // Wave animation
        final waveAngle = armProgress * 0.5;
        final leftEnd = Offset(
          leftStart.dx - radius * 0.3,
          leftStart.dy + radius * 0.2 - sin(waveAngle * pi) * radius * 0.3,
        );
        final rightEnd = Offset(
          rightStart.dx + radius * 0.3,
          rightStart.dy + radius * 0.2 - sin(waveAngle * pi) * radius * 0.3,
        );
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;

      case RampState.listening:
        // Left arm cups ear
        final leftEnd = Offset(center.dx - radius * 0.5, center.dy - radius * 0.3);
        final rightEnd = Offset(rightStart.dx + radius * 0.25, rightStart.dy + radius * 0.15);
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;

      case RampState.clapping:
        // Arms come together
        final spread = (1 - armProgress) * radius * 0.4;
        final leftEnd = Offset(center.dx - spread, center.dy + radius * 0.35);
        final rightEnd = Offset(center.dx + spread, center.dy + radius * 0.35);
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;

      case RampState.stopSign:
        // Right arm up with stop gesture
        final leftEnd = Offset(leftStart.dx - radius * 0.2, leftStart.dy + radius * 0.2);
        final rightEnd = Offset(rightStart.dx + radius * 0.35, rightStart.dy - radius * 0.5);
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        // Small circle for "hand"
        final handPaint = Paint()
          ..color = const Color(0xFFFFF3D4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(rightEnd, radius * 0.08, handPaint);
        break;

      case RampState.celebrating:
        // Arms up throwing confetti
        final leftEnd = Offset(leftStart.dx - radius * 0.25, leftStart.dy - radius * 0.5);
        final rightEnd = Offset(rightStart.dx + radius * 0.25, rightStart.dy - radius * 0.5);
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;

      case RampState.yawning:
      case RampState.waking:
        // Arms stretched wide
        final stretch = armProgress;
        final leftEnd = Offset(
          leftStart.dx - radius * 0.4 * stretch,
          leftStart.dy - radius * 0.3 * stretch,
        );
        final rightEnd = Offset(
          rightStart.dx + radius * 0.4 * stretch,
          rightStart.dy - radius * 0.3 * stretch,
        );
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;

      default:
        // Default small arms down
        final leftEnd = Offset(leftStart.dx - radius * 0.2, leftStart.dy + radius * 0.15);
        final rightEnd = Offset(rightStart.dx + radius * 0.2, rightStart.dy + radius * 0.15);
        canvas.drawLine(leftStart, leftEnd, armPaint);
        canvas.drawLine(rightStart, rightEnd, armPaint);
        break;
    }
  }

  void _drawSleepCap(Canvas canvas, Offset center, double radius) {
    final capPaint = Paint()
      ..color = AppColors.lavender
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6);
    path.quadraticBezierTo(
      center.dx, center.dy - radius * 1.4,
      center.dx + radius * 0.5, center.dy - radius * 0.7,
    );
    path.lineTo(center.dx - radius * 0.5, center.dy - radius * 0.6);
    canvas.drawPath(path, capPaint);

    // Pompom
    canvas.drawCircle(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.7),
      radius * 0.1,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
  }

  void _drawZzz(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'z z z',
        style: TextStyle(
          fontSize: radius * 0.25,
          color: AppColors.lavender.withValues(alpha: 0.7),
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.9),
    );
  }

  void _drawSparkles(Canvas canvas, Offset center, double radius) {
    final sparklePaint = Paint()
      ..color = AppColors.accentYellow
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(center.dx - radius * 0.8, center.dy - radius * 0.6),
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.7),
      Offset(center.dx + radius * 0.8, center.dy + radius * 0.4),
    ];

    for (final pos in positions) {
      _drawStar(canvas, pos, radius * 0.06, sparklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RampPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.armProgress != armProgress ||
        oldDelegate.eyeOpenness != eyeOpenness;
  }
}
