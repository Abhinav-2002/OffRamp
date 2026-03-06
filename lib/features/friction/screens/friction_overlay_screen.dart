import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/four_things.dart';

// ═════════════════════════════════════════════════════════════════════════════
// FRICTION OVERLAY SCREEN - 30-second countdown with breathing animation
// Shows current Win Task, Close/Open Anyway buttons
// Semi-transparent Deep Navy 90% background
// ═════════════════════════════════════════════════════════════════════════════

class FrictionOverlayScreen extends StatefulWidget {
  final String? packageName;
  final String? appName;

  const FrictionOverlayScreen({
    super.key,
    this.packageName,
    this.appName,
  });

  @override
  State<FrictionOverlayScreen> createState() => _FrictionOverlayScreenState();
}

class _FrictionOverlayScreenState extends State<FrictionOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  int _countdown = 30;
  Timer? _timer;
  FourThings? _fourThings;
  String? _winTask;

  static const platform = MethodChannel('com.offramp/friction');

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadData();
    _startCountdown();
  }

  void _setupAnimation() {
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _breathingController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    _fourThings = HiveService().getFourThings();
    setState(() {
      _winTask = _fourThings?.winTask ?? 'Your Win Task';
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _onOpenAnyway();
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.overlayBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App name indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Opening ${widget.appName ?? 'app'}...',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Breathing countdown circle
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _breathingAnimation.value,
                        height: 200 * _breathingAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.softSage.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.softSage.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_countdown',
                                style: AppText.timerDigits.copyWith(
                                  fontSize: 56,
                                  color: AppColors.softSage,
                                ),
                              ),
                              Text(
                                'seconds',
                                style: AppText.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Mascot with calm expression
                  MascotWidget(
                    state: MascotState.stop,
                    size: 100,
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Win Task reminder
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.softSage.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Win Task:',
                          style: AppText.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          _winTask ?? 'Complete your 50-minute task',
                          style: AppText.bodyMedium.copyWith(
                            color: AppColors.creamWhite,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      // Close button - Warm Coral
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: AppButtons.primary,
                            onPressed: _onClose,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home,
                                  color: AppColors.creamWhite,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Close',
                                  style: AppText.button,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: AppSpacing.md),

                      // Open Anyway button - Muted Gray
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: AppButtons.tertiary,
                            onPressed: _onOpenAnyway,
                            child: Text(
                              'Open Anyway',
                              style: AppText.button,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Tip text
                  Text(
                    'Take a breath. Is this what you want right now?',
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

  Future<void> _onClose() async {
    // Record resistance in stats
    await HiveService().recordUrge(resisted: true);

    try {
      await platform.invokeMethod('onCloseClicked');
    } catch (e) {
      // Fallback: just go back
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _onOpenAnyway() async {
    // Record urge (not resisted)
    await HiveService().recordUrge(resisted: false);

    try {
      await platform.invokeMethod('onOpenAnywayClicked');
    } catch (e) {
      // Fallback: just go back
      if (mounted) Navigator.of(context).pop();
    }
  }
}
