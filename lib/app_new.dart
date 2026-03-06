import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/hive_service.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/permission_wizard.dart';
import 'features/onboarding/screens/four_things_setup.dart';
import 'features/onboarding/screens/app_selector.dart';
import 'features/dashboard/screens/home_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'features/sleep/screens/loop_closer_screen.dart';
import 'features/sleep/screens/sleep_mode_screen.dart';
import 'features/friction/screens/friction_overlay_screen.dart';
import 'features/win_task/screens/timer_screen.dart';

// ═════════════════════════════════════════════════════════════════════════════
// OFFRAMP APP - Main application entry point
// Production-ready digital wellness app
// ═════════════════════════════════════════════════════════════════════════════

class OfframpApp extends StatelessWidget {
  const OfframpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OFFRAMP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.deepNavy,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.softSage,
          secondary: AppColors.warmCoral,
          surface: AppColors.charcoal,
          background: AppColors.deepNavy,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _AppNavigator());
      case '/friction':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FrictionOverlayScreen(
            packageName: args?['packageName'] as String?,
            appName: args?['appName'] as String?,
          ),
          fullscreenDialog: true,
        );
      case '/timer':
        return MaterialPageRoute(
          builder: (_) => const WinTaskTimerScreen(),
          fullscreenDialog: true,
        );
      case '/stats':
        return MaterialPageRoute(builder: (_) => const StatsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const _AppNavigator());
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// APP NAVIGATOR - Handles app state and screen routing
// ═════════════════════════════════════════════════════════════════════════════

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  int _currentScreen = 0;
  bool _isLoading = true;
  bool _onboardingComplete = false;

  // Screen indices
  static const int welcome = 0;
  static const int permissions = 1;
  static const int fourThings = 2;
  static const int appSelector = 3;
  static const int home = 4;
  static const int loopCloser = 5;
  static const int sleepMode = 6;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    // Initialize Hive
    await HiveService().initialize();

    // Check onboarding status
    final settings = HiveService().getSettings();

    setState(() {
      _onboardingComplete = settings.onboardingComplete;
      _currentScreen = _onboardingComplete ? home : welcome;
      _isLoading = false;
    });
  }

  void _navigateTo(int screen) {
    setState(() => _currentScreen = screen);
  }

  void _completeOnboarding() async {
    final settings = HiveService().getSettings();
    final updated = settings.copyWith(onboardingComplete: true);
    await HiveService().saveSettings(updated);

    setState(() {
      _onboardingComplete = true;
      _currentScreen = home;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.softSage),
              SizedBox(height: AppSpacing.lg),
              Text(
                'OFFRAMP',
                style: AppText.display.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: AppDurations.normal,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _navigateTo(permissions),
        );

      case permissions:
        return PermissionWizard(
          key: const ValueKey('permissions'),
          onComplete: () => _navigateTo(fourThings),
        );

      case fourThings:
        return FourThingsSetup(
          key: const ValueKey('fourThings'),
          onComplete: () => _navigateTo(appSelector),
        );

      case appSelector:
        return AppSelector(
          key: const ValueKey('appSelector'),
          onComplete: _completeOnboarding,
        );

      case home:
        return HomeScreen(
          key: const ValueKey('home'),
          onLoopCloserTap: () => _navigateTo(loopCloser),
          onStatsTap: () => Navigator.of(context).pushNamed('/stats'),
          onSettingsTap: () {},
        );

      case loopCloser:
        return LoopCloserScreen(
          key: const ValueKey('loopCloser'),
          onSleepModeTap: () => _navigateTo(sleepMode),
        );

      case sleepMode:
        return SleepModeScreen(
          key: const ValueKey('sleepMode'),
          onMorningTap: () => _navigateTo(home),
        );

      default:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _navigateTo(permissions),
        );
    }
  }
}
