import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import '../../mascot/ramp_widget.dart';

class VoiceSetupScreen extends StatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  State<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends State<VoiceSetupScreen> {
  bool _recording = false;
  bool _detected = false;

  final _items = ['Text mom', 'Read chapter 4', 'Make tea', 'Lab report'];
  final _icons = ['👤', '📖', '🍵', '✅'];

  void _handleMic() {
    if (_detected) return;
    setState(() => _recording = true);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _recording = false;
          _detected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your 4 Things', style: AppText.displaySm),
          const SizedBox(height: 6),
          Text('Hold the mic and say your 4 tasks for tonight.', style: AppText.caption),
          const SizedBox(height: 28),
          // Ramp mascot
          Center(
            child: RampWidget(
              state: _recording
                  ? RampState.listening
                  : _detected
                      ? RampState.clapping
                      : RampState.idle,
              size: 80,
            ),
          ),
          const SizedBox(height: 16),
          // Mic button
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: !_detected ? _handleMic : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.coral,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: _recording ? 0.6 : 0.3),
                          blurRadius: _recording ? 24 : 20,
                          spreadRadius: _recording ? 4 : 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎤', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_recording)
                  Text(
                    'Listening...',
                    style: TextStyle(
                      color: AppColors.coral,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!_recording && !_detected)
                  Text(
                    'Hold to speak',
                    style: AppText.caption,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Example or detected
          if (!_detected)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Example', style: AppText.caption.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    '"Text mom, read chapter 4, make tea, lab report"',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          if (_detected)
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('✦', style: TextStyle(color: AppColors.sage)),
                      const SizedBox(width: 6),
                      Text('DETECTED', style: AppText.cardTitle),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sage,
                            ),
                            child: const Center(
                              child: Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_icons[i]} ${_items[i]}',
                            style: AppText.body,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtons.coralSmall,
                          onPressed: () {
                            context.read<AppState>().goTo('apps');
                          },
                          child: const Text('Confirm ✓'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: AppButtons.ghostSmall,
                          onPressed: () {
                            setState(() => _detected = false);
                          },
                          child: const Text('Try Again'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
