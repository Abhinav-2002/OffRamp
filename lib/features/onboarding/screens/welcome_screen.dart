import 'package:flutter/material.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/user_settings.dart';

// ═════════════════════════════════════════════════════════════════════════════
// WELCOME SCREEN - All elements centered per spec
// Background: Deep Navy (#1A1F2E)
// Mascot at 40% of screen height, centered
// ═════════════════════════════════════════════════════════════════════════════

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final settings = HiveService().getSettings();
    if (settings.onboardingComplete) {
      // Skip to home screen if onboarding is complete
      widget.onGetStarted();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mascot - 40% of screen height
                    SizedBox(
                      height: screenHeight * 0.4,
                      child: Center(
                        child: MascotWidget(
                          state: MascotState.wave,
                          size: 160,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // Title "OFFRAMP" - centered
                    Text(
                      'OFFRAMP',
                      style: AppText.display.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.sm),

                    // Subtitle "Your evening, reclaimed." - centered
                    Text(
                      'Your evening, reclaimed.',
                      style: AppText.titleLight.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Quote card - centered
                    Container(
                      constraints: BoxConstraints(maxWidth: 320),
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mutedGray.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '"Willpower is a scam.',
                            style: AppText.quote.copyWith(
                              color: AppColors.creamWhite,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Design your environment instead."',
                            style: AppText.quote.copyWith(
                              color: AppColors.creamWhite,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    // Get Started button - centered
                    SizedBox(
                      width: 280,
                      height: 56,
                      child: ElevatedButton(
                        style: AppButtons.primary,
                        onPressed: _isLoading ? null : _onGetStarted,
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.creamWhite,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
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

                    SizedBox(height: AppSpacing.md),

                    // Tagline below button - centered
                    Text(
                      'Designed for 9pm brain, not 9am brain',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onGetStarted() async {
    setState(() => _isLoading = true);

    // Initialize user settings
    final settings = HiveService().getSettings();
    if (settings.userName.isEmpty) {
      final newSettings = settings.copyWith(userName: 'Friend');
      await HiveService().saveSettings(newSettings);
    }

    setState(() => _isLoading = false);
    widget.onGetStarted();
  }
}
