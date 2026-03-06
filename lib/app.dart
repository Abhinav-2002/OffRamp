import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'models/app_state.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/onboarding/permissions_screen.dart';
import 'features/onboarding/voice_setup_screen.dart';
import 'features/onboarding/app_selection_screen.dart';
import 'features/onboarding/ready_screen.dart';
import 'features/home/home_screen.dart';
import 'features/loop_closer/loop_closer_screen.dart';
import 'features/loop_closer/sleep_mode_screen.dart';
import 'features/loop_closer/morning_screen.dart';

class OfframpApp extends StatelessWidget {
  const OfframpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offramp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: ColorScheme.light(
          primary: AppColors.coral,
          secondary: AppColors.sage,
          surface: AppColors.bgCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screen = state.screen;
    final isOnboarding = ['welcome', 'permissions', 'voice', 'apps', 'ready'].contains(screen);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: Padding(
            key: ValueKey(screen),
            padding: EdgeInsets.only(
              left: isOnboarding || screen == 'loop' ? 20 : 0,
              right: isOnboarding || screen == 'loop' ? 20 : 0,
              top: isOnboarding ? 16 : 0,
            ),
            child: _buildScreen(screen),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(String screen) {
    switch (screen) {
      case 'welcome':
        return const WelcomeScreen();
      case 'permissions':
        return const PermissionsScreen();
      case 'voice':
        return const VoiceSetupScreen();
      case 'apps':
        return const AppSelectionScreen();
      case 'ready':
        return const ReadyScreen();
      case 'home':
        return const HomeScreen();
      case 'loop':
        return const LoopCloserScreen();
      case 'sleep':
        return const SleepModeScreen();
      case 'morning':
        return const MorningScreen();
      default:
        return const WelcomeScreen();
    }
  }
}
