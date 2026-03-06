import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  bool _placed = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rng = Random(42);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sleepBg1,
            AppColors.sleepBg2,
            AppColors.sleepBg3,
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Stars
          ...List.generate(8, (i) {
            return Positioned(
              left: (10 + i * 12) * MediaQuery.of(context).size.width / 100,
              top: 15.0 + i * 8 + rng.nextDouble() * 20,
              child: _TwinkleStar(
                size: i % 3 == 0 ? 3 : 2,
                delay: Duration(milliseconds: (i * 400)),
                duration: Duration(milliseconds: 2000 + i * 300),
              ),
            );
          }),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Ramp sleeping
                const RampWidget(state: RampState.sleeping, size: 90),
                const SizedBox(height: 12),
                const Text('🌙', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'Sleep Mode Active',
                  style: AppText.display.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rest well, Priya.',
                  style: AppText.caption.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 24),
                // Checklist
                ...['Notifications silenced', 'Screen going to grayscale',
                    'OFFRAMP locked until 7:00 AM', "Tomorrow's step scheduled"]
                    .map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          '✓',
                          style: TextStyle(color: AppColors.sage, fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Sleep sounds
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLEEP SOUNDS',
                        style: AppText.cardTitle.copyWith(color: Colors.white60),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: SleepSound.values.map((s) {
                          final selected = state.sleepSound == s;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => state.setSleepSound(s),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.sage
                                      : Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.sage
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    kSleepSoundLabels[s]!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Reminder
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lavender.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Put phone in kitchen to charge 🔌',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: _placed ? AppButtons.sage : AppButtons.coral,
                    onPressed: () {
                      setState(() => _placed = true);
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (mounted) {
                          context.read<AppState>().goTo('morning');
                        }
                      });
                    },
                    child: Text(
                      _placed ? "Done! Good night 🌙" : "I've Done It ✓",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TwinkleStar extends StatefulWidget {
  final double size;
  final Duration delay;
  final Duration duration;

  const _TwinkleStar({
    required this.size,
    required this.delay,
    required this.duration,
  });

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
