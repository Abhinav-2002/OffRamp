import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/distracting_app.dart';

// ═════════════════════════════════════════════════════════════════════════════
// APP SELECTOR - Select distracting apps with real device apps
// Default selected: Instagram, TikTok, YouTube
// Custom switch widget with Soft Sage when on
// ═════════════════════════════════════════════════════════════════════════════

class AppSelector extends StatefulWidget {
  final VoidCallback onComplete;

  const AppSelector({
    super.key,
    required this.onComplete,
  });

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  List<DistractingApp> _apps = [];
  List<Map<String, dynamic>> _installedApps = [];
  bool _isLoading = true;
  bool _showCustomApps = false;

  static const platform = MethodChannel('com.offramp/apps');

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);

    // Load saved apps from Hive
    final savedApps = HiveService().getDistractingApps();

    if (savedApps.isNotEmpty) {
      setState(() {
        _apps = savedApps;
        _isLoading = false;
      });
    } else {
      // Initialize with defaults
      final defaults = DistractingApp.getDefaultApps();
      for (final app in defaults) {
        await HiveService().saveDistractingApp(app);
      }
      setState(() {
        _apps = defaults;
        _isLoading = false;
      });
    }

    // Try to fetch real installed apps from native
    await _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final result = await platform.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result != null && mounted) {
        setState(() {
          _installedApps = result.cast<Map<String, dynamic>>();
        });

        // Merge with known distracting apps
        await _mergeInstalledApps();
      }
    } catch (e) {
      // Platform not available, use defaults
    }
  }

  Future<void> _mergeInstalledApps() async {
    final knownPackages = _apps.map((a) => a.packageName).toSet();

    for (final installed in _installedApps) {
      final packageName = installed['packageName'] as String;
      final appName = installed['appName'] as String;

      // Check if it's a known distracting app type
      if (_isDistractingApp(packageName) && !knownPackages.contains(packageName)) {
        final newApp = DistractingApp(
          packageName: packageName,
          appName: appName,
          isSelected: false,
        );
        await HiveService().saveDistractingApp(newApp);
        _apps.add(newApp);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool _isDistractingApp(String packageName) {
    final distractingPatterns = [
      'instagram',
      'tiktok',
      'youtube',
      'twitter',
      'reddit',
      'facebook',
      'snapchat',
      'netflix',
      'twitch',
      'pinterest',
      'linkedin',
      'telegram',
      'discord',
      'whatsapp',
    ];

    final lowerPackage = packageName.toLowerCase();
    return distractingPatterns.any((pattern) => lowerPackage.contains(pattern));
  }

  Future<void> _toggleApp(String packageName) async {
    await HiveService().toggleAppSelection(packageName);
    setState(() {
      final app = _apps.firstWhere((a) => a.packageName == packageName);
      app.isSelected = !app.isSelected;
    });
  }

  Future<void> _addCustomApp() async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text(
          'Add Custom App',
          style: AppText.title.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          style: AppText.body.copyWith(color: AppColors.creamWhite),
          decoration: AppInputDecoration.textField(
            hint: 'Enter app package name (e.g., com.example.app)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppText.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              'Add',
              style: AppText.bodyMedium.copyWith(color: AppColors.softSage),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final customApp = DistractingApp(
        packageName: result,
        appName: result.split('.').last,
        isSelected: true,
      );
      await HiveService().saveDistractingApp(customApp);
      setState(() => _apps.add(customApp));
    }
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
                  // Mascot with stop sign
                  MascotWidget(
                    state: MascotState.stop,
                    size: 120,
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Title - centered
                  Text(
                    'Which apps need friction?',
                    style: AppText.title,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.sm),

                  // Subtitle - centered
                  Text(
                    'We\'ll add a gentle pause when you open these.',
                    style: AppText.body.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // App list
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.softSage,
                          ),
                        )
                      : _buildAppList(),

                  SizedBox(height: AppSpacing.lg),

                  // Add Custom App button
                  TextButton.icon(
                    onPressed: _addCustomApp,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.softSage,
                      size: 20,
                    ),
                    label: Text(
                      'Add Custom App',
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.softSage,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Continue button
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
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: AppColors.creamWhite,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Selected count
                  Text(
                    '${_apps.where((a) => a.isSelected).length} apps selected',
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

  Widget _buildAppList() {
    return Container(
      decoration: AppDecorations.card,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: _apps.map((app) => _buildAppItem(app)).toList(),
      ),
    );
  }

  Widget _buildAppItem(DistractingApp app) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // App icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                app.appName.substring(0, 1).toUpperCase(),
                style: AppText.title.copyWith(
                  fontSize: 18,
                  color: AppColors.softSage,
                ),
              ),
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // App name
          Expanded(
            child: Text(
              app.appName,
              style: AppText.body.copyWith(color: AppColors.creamWhite),
            ),
          ),

          // Custom switch
          _buildCustomSwitch(app.isSelected, () => _toggleApp(app.packageName)),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, VoidCallback onToggle) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.softSage : AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? AppColors.softSage : AppColors.mutedGray.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: AppDurations.fast,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.creamWhite,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
