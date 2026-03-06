import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class LoopCloserScreen extends StatelessWidget {
  const LoopCloserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ramp yawning
          const Center(child: RampWidget(state: RampState.yawning, size: 70)),
          const SizedBox(height: 12),
          Text('🧠 Close Your Loops', style: AppText.displaySm),
          const SizedBox(height: 4),
          Text('"What\'s looping in your head?"', style: AppText.caption),
          const SizedBox(height: 20),
          // Voice dump / type buttons
          Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtons.coralSmall,
                        onPressed: () {},
                        child: const Text('🎤 Voice Dump'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: AppButtons.ghostSmall,
                        onPressed: () {},
                        child: const Text('✍️ Type'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Brain dump is private & encrypted', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Loop items
          ...state.loops.map((l) {
            return GestureDetector(
              onTap: () => state.toggleLoop(l.id),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: l.parked ? 0.4 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: l.parked
                        ? Colors.transparent
                        : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: l.parked ? AppColors.textMuted : l.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.text,
                          style: AppText.body.copyWith(fontSize: 13),
                        ),
                      ),
                      Text(
                        l.parked ? 'parked ✓' : 'tap',
                        style: TextStyle(
                          fontSize: 11,
                          color: l.parked ? AppColors.sage : AppColors.textSecondary,
                          fontWeight: l.parked ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // All parked message
          if (state.allLoopsParked)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Mind clear. Rest earned.',
                  style: AppText.displaySm.copyWith(fontSize: 18),
                ),
              ),
            ),
          // Pick ONE step
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PICK ONE STEP FOR TOMORROW', style: AppText.cardTitle),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Email professor @ 10:00 AM', style: AppText.body.copyWith(fontSize: 13)),
                      ElevatedButton(
                        style: AppButtons.sageSmall,
                        onPressed: () {},
                        child: const Text('Schedule'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtons.coral,
              onPressed: () => state.goTo('sleep'),
              child: const Text('Activate Sleep Mode 🌙'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
