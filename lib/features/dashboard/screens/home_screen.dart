import 'package:flutter/material.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/four_things.dart';
import 'package:offramp/models/user_settings.dart';
import 'package:offramp/models/human_buffer.dart';

// ═════════════════════════════════════════════════════════════════════════════
// HOME SCREEN DASHBOARD - Real data from Hive, no mock data
// Cards: 4 Things, Win Task Timer, Human Buffer, Sleep Mode
// ═════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  final VoidCallback? onStatsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLoopCloserTap;

  const HomeScreen({
    super.key,
    this.onStatsTap,
    this.onSettingsTap,
    this.onLoopCloserTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FourThings? _fourThings;
  UserSettings? _settings;
  List<HumanBuffer> _buffers = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _fourThings = HiveService().getFourThings();
    _settings = HiveService().getSettings();
    _buffers = HiveService().getHumanBuffers();

    setState(() => _isLoading = false);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.softSage),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHomeTab(),
            _buildStatsTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.softSage,
      backgroundColor: AppColors.charcoal,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            SizedBox(height: AppSpacing.xl),

            // 4 Things Card
            _buildFourThingsCard(),

            SizedBox(height: AppSpacing.lg),

            // Win Task Timer Card
            _buildWinTaskCard(),

            SizedBox(height: AppSpacing.lg),

            // Human Buffer Card
            _buildHumanBufferCard(),

            SizedBox(height: AppSpacing.lg),

            // Sleep Mode Card
            _buildSleepModeCard(),

            SizedBox(height: AppSpacing.xl),

            // Loop Closer quick action
            _buildLoopCloserButton(),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting,',
              style: AppText.body.copyWith(color: AppColors.textMuted),
            ),
            Text(
              _settings?.userName ?? 'Friend',
              style: AppText.title,
            ),
          ],
        ),
        // Date display
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${DateTime.now().month}/${DateTime.now().day}',
            style: AppText.caption.copyWith(color: AppColors.softSage),
          ),
        ),
      ],
    );
  }

  Widget _buildFourThingsCard() {
    if (_fourThings == null || !_fourThings!.isComplete) {
      return _buildSetupCard(
        icon: Icons.list_alt,
        title: 'Set Your 4 Things',
        subtitle: 'Define your evening priorities',
        onTap: () {/* Navigate to setup */},
      );
    }

    final progress = _fourThings!.progress;

    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Your 4 Things',
                    style: AppText.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {/* Edit 4 things */},
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.charcoal,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.softSage),
              minHeight: 8,
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Progress text
          Text(
            '${_fourThings!.completedCount} of 4 complete',
            style: AppText.caption,
          ),

          SizedBox(height: AppSpacing.md),

          // Thing items
          _buildThingItem(0, '👤', _fourThings!.socialConnection, _fourThings!.socialDone),
          _buildThingItem(1, '📖', _fourThings!.readLearn, _fourThings!.readDone),
          _buildThingItem(2, '🍵', _fourThings!.drinkSelfCare, _fourThings!.drinkDone),
          _buildThingItem(3, '✅', _fourThings!.winTask, _fourThings!.winDone),
        ],
      ),
    );
  }

  Widget _buildThingItem(int index, String icon, String text, bool done) {
    return InkWell(
      onTap: () async {
        final updated = _fourThings!.copyWith(
          socialDone: index == 0 ? !_fourThings!.socialDone : null,
          readDone: index == 1 ? !_fourThings!.readDone : null,
          drinkDone: index == 2 ? !_fourThings!.drinkDone : null,
          winDone: index == 3 ? !_fourThings!.winDone : null,
        );
        await HiveService().saveFourThings(updated);
        setState(() => _fourThings = updated);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.softSage : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: done ? AppColors.softSage : AppColors.mutedGray,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(icon, style: const TextStyle(fontSize: 16)),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppText.body.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? AppColors.textMuted : AppColors.creamWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinTaskCard() {
    final winTask = _fourThings?.winTask ?? 'Set your win task';

    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 20)),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Win Task',
                    style: AppText.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmCoral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_settings?.winTaskDuration ?? 50} min',
                  style: AppText.caption.copyWith(color: AppColors.warmCoral),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          Text(
            winTask,
            style: AppText.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppSpacing.md),

          // Reward input
          TextField(
            decoration: AppInputDecoration.textField(
              hint: 'What\'s your reward?',
              label: 'Reward',
            ),
            style: AppText.body.copyWith(color: AppColors.creamWhite),
            onChanged: (value) {
              // Save reward
            },
          ),

          SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: AppButtons.smallPrimary,
              onPressed: () {/* Start timer */},
              child: const Text('Start Focus Timer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumanBufferCard() {
    final nextBuffer = _buffers.isNotEmpty ? _buffers.first : null;

    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👋', style: TextStyle(fontSize: 20)),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Human Buffer',
                    style: AppText.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {/* Edit contacts */},
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          if (nextBuffer != null) ...[
            Text(
              'Next: ${nextBuffer.timeFormatted}',
              style: AppText.bodyMedium.copyWith(color: AppColors.softSage),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              nextBuffer.contactName,
              style: AppText.body,
            ),
            Text(
              nextBuffer.methodLabel,
              style: AppText.caption,
            ),
          ] else ...[
            Text(
              'No contacts set up',
              style: AppText.body.copyWith(color: AppColors.textMuted),
            ),
            SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () {/* Setup contacts */},
              child: Text(
                'Add contact reminders',
                style: AppText.bodyMedium.copyWith(color: AppColors.softSage),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepModeCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 20)),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sleep Mode',
                    style: AppText.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {/* Configure */},
                icon: const Icon(
                  Icons.settings,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activates at',
                      style: AppText.caption,
                    ),
                    Text(
                      _settings?.sleepTimeFormatted ?? '9:00 PM',
                      style: AppText.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.mutedGray.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.md),
                      child: Text(
                        'Last night',
                        style: AppText.caption,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.md),
                      child: Text(
                        'Not activated',
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoopCloserButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mutedLavender.withOpacity(0.3),
            AppColors.softSage.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onLoopCloserTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🧠', style: TextStyle(fontSize: 24)),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loop Closer',
                        style: AppText.bodyMedium,
                      ),
                      Text(
                        'Brain dump & wind down',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softSage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.softSage,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyMedium),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: AppButtons.smallPrimary,
            child: const Text('Set Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return const Center(
      child: Text(
        'Stats coming soon...',
        style: TextStyle(color: AppColors.creamWhite),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text(
        'Settings coming soon...',
        style: TextStyle(color: AppColors.creamWhite),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        border: Border(
          top: BorderSide(
            color: AppColors.mutedGray.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart, 'Stats'),
              _buildNavItem(2, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.softSage : AppColors.textMuted,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: isActive ? AppColors.softSage : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
