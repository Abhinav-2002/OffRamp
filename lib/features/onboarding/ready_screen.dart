import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  static const _flowSteps = [
    ['🏠', "Arrive home → check widget (no app needed)"],
    ['⏸️', "Try to scroll → 30-second pause"],
    ['🏆', "Complete win task → claim reward"],
    ['🌙', "9 PM → Loop closer + sleep mode"],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Ramp celebrating
          const RampWidget(state: RampState.celebrating, size: 100),
          const SizedBox(height: 16),
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text("You're set.", style: AppText.display),
          const SizedBox(height: 8),
          Text('Your environment is now designed.', style: AppText.caption),
          const SizedBox(height: 28),
          // Tonight's flow card
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TONIGHT'S FLOW", style: AppText.cardTitle),
                const SizedBox(height: 14),
                ...List.generate(_flowSteps.length, (i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: i < _flowSteps.length - 1
                        ? BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.divider,
                                width: 1,
                              ),
                            ),
                          )
                        : null,
                    child: Row(
                      children: [
                        Text(_flowSteps[i][0], style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _flowSteps[i][1],
                            style: AppText.body.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtons.coral,
              onPressed: () {
                context.read<AppState>().completeOnboarding();
                context.read<AppState>().goTo('home');
              },
              child: const Text('Start My First Day →'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
