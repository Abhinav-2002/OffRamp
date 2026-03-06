import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PERMISSION WIZARD - 3 steps with real Android settings integration
// Steps: 1. Usage Stats, 2. Display Over Apps, 3. Notifications
// ═════════════════════════════════════════════════════════════════════════════

class PermissionWizard extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionWizard({
    super.key,
    required this.onComplete,
  });

  @override
  State<PermissionWizard> createState() => _PermissionWizardState();
}

class _PermissionWizardState extends State<PermissionWizard>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final List<bool> _permissionsGranted = [false, false, false];
  late AnimationController _controller;
  Timer? _permissionCheckTimer;

  static const platform = MethodChannel('com.offramp/permissions');

  final List<PermissionStep> _steps = [
    PermissionStep(
      title: 'Usage Access',
      description: 'We need to see which apps you open so we can help you stay focused on what matters.',
      action: SettingsAction.usageStats,
      mascotState: MascotState.think,
    ),
    PermissionStep(
      title: 'Display Over Apps',
      description: 'This lets us show gentle reminders when you open distracting apps.',
      action: SettingsAction.overlay,
      mascotState: MascotState.point,
    ),
    PermissionStep(
      title: 'Notifications',
      description: 'We\'ll nudge you about your 4 Things and when it\'s time to wind down.',
      action: SettingsAction.notifications,
      mascotState: MascotState.wave,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _startPermissionCheck();
  }

  void _startPermissionCheck() {
    _permissionCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkPermissions();
    });
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final results = await platform.invokeMethod<List<dynamic>>('checkPermissions');
      if (results != null && mounted) {
        setState(() {
          for (int i = 0; i < results.length && i < _permissionsGranted.length; i++) {
            _permissionsGranted[i] = results[i] as bool;
          }
        });

        // Auto-advance if permission granted
        if (_currentStep < _permissionsGranted.length &&
            _permissionsGranted[_currentStep] &&
            _currentStep < _steps.length - 1) {
          _nextStep();
        }
      }
    } catch (e) {
      // Permissions not available on platform, simulate for testing
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _permissionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Step indicator
                  _buildStepIndicator(),

                  SizedBox(height: AppSpacing.lg),

                  // Mascot with appropriate expression
                  MascotWidget(
                    state: _steps[_currentStep].mascotState,
                    size: 140,
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Title - centered
                  Text(
                    _steps[_currentStep].title,
                    style: AppText.title,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Description - centered, max 3 lines
                  Text(
                    _steps[_currentStep].description,
                    style: AppText.body.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Grant Permission button
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: ElevatedButton(
                      style: _permissionsGranted[_currentStep]
                          ? AppButtons.secondary
                          : AppButtons.primary,
                      onPressed: _permissionsGranted[_currentStep]
                          ? null
                          : () => _openSettings(_steps[_currentStep].action),
                      child: Text(
                        _permissionsGranted[_currentStep]
                            ? '✓ Granted'
                            : 'Grant Permission',
                        style: AppText.button,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Skip option
                  TextButton(
                    onPressed: _skipStep,
                    child: Text(
                      'Skip for now',
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Navigation buttons
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: _previousStep,
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      label: Text(
                        'Back',
                        style: AppText.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),

                  SizedBox(height: AppSpacing.md),

                  // Continue button (enabled when all permissions granted or skipped)
                  if (_currentStep == _steps.length - 1)
                    SizedBox(
                      width: 280,
                      height: 56,
                      child: ElevatedButton(
                        style: AppButtons.secondary,
                        onPressed: widget.onComplete,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: AppText.button,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: AppColors.creamWhite,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep || _permissionsGranted[index];

        return Row(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.softSage
                    : isActive
                        ? AppColors.warmCoral
                        : AppColors.charcoal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (index < _steps.length - 1) SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  Future<void> _openSettings(SettingsAction action) async {
    try {
      await platform.invokeMethod('openSettings', {'action': action.index});
    } catch (e) {
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open settings. Please enable manually.',
              style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
            ),
            backgroundColor: AppColors.warmCoral,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _controller.forward(from: 0);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.forward(from: 0);
    }
  }

  void _skipStep() {
    if (_currentStep < _steps.length - 1) {
      _nextStep();
    } else {
      widget.onComplete();
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PERMISSION STEP DATA
// ═════════════════════════════════════════════════════════════════════════════

class PermissionStep {
  final String title;
  final String description;
  final SettingsAction action;
  final MascotState mascotState;

  PermissionStep({
    required this.title,
    required this.description,
    required this.action,
    required this.mascotState,
  });
}

enum SettingsAction {
  usageStats,
  overlay,
  notifications,
}
