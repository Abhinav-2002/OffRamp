import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/user_settings.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SLEEP MODE SCREEN - Activates DND, grayscale, locks app until wake time
// Mascot wearing sleep cap, animated breathing
// ═════════════════════════════════════════════════════════════════════════════

class SleepModeScreen extends StatefulWidget {
  final VoidCallback? onMorningTap;

  const SleepModeScreen({
    super.key,
    this.onMorningTap,
  });

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  bool _isActive = false;
  bool _isLoading = false;
  UserSettings? _settings;
  Timer? _wakeTimer;
  String _timeUntilWake = '';

  static const platform = MethodChannel('com.offramp/sleep');

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadSettings();
  }

  void _setupAnimation() {
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _breathingController.repeat(reverse: true);
  }

  Future<void> _loadSettings() async {
    _settings = HiveService().getSettings();
    setState(() {});
  }

  void _startWakeTimer() {
    _wakeTimer?.cancel();
    _updateTimeUntilWake();

    _wakeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTimeUntilWake();
    });
  }

  void _updateTimeUntilWake() {
    if (_settings == null) return;

    final now = DateTime.now();
    var wakeTime = DateTime(
      now.year,
      now.month,
      now.day,
      _settings!.wakeTime.hour,
      _settings!.wakeTime.minute,
    );

    if (wakeTime.isBefore(now)) {
      wakeTime = wakeTime.add(const Duration(days: 1));
    }

    final diff = wakeTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    setState(() {
      _timeUntilWake = hours > 0
          ? '$hours hr ${minutes} min until wake'
          : '$minutes min until wake';
    });
  }

  Future<void> _activateSleepMode() async {
    setState(() => _isLoading = true);

    try {
      // Request DND access
      await platform.invokeMethod('enableDoNotDisturb');

      // Enable grayscale
      await platform.invokeMethod('enableGrayscale');

      // Record activation
      HiveService().getTodayStats().recordSleepMode();

      setState(() {
        _isActive = true;
        _isLoading = false;
      });

      _startWakeTimer();

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sleep mode activated. Sweet dreams!',
              style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
            ),
            backgroundColor: AppColors.mutedLavender,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not activate sleep mode. Check permissions.',
              style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
            ),
            backgroundColor: AppColors.warmCoral,
          ),
        );
      }
    }
  }

  Future<void> _deactivateSleepMode() async {
    setState(() => _isLoading = true);

    try {
      await platform.invokeMethod('disableDoNotDisturb');
      await platform.invokeMethod('disableGrayscale');

      setState(() {
        _isActive = false;
        _isLoading = false;
      });

      _wakeTimer?.cancel();

      widget.onMorningTap?.call();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _wakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sleepBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Breathing mascot
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathingAnimation.value,
                        child: MascotWidget(
                          state: MascotState.sleep,
                          size: 150,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSpacing.xl),

                  if (!_isActive) ...[
                    // Activation UI
                    Text(
                      'Ready to Sleep?',
                      style: AppText.title.copyWith(
                        color: AppColors.creamWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.md),

                    Text(
                      'Sleep mode will:\n'
                      '• Enable Do Not Disturb\n'
                      '• Set screen to grayscale\n'
                      '• Lock app until ${_settings?.wakeTimeFormatted ?? '7:00 AM'}',
                      style: AppText.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    SizedBox(
                      width: 280,
                      height: 64,
                      child: ElevatedButton(
                        style: AppButtons.primary.copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            AppColors.mutedLavender,
                          ),
                        ),
                        onPressed: _isLoading ? null : _activateSleepMode,
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: AppColors.creamWhite,
                                strokeWidth: 2,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    color: AppColors.creamWhite,
                                    size: 24,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Activate Sleep Mode',
                                    style: AppText.button,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ] else ...[
                    // Active sleep mode UI
                    Text(
                      'Sleep Mode Active',
                      style: AppText.title.copyWith(
                        color: AppColors.mutedLavender,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.md),

                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mutedLavender.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.do_not_disturb_on,
                            color: AppColors.mutedLavender,
                            size: 32,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Do Not Disturb Enabled',
                            style: AppText.bodyMedium.copyWith(
                              color: AppColors.creamWhite,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Grayscale Mode On',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    Text(
                      _timeUntilWake,
                      style: AppText.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Emergency unlock (for testing)
                    TextButton(
                      onPressed: _isLoading ? null : _deactivateSleepMode,
                      child: Text(
                        'Wake Up Early',
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.warmCoral,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),

                  // Tip
                  Text(
                    _isActive
                        ? 'Put your phone away and rest well.'
                        : 'Your brain dump is saved. Everything can wait until morning.',
                    style: AppText.caption.copyWith(
                      color: AppColors.textMuted.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
