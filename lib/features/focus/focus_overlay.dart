import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../mascot/ramp_widget.dart';

class FocusOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onClose;

  const FocusOverlay({
    super.key,
    required this.onComplete,
    required this.onClose,
  });

  @override
  State<FocusOverlay> createState() => _FocusOverlayState();
}

class _FocusOverlayState extends State<FocusOverlay>
    with SingleTickerProviderStateMixin {
  static const int _total = 50 * 60; // 50 minutes in seconds
  int _elapsed = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50)); // fast for demo
      if (!mounted) return false;
      if (!_running) return true;
      setState(() {
        if (_elapsed >= _total) {
          _elapsed = _total;
          return;
        }
        _elapsed++;
      });
      return _elapsed < _total;
    });
  }

  String _fmtTime(int s) {
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _total - _elapsed;
    final pct = _elapsed / _total;
    final circumference = 2 * pi * 80;
    final dashoffset = circumference - pct * circumference;

    return Container(
      color: const Color(0xF8F7F9F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                'Focus Mode Active',
                style: AppText.caption.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Lab Report', style: AppText.displaySm),
              const SizedBox(height: 28),
              // Timer ring
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _FocusRingPainter(
                        progress: pct,
                        trackColor: AppColors.divider,
                        fillColor: AppColors.sage,
                      ),
                    ),
                    Text(_fmtTime(remaining), style: AppText.timerDigits),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Reward waiting:', style: AppText.caption),
              const SizedBox(height: 6),
              Text('Hot shower + 1 episode 🎬', style: AppText.body),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: AppPills.sage,
                child: Text(
                  'Distracting apps blocked ✓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sage,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: AppButtons.ghostSmall,
                    onPressed: () {
                      setState(() => _running = !_running);
                    },
                    child: Text(_running ? 'Pause' : 'Resume'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: AppButtons.coralSmall,
                    onPressed: widget.onComplete,
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _FocusRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 80.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = trackColor
        ..strokeWidth = 8,
    );

    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = fillColor
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
