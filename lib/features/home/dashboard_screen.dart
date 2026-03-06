import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pct = (state.taskProgress * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppText.display,
                    children: [
                      TextSpan(text: '${_greeting()},\n'),
                      TextSpan(
                        text: 'Priya',
                        style: AppText.display.copyWith(color: AppColors.coral),
                      ),
                      const TextSpan(text: ' 👋'),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  const Text('⚙️', style: TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Things card
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('📋', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text("TODAY'S 4 THINGS", style: AppText.cardTitle),
                    const Spacer(),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.coral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...state.tasks.map((t) {
                  return GestureDetector(
                    onTap: () => state.toggleTask(t.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: t.id < state.tasksTotal ? 1 : 0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: const Cubic(0.34, 1.56, 0.64, 1),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.done ? AppColors.sage : Colors.transparent,
                              border: Border.all(
                                color: t.done
                                    ? AppColors.sage
                                    : AppColors.textMuted.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: t.done
                                  ? [
                                      BoxShadow(
                                        color: AppColors.sage.withValues(alpha: 0.4),
                                        blurRadius: 14,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: t.done
                                ? const Center(
                                    child: Icon(Icons.check, color: Colors.white, size: 12),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${t.icon} ${t.text}',
                              style: AppText.body.copyWith(
                                color: t.done
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                                decoration: t.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (!t.done)
                            Text(
                              'tap',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: state.taskProgress,
                    minHeight: 5,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.tasksDone}/${state.tasksTotal} complete',
                      style: AppText.caption,
                    ),
                    Text(
                      '$pct%',
                      style: AppText.caption.copyWith(
                        color: AppColors.sage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Win Task Timer card
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('WIN TASK TIMER', style: AppText.cardTitle),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Lab report',
                  style: AppText.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '50 minutes · Reward: Hot shower + 1 episode',
                  style: AppText.caption,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtons.coral,
                    onPressed: () => state.setOverlay('focus'),
                    child: const Text('Start Focus →'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Human Buffer card
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📞', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('HUMAN BUFFER', style: AppText.cardTitle),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Call Mom',
                            style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Next: 5:30 PM (in 2 hours)',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: AppButtons.ghostSmall,
                          onPressed: () {},
                          child: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: AppButtons.sageSmall,
                          onPressed: () {},
                          child: const Text('Test'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sleep Mode card
          Container(
            width: double.infinity,
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('SLEEP MODE', style: AppText.cardTitle),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activates: 9:00 PM',
                            style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last night: Activated at 8:47 PM ✓',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: AppButtons.ghostSmall,
                      onPressed: () {},
                      child: const Text('Configure'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
