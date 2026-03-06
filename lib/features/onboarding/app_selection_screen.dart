import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/app_state.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Friction Apps', style: AppText.displaySm),
          const SizedBox(height: 6),
          Text(
            'Which apps do you want a pause before opening?',
            style: AppText.caption,
          ),
          const SizedBox(height: 20),
          ...List.generate(kApps.length, (i) {
            final selected = state.selectedApps.contains(i);
            return GestureDetector(
              onTap: () => state.toggleApp(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.sage.withValues(alpha: 0.08)
                      : AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.sage.withValues(alpha: 0.35)
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Text(kApps[i].icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        kApps[i].name,
                        style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.sage : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? AppColors.sage
                              : AppColors.textMuted.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Center(
                              child: Icon(Icons.check, color: Colors.white, size: 12),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtons.coral,
              onPressed: () {
                context.read<AppState>().goTo('ready');
              },
              child: Text('Continue with ${state.selectedApps.length} apps →'),
            ),
          ),
        ],
      ),
    );
  }
}
