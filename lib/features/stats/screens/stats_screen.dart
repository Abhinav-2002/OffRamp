import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/user_stats.dart';

// ═════════════════════════════════════════════════════════════════════════════
// STATS SCREEN - Weekly view with real data from Hive
// Shows: urges resisted, win tasks completed, human connections, sleep mode
// Export data button (CSV)
// ═════════════════════════════════════════════════════════════════════════════

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<UserStats> _weeklyStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    _weeklyStats = HiveService().getWeeklyStats();
    setState(() => _isLoading = false);
  }

  int get _totalUrgesResisted {
    return _weeklyStats.fold(0, (sum, s) => sum + s.urgesResisted);
  }

  int get _totalUrges {
    return _weeklyStats.fold(0, (sum, s) => sum + s.urgesTotal);
  }

  double get _resistanceRate {
    return _totalUrges > 0 ? _totalUrgesResisted / _totalUrges : 0;
  }

  int get _totalWinTasks {
    return _weeklyStats.fold(0, (sum, s) => sum + s.winTasksCompleted);
  }

  int get _totalConnections {
    return _weeklyStats.fold(0, (sum, s) => sum + s.humanConnections);
  }

  int get _totalSleepModes {
    return _weeklyStats.fold(0, (sum, s) => sum + s.sleepModeActivations);
  }

  MascotState get _mascotState {
    final rate = _resistanceRate;
    if (rate >= 0.8) return MascotState.celebrate;
    if (rate >= 0.5) return MascotState.wave;
    if (rate >= 0.3) return MascotState.think;
    return MascotState.idle;
  }

  Future<void> _exportData() async {
    try {
      final data = HiveService().exportAllData();
      final jsonString = jsonEncode(data);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/offramp_data.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Offramp data export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not export data',
              style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
            ),
            backgroundColor: AppColors.warmCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: AppColors.softSage,
          backgroundColor: AppColors.charcoal,
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Your Week',
                    style: AppText.display,
                  ),

                  SizedBox(height: AppSpacing.sm),

                  Text(
                    DateFormat('MMM d - MMM d, yyyy').format(
                      DateTime.now().subtract(const Duration(days: 7)),
                    ),
                    style: AppText.caption,
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Mascot based on performance
                  Center(
                    child: MascotWidget(
                      state: _mascotState,
                      size: 120,
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Weekly summary card
                  _buildSummaryCard(),

                  SizedBox(height: AppSpacing.lg),

                  // Daily breakdown
                  Text(
                    'Daily Breakdown',
                    style: AppText.title.copyWith(fontSize: 16),
                  ),

                  SizedBox(height: AppSpacing.md),

                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.softSage,
                          ),
                        )
                      : _buildDailyStats(),

                  SizedBox(height: AppSpacing.xxl),

                  // Export button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: AppButtons.ghost,
                      onPressed: _exportData,
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Export Data'),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Positive framing message
                  Text(
                    _getEncouragementMessage(),
                    style: AppText.caption.copyWith(
                      color: AppColors.textMuted,
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
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildStatRow(
            icon: '🛡️',
            label: 'Urges Resisted',
            value: '$_totalUrgesResisted',
            subValue: '/ $_totalUrges',
            progress: _resistanceRate,
            color: AppColors.softSage,
          ),
          Divider(color: AppColors.mutedGray, height: AppSpacing.xl),
          _buildStatRow(
            icon: '🎯',
            label: 'Win Tasks Done',
            value: '$_totalWinTasks',
            progress: _totalWinTasks / 7, // Assuming 1 per day max
            color: AppColors.warmCoral,
          ),
          Divider(color: AppColors.mutedGray, height: AppSpacing.xl),
          _buildStatRow(
            icon: '👋',
            label: 'Human Connections',
            value: '$_totalConnections',
            progress: _totalConnections / 14, // Assuming 2 per day
            color: AppColors.mutedLavender,
          ),
          Divider(color: AppColors.mutedGray, height: AppSpacing.xl),
          _buildStatRow(
            icon: '🌙',
            label: 'Sleep Modes',
            value: '$_totalSleepModes',
            progress: _totalSleepModes / 7,
            color: AppColors.softSage,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    String? subValue,
    required double progress,
    required Color color,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppText.body,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: AppText.bodyMedium.copyWith(
                    color: color,
                    fontSize: 18,
                  ),
                ),
                if (subValue != null)
                  Text(
                    subValue,
                    style: AppText.caption,
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedProgress,
            backgroundColor: AppColors.charcoal,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStats() {
    if (_weeklyStats.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: AppDecorations.card,
        child: Center(
          child: Text(
            'No data yet. Start using the app!',
            style: AppText.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: _weeklyStats.map((stat) => _buildDayCard(stat)).toList(),
    );
  }

  Widget _buildDayCard(UserStats stat) {
    final dayName = DateFormat('EEE').format(stat.date);
    final dateNum = DateFormat('d').format(stat.date);
    final isToday = DateUtils.isSameDay(stat.date, DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isToday ? AppColors.charcoal : AppColors.charcoal.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.softSage.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Day indicator
          Container(
            width: 48,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.softSage.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: AppText.caption.copyWith(
                    color: isToday ? AppColors.softSage : AppColors.textMuted,
                  ),
                ),
                Text(
                  dateNum,
                  style: AppText.bodyMedium.copyWith(
                    color: isToday ? AppColors.softSage : AppColors.creamWhite,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // Stats summary
          Expanded(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                if (stat.urgesResisted > 0)
                  _buildMiniStat('🛡️', '${stat.urgesResisted}'),
                if (stat.winTasksCompleted > 0)
                  _buildMiniStat('🎯', '${stat.winTasksCompleted}'),
                if (stat.humanConnections > 0)
                  _buildMiniStat('👋', '${stat.humanConnections}'),
                if (stat.sleepModeActivations > 0)
                  _buildMiniStat('🌙', '${stat.sleepModeActivations}'),
              ],
            ),
          ),

          // Resistance rate
          if (stat.urgesTotal > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.softSage.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(stat.resistanceRate * 100).toInt()}%',
                style: AppText.caption.copyWith(
                  color: AppColors.softSage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        SizedBox(width: 2),
        Text(
          value,
          style: AppText.caption,
        ),
      ],
    );
  }

  String _getEncouragementMessage() {
    if (_totalUrgesResisted == 0 && _totalWinTasks == 0) {
      return 'Every journey starts with a single step. You\'ve got this!';
    }

    final rate = _resistanceRate;
    if (rate >= 0.8) {
      return 'Amazing work! You\'re building strong evening habits.';
    } else if (rate >= 0.5) {
      return 'Great progress! Every urge resisted is a win.';
    } else if (_totalUrgesResisted > 0) {
      return 'Every small step counts. Keep going!';
    }

    return 'You\'re taking control of your evenings. Well done!';
  }
}
