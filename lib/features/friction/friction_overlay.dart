import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../mascot/ramp_widget.dart';

class FrictionOverlay extends StatefulWidget {
  final List<TaskItem> tasks;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const FrictionOverlay({
    super.key,
    required this.tasks,
    required this.onClose,
    required this.onOpen,
  });

  @override
  State<FrictionOverlay> createState() => _FrictionOverlayState();
}

class _FrictionOverlayState extends State<FrictionOverlay>
    with TickerProviderStateMixin {
  int _count = 30;
  bool _done = false;

  // Breathing animation
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_count <= 1) {
          _count = 0;
          _done = true;
          return;
        }
        _count--;
      });
      return _count > 0;
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circumference = 2 * pi * 42;
    final offset = circumference * (_count / 30);

    return Container(
      color: AppColors.overlay,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          decoration: AppDecorations.card,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏸️', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  'Pause for 30 seconds',
                  style: AppText.displaySm.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                // Ramp mascot
                RampWidget(
                  state: _done ? RampState.idle : RampState.breathing,
                  size: 60,
                ),
                const SizedBox(height: 12),
                // Breathing ring with countdown
                AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathAnimation.value,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(100, 100),
                              painter: _CountdownRingPainter(
                                progress: 1 - (_count / 30),
                                trackColor: AppColors.divider,
                                fillColor: AppColors.sage,
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.sage.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppColors.sage.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _done ? 'Done' : '$_count',
                                  style: _done
                                      ? TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.sage,
                                        )
                                      : AppText.displaySm.copyWith(fontSize: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                // 4 Things
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('YOUR 4 THINGS:', style: AppText.cardTitle),
                ),
                const SizedBox(height: 8),
                ...widget.tasks.map((t) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          t.done ? '✓' : '←',
                          style: TextStyle(
                            color: t.done ? AppColors.sage : AppColors.coral,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${t.icon} ${t.text}',
                            style: AppText.body.copyWith(
                              fontSize: 13,
                              color: t.done
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              decoration: t.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (!t.done)
                          Text(
                            'Not done',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.coral,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Text(
                  '"The urge will pass. You\'re in control."',
                  style: AppText.caption.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtons.sage,
                    onPressed: widget.onClose,
                    child: const Text("Close — I'll Work ✓"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: AppButtons.ghost,
                    onPressed: widget.onOpen,
                    child: const Text('Open Anyway'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _CountdownRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = trackColor
        ..strokeWidth = 6,
    );

    // Fill
    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = fillColor
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
