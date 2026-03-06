import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';
import 'dashboard_screen.dart';
import '../stats/stats_screen.dart';
import '../buffer/human_buffer_screen.dart';
import '../friction/friction_overlay.dart';
import '../focus/focus_overlay.dart';
import '../focus/win_overlay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Stack(
      children: [
        Column(
          children: [
            // Screen content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildTab(state.tab),
              ),
            ),
            // Bottom navigation
            if (state.overlay == null) _buildBottomNav(context, state),
            // Demo shortcuts
            if (state.overlay == null) _buildDemoShortcuts(context, state),
          ],
        ),
        // Overlays
        if (state.overlay == 'friction')
          FrictionOverlay(
            tasks: state.tasks,
            onClose: () => state.setOverlay(null),
            onOpen: () => state.setOverlay(null),
          ),
        if (state.overlay == 'focus')
          FocusOverlay(
            onComplete: () => state.setOverlay('win'),
            onClose: () => state.setOverlay(null),
          ),
        if (state.overlay == 'win')
          WinOverlay(
            onClose: () {
              state.completeWinTask();
              state.setOverlay(null);
            },
          ),
      ],
    );
  }

  Widget _buildTab(String tab) {
    switch (tab) {
      case 'stats':
        return const StatsScreen(key: ValueKey('stats'));
      case 'settings':
        return const HumanBufferScreen(key: ValueKey('settings'));
      default:
        return const DashboardScreen(key: ValueKey('home'));
    }
  }

  Widget _buildBottomNav(BuildContext context, AppState state) {
    final tabs = [
      ('home', '🏠', 'Home'),
      ('stats', '📊', 'Stats'),
      ('settings', '📞', 'Buffer'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((t) {
              final active = state.tab == t.$1;
              return GestureDetector(
                onTap: () => state.setTab(t.$1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: active ? 1.0 : 0.35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.$2, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        t.$3.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoShortcuts(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEMO SHORTCUTS',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _shortcutBtn('⏸ Friction', () => state.setOverlay('friction')),
              _shortcutBtn('🎯 Focus', () => state.setOverlay('focus')),
              _shortcutBtn('🎉 Win', () => state.setOverlay('win')),
              _shortcutBtn('🌙 Loop→Sleep', () => state.goTo('loop')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcutBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
          color: AppColors.bgCard,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
