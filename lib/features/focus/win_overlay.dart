import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../mascot/ramp_widget.dart';

class WinOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const WinOverlay({super.key, required this.onClose});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<_ConfettiPiece> _confetti;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _confetti = List.generate(18, (i) {
      return _ConfettiPiece(
        x: rng.nextDouble() * 340 - 20,
        delay: rng.nextDouble() * 0.5,
        color: [AppColors.coral, AppColors.sage, AppColors.warning, AppColors.lavender][i % 4],
        size: 6 + rng.nextDouble() * 6,
      );
    });

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlay,
      child: Stack(
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return Stack(
                children: _confetti.map((c) {
                  final t = (_confettiController.value - c.delay).clamp(0.0, 1.0);
                  return Positioned(
                    left: c.x,
                    top: 60 + t * 400,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: t * 4 * pi,
                        child: Container(
                          width: c.size,
                          height: c.size,
                          decoration: BoxDecoration(
                            color: c.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const RampWidget(state: RampState.celebrating, size: 80),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: const Cubic(0.34, 1.56, 0.64, 1),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: const Text('🎉', style: TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Win Task Complete!',
                    style: AppText.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You just reclaimed 50 minutes\nfrom the algorithm.',
                    style: AppText.quote.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: AppDecorations.card,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR REWARD IS UNLOCKED', style: AppText.cardTitle),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('✓', style: TextStyle(color: AppColors.sage)),
                            const SizedBox(width: 8),
                            Text('Hot shower', style: AppText.body),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('✓', style: TextStyle(color: AppColors.sage)),
                            const SizedBox(width: 8),
                            Text('1 episode', style: AppText.body),
                            const SizedBox(width: 4),
                            Text(
                              '(guilt-free)',
                              style: AppText.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtons.coral,
                      onPressed: widget.onClose,
                      child: const Text('Claim Reward 🎁'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final Color color;
  final double size;

  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
  });
}
