import 'dart:math';
import 'package:flutter/material.dart';
import 'package:offramp/config/theme.dart';

// ═════════════════════════════════════════════════════════════════════════════
// MASCOT WIDGET - Animated moon character with arms and legs
// States: wave, point, write, jump, sleep
// ═════════════════════════════════════════════════════════════════════════════

enum MascotState {
  idle,
  wave,
  point,
  write,
  jump,
  sleep,
  celebrate,
  think,
  stop,
  focus,
}

class MascotWidget extends StatefulWidget {
  final MascotState state;
  final double size;
  final VoidCallback? onAnimationComplete;

  const MascotWidget({
    super.key,
    this.state = MascotState.idle,
    this.size = 120,
    this.onAnimationComplete,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _blinkController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _armAnimation;
  late Animation<double> _eyeAnimation;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _startAnimation();
  }

  void _setupControllers() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Random blinking
    Future.delayed(const Duration(seconds: 2), _blink);
  }

  void _setupAnimations() {
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _armAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _eyeAnimation = Tween<double>(begin: 1, end: 0.1).animate(
      CurvedAnimation(
        parent: _blinkController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _blink() async {
    if (!mounted) return;
    await _blinkController.forward();
    await _blinkController.reverse();
    Future.delayed(
      Duration(seconds: 3 + DateTime.now().millisecond % 4),
      _blink,
    );
  }

  void _startAnimation() {
    switch (widget.state) {
      case MascotState.idle:
        _controller.repeat(reverse: true);
        break;
      case MascotState.wave:
        _controller.duration = const Duration(milliseconds: 1500);
        _controller.repeat(reverse: true);
        break;
      case MascotState.point:
        _controller.duration = const Duration(milliseconds: 1000);
        _controller.repeat(reverse: true);
        break;
      case MascotState.write:
        _controller.duration = const Duration(milliseconds: 2000);
        _controller.repeat(reverse: true);
        break;
      case MascotState.jump:
        _controller.duration = const Duration(milliseconds: 800);
        _controller.repeat(reverse: true);
        break;
      case MascotState.sleep:
        _controller.duration = const Duration(milliseconds: 3000);
        _controller.repeat(reverse: true);
        break;
      case MascotState.celebrate:
        _controller.duration = const Duration(milliseconds: 600);
        _controller.repeat(reverse: true);
        break;
      case MascotState.think:
        _controller.duration = const Duration(milliseconds: 2500);
        _controller.repeat(reverse: true);
        break;
      case MascotState.stop:
        _controller.duration = const Duration(milliseconds: 2000);
        _controller.repeat(reverse: true);
        break;
      case MascotState.focus:
        _controller.duration = const Duration(milliseconds: 4000);
        _controller.repeat(reverse: true);
        break;
    }
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _controller.stop();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _blinkController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: MascotPainter(
            state: widget.state,
            bounceValue: _bounceAnimation.value,
            armValue: _armAnimation.value,
            eyeOpenValue: _eyeAnimation.value,
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MASCOT PAINTER - Custom painter for the moon character
// ═════════════════════════════════════════════════════════════════════════════

class MascotPainter extends CustomPainter {
  final MascotState state;
  final double bounceValue;
  final double armValue;
  final double eyeOpenValue;

  MascotPainter({
    required this.state,
    required this.bounceValue,
    required this.armValue,
    required this.eyeOpenValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.7;

    // Body bounce offset
    final bounceOffset = state == MascotState.jump
        ? -bounceValue * 3
        : state == MascotState.sleep
            ? bounceValue * 0.5
            : -bounceValue;

    final bodyY = baseY + bounceOffset;

    // Draw shadow
    _drawShadow(canvas, centerX, baseY + 10, size.width * 0.3);

    // Draw legs
    _drawLegs(canvas, centerX, bodyY, size);

    // Draw body (moon shape)
    _drawBody(canvas, centerX, bodyY, size);

    // Draw arms based on state
    _drawArms(canvas, centerX, bodyY, size);

    // Draw face
    _drawFace(canvas, centerX, bodyY, size);

    // Draw sleep cap if sleeping
    if (state == MascotState.sleep) {
      _drawSleepCap(canvas, centerX, bodyY, size);
    }

    // Draw notebook if writing
    if (state == MascotState.write) {
      _drawNotebook(canvas, centerX, bodyY, size);
    }

    // Draw stop sign if stopping
    if (state == MascotState.stop) {
      _drawStopSign(canvas, centerX, bodyY, size);
    }
  }

  void _drawShadow(Canvas canvas, double x, double y, double width) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: width, height: width * 0.3),
      paint,
    );
  }

  void _drawBody(Canvas canvas, double x, double y, Size size) {
    final bodyRadius = size.width * 0.35;

    // Glow effect
    final glowPaint = Paint()
      ..color = AppColors.creamWhite.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(Offset(x, y - bodyRadius * 0.5), bodyRadius * 1.2, glowPaint);

    // Main body
    final bodyPaint = Paint()
      ..color = AppColors.creamWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y - bodyRadius * 0.5), bodyRadius, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.softSage.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(x, y - bodyRadius * 0.5), bodyRadius, borderPaint);
  }

  void _drawLegs(Canvas canvas, double x, double y, Size size) {
    final legPaint = Paint()
      ..color = AppColors.creamWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final legLength = size.height * 0.15;
    final legSpread = size.width * 0.15;

    // Left leg
    final leftLegPath = Path()
      ..moveTo(x - legSpread, y)
      ..lineTo(x - legSpread * 1.2, y + legLength);

    // Right leg
    final rightLegPath = Path()
      ..moveTo(x + legSpread, y)
      ..lineTo(x + legSpread * 1.2, y + legLength);

    // Animate legs when jumping
    if (state == MascotState.jump || state == MascotState.celebrate) {
      final kick = armValue * 20;
      canvas.drawLine(
        Offset(x - legSpread, y),
        Offset(x - legSpread * 1.5, y + legLength - kick),
        legPaint,
      );
      canvas.drawLine(
        Offset(x + legSpread, y),
        Offset(x + legSpread * 1.5, y + legLength + kick),
        legPaint,
      );
    } else {
      canvas.drawPath(leftLegPath, legPaint);
      canvas.drawPath(rightLegPath, legPaint);
    }

    // Feet
    final footPaint = Paint()
      ..color = AppColors.softSage
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(x - legSpread * 1.2, y + legLength + 4),
      6,
      footPaint,
    );
    canvas.drawCircle(
      Offset(x + legSpread * 1.2, y + legLength + 4),
      6,
      footPaint,
    );
  }

  void _drawArms(Canvas canvas, double x, double y, Size size) {
    final armPaint = Paint()
      ..color = AppColors.creamWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final armLength = size.height * 0.2;
    final shoulderY = y - size.height * 0.25;
    final shoulderSpread = size.width * 0.25;

    // Calculate arm positions based on state
    double leftAngle = 0.5;
    double rightAngle = -0.5;

    switch (state) {
      case MascotState.wave:
        leftAngle = 0.3;
        rightAngle = -1.5 + armValue * 2; // Waving
        break;
      case MascotState.point:
        leftAngle = 0.5;
        rightAngle = -2.0; // Pointing up/right
        break;
      case MascotState.write:
        leftAngle = 0.8;
        rightAngle = -0.5 + armValue * 0.3; // Writing motion
        break;
      case MascotState.jump:
      case MascotState.celebrate:
        leftAngle = 2.5; // Arms up!
        rightAngle = -2.5;
        break;
      case MascotState.sleep:
        leftAngle = 0.2;
        rightAngle = -0.2; // Relaxed at sides
        break;
      case MascotState.stop:
        leftAngle = 0.3;
        rightAngle = -1.0; // Holding sign
        break;
      case MascotState.think:
        leftAngle = 2.0; // Hand on chin
        rightAngle = -0.5;
        break;
      case MascotState.focus:
        leftAngle = 0.5;
        rightAngle = -0.5;
        break;
      case MascotState.idle:
        leftAngle = 0.5 + armValue * 0.2;
        rightAngle = -0.5 - armValue * 0.2;
        break;
    }

    // Draw left arm
    final leftEndX = x - shoulderSpread + armLength * 0.8 * cos(leftAngle);
    final leftEndY = shoulderY + armLength * sin(leftAngle);
    canvas.drawLine(
      Offset(x - shoulderSpread, shoulderY),
      Offset(leftEndX, leftEndY),
      armPaint,
    );

    // Draw right arm
    final rightEndX = x + shoulderSpread + armLength * 0.8 * cos(rightAngle);
    final rightEndY = shoulderY + armLength * sin(rightAngle);
    canvas.drawLine(
      Offset(x + shoulderSpread, shoulderY),
      Offset(rightEndX, rightEndY),
      armPaint,
    );

    // Hands
    final handPaint = Paint()
      ..color = AppColors.softSage
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(leftEndX, leftEndY), 7, handPaint);
    canvas.drawCircle(Offset(rightEndX, rightEndY), 7, handPaint);
  }

  void _drawFace(Canvas canvas, double x, double y, Size size) {
    final faceY = y - size.height * 0.35;
    final eyeSpacing = size.width * 0.12;
    final eyeY = faceY - size.height * 0.05;

    // Eye positions
    final leftEyeX = x - eyeSpacing;
    final rightEyeX = x + eyeSpacing;

    // Eye colors based on state
    Color eyeColor = AppColors.charcoal;
    if (state == MascotState.sleep) {
      eyeColor = AppColors.mutedGray;
    }

    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    // Draw eyes based on state
    if (state == MascotState.sleep) {
      // Closed eyes (arcs)
      final eyePath = Path()
        ..moveTo(leftEyeX - 8, eyeY)
        ..arcToPoint(Offset(leftEyeX + 8, eyeY), radius: const Radius.circular(8));
      canvas.drawPath(
        eyePath,
        Paint()
          ..color = eyeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final rightEyePath = Path()
        ..moveTo(rightEyeX - 8, eyeY)
        ..arcToPoint(Offset(rightEyeX + 8, eyeY), radius: const Radius.circular(8));
      canvas.drawPath(
        rightEyePath,
        Paint()
          ..color = eyeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      // Open eyes with blinking
      final eyeHeight = 12 * eyeOpenValue;
      if (eyeHeight > 1) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(leftEyeX, eyeY), width: 12, height: eyeHeight),
          eyePaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(rightEyeX, eyeY), width: 12, height: eyeHeight),
          eyePaint,
        );
      }
    }

    // Draw mouth based on state
    final mouthY = faceY + size.height * 0.08;
    final mouthPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    switch (state) {
      case MascotState.wave:
      case MascotState.celebrate:
        // Happy smile
        final smilePath = Path()
          ..moveTo(x - 10, mouthY)
          ..quadraticBezierTo(x, mouthY + 10, x + 10, mouthY);
        canvas.drawPath(smilePath, mouthPaint);
        break;
      case MascotState.sleep:
        // Small peaceful smile
        canvas.drawLine(Offset(x - 6, mouthY), Offset(x + 6, mouthY), mouthPaint);
        break;
      case MascotState.think:
        // Thoughtful small smile
        final thinkPath = Path()
          ..moveTo(x - 6, mouthY)
          ..quadraticBezierTo(x, mouthY + 4, x + 6, mouthY);
        canvas.drawPath(thinkPath, mouthPaint);
        break;
      case MascotState.focus:
        // Determined line
        canvas.drawLine(Offset(x - 8, mouthY + 2), Offset(x + 8, mouthY + 2), mouthPaint);
        break;
      default:
        // Neutral slight smile
        final neutralPath = Path()
          ..moveTo(x - 8, mouthY)
          ..quadraticBezierTo(x, mouthY + 5, x + 8, mouthY);
        canvas.drawPath(neutralPath, mouthPaint);
    }

    // Cheeks for cute factor
    final cheekPaint = Paint()
      ..color = AppColors.warmCoral.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x - eyeSpacing * 1.5, mouthY - 2), 6, cheekPaint);
    canvas.drawCircle(Offset(x + eyeSpacing * 1.5, mouthY - 2), 6, cheekPaint);
  }

  void _drawSleepCap(Canvas canvas, double x, double y, Size size) {
    final capPaint = Paint()
      ..color = AppColors.mutedLavender
      ..style = PaintingStyle.fill;

    final capY = y - size.height * 0.55;
    final capPath = Path()
      ..moveTo(x - 15, capY)
      ..lineTo(x + 15, capY)
      ..lineTo(x, capY - 20)
      ..close();

    canvas.drawPath(capPath, capPaint);

    // Pom pom
    canvas.drawCircle(Offset(x, capY - 22), 6, capPaint);
  }

  void _drawNotebook(Canvas canvas, double x, double y, Size size) {
    final bookPaint = Paint()
      ..color = AppColors.creamWhite
      ..style = PaintingStyle.fill;

    final bookBorder = Paint()
      ..color = AppColors.softSage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bookRect = Rect.fromCenter(
      center: Offset(x + size.width * 0.25, y - size.height * 0.1),
      width: 24,
      height: 30,
    );

    canvas.drawRect(bookRect, bookPaint);
    canvas.drawRect(bookRect, bookBorder);

    // Lines
    final linePaint = Paint()
      ..color = AppColors.mutedGray
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(bookRect.left + 4, bookRect.top + 8 + i * 6),
        Offset(bookRect.right - 4, bookRect.top + 8 + i * 6),
        linePaint,
      );
    }
  }

  void _drawStopSign(Canvas canvas, double x, double y, Size size) {
    final signPaint = Paint()
      ..color = AppColors.warmCoral
      ..style = PaintingStyle.fill;

    final signCenter = Offset(x + size.width * 0.25, y - size.height * 0.3);
    final signRadius = 16;

    // Octagon shape
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * 3.14159 / 180;
      final px = signCenter.dx + signRadius * cos(angle);
      final py = signCenter.dy + signRadius * sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    canvas.drawPath(path, signPaint);

    // Stop text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'STOP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      signCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
