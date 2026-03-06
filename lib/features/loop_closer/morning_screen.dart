import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class MorningScreen extends StatelessWidget {
  const MorningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const RampWidget(state: RampState.waking, size: 100),
          const SizedBox(height: 12),
          const Text('☀️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppText.display,
              children: [
                const TextSpan(text: 'Good Morning,\n'),
                TextSpan(
                  text: 'Priya',
                  style: AppText.display.copyWith(color: AppColors.coral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Sleep mode deactivated.', style: AppText.caption),
          const SizedBox(height: 28),
          // Today's one step
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR ONE STEP TODAY', style: AppText.cardTitle),
                const SizedBox(height: 8),
                Text(
                  'Email professor @ 10:00 AM',
                  style: AppText.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Brain dump access
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Last night's brain dump is saved",
                    style: AppText.body,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      style: AppButtons.ghostSmall,
                      onPressed: () {},
                      child: const Text('View'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: AppButtons.ghostSmall,
                      onPressed: () {},
                      child: const Text('Archive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtons.coral,
              onPressed: () {
                context.read<AppState>().goTo('home');
              },
              child: const Text('Start New Day →'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
