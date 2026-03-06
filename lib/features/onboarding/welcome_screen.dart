import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Ramp mascot floating
          const RampWidget(state: RampState.idle, size: 120),
          const SizedBox(height: 20),
          // Moon emoji
          const Text('🌙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('OFFRAMP', style: AppText.display),
          const SizedBox(height: 8),
          Text(
            'Your evening, reclaimed.',
            style: AppText.quote,
          ),
          const SizedBox(height: 32),
          // Quote card
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(20),
            child: Text(
              '"Willpower is a scam.\nDesign your environment instead."',
              style: AppText.quote.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 260,
            child: ElevatedButton(
              style: AppButtons.coral,
              onPressed: () {
                context.read<AppState>().goTo('permissions');
              },
              child: const Text('Get Started →'),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
