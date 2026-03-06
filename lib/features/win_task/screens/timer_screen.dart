import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/four_things.dart';

// ═════════════════════════════════════════════════════════════════════════════
// WIN TASK TIMER - Full screen 50-minute timer with progress ring
// Confetti animation on completion, mascot celebrating
// Background service keeps timer running
// ═════════════════════════════════════════════════════════════════════════════

class WinTaskTimerScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const WinTaskTimerScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<WinTaskTimerScreen> createState() => _WinTaskTimerScreenState();
}

class _WinTaskTimerScreenState extends State<WinTaskTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  late Animation<double> _progressAnimation;

  Timer? _timer;
  int _totalSeconds = 50 * 60; // 50 minutes default
  int _remainingSeconds = 50 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  FourThings? _fourThings;
  String? _winTask;
  String? _reward;

  static const platform = MethodChannel('com.offramp/timer');

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.linear,
      ),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _loadSettings() async {
    final settings = HiveService().getSettings();
    _fourThings = HiveService().getFourThings();

    setState(() {
      _totalSeconds = (settings.winTaskDuration) * 60;
      _remainingSeconds = _totalSeconds;
      _winTask = _fourThings?.winTask ?? 'Your Win Task';
      _reward = settings.winTaskReward;
    });

    // Update animation duration
    _progressController.duration = Duration(seconds: _totalSeconds);
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeTimer();
      }
    });

    // Start background service
    _startBackgroundService();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _progressController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _stopBackgroundService();
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    final elapsed = _totalSeconds - _remainingSeconds;
    _progressController.value = elapsed / _totalSeconds;
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeTimer();
      }
    });

    _startBackgroundService();
  }

  void _completeTimer() {
    _timer?.cancel();
    _progressController.value = 1;

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Record completion
    HiveService().recordWinTask();

    // Update four things
    if (_fourThings != null) {
      final updated = _fourThings!.copyWith(winDone: true);
      HiveService().saveFourThings(updated);
    }

    // Start celebration
    _celebrationController.forward();

    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });

    _stopBackgroundService();
  }

  Future<void> _startBackgroundService() async {
    try {
      await platform.invokeMethod('startTimer', {
        'duration': _remainingSeconds,
        'taskName': _winTask,
      });
    } catch (e) {
      // Service not available
    }
  }

  Future<void> _stopBackgroundService() async {
    try {
      await platform.invokeMethod('stopTimer');
    } catch (e) {
      // Service not available
    }
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Task name
                      Text(
                        _winTask ?? 'Win Task',
                        style: AppText.title.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // Progress ring with timer
                      _buildProgressRing(),

                      SizedBox(height: AppSpacing.xl),

                      // Mascot
                      MascotWidget(
                        state: _isCompleted
                            ? MascotState.celebrate
                            : _isRunning
                                ? MascotState.focus
                                : MascotState.idle,
                        size: 100,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // Control buttons
                      if (!_isCompleted) _buildControls(),

                      // Completion UI
                      if (_isCompleted) _buildCompletionUI(),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti overlay
            if (_isCompleted) _buildConfetti(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 12,
            backgroundColor: AppColors.charcoal,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
          ),

          // Progress arc
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: 1 - _progressAnimation.value,
                strokeWidth: 12,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.softSage),
                strokeCap: StrokeCap.round,
              );
            },
          ),

          // Timer text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formattedTime,
                  style: AppText.timerDigits.copyWith(fontSize: 48),
                ),
                if (_isPaused)
                  Text(
                    'PAUSED',
                    style: AppText.caption.copyWith(color: AppColors.warmCoral),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Resume button
        FloatingActionButton.large(
          onPressed: _isRunning ? _pauseTimer : _resumeTimer,
          backgroundColor: _isRunning ? AppColors.warmCoral : AppColors.softSage,
          child: Icon(
            _isRunning ? Icons.pause : Icons.play_arrow,
            size: 32,
            color: AppColors.creamWhite,
          ),
        ),

        SizedBox(width: AppSpacing.xl),

        // Cancel button
        FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppColors.charcoal,
          mini: true,
          child: Icon(
            Icons.close,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionUI() {
    return Column(
      children: [
        Text(
          '🎉 Task Complete!',
          style: AppText.title.copyWith(color: AppColors.softSage),
        ),

        SizedBox(height: AppSpacing.md),

        if (_reward?.isNotEmpty == true) ...[
          Text(
            'Your reward:',
            style: AppText.caption,
          ),
          Text(
            _reward!,
            style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
          ),
          SizedBox(height: AppSpacing.md),
        ],

        SizedBox(
          width: 280,
          height: 56,
          child: ElevatedButton(
            style: AppButtons.secondary,
            onPressed: () {
              widget.onComplete?.call();
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: AppColors.creamWhite),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Claim Reward',
                  style: AppText.button,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ConfettiPainter(
            progress: _celebrationController.value,
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CONFETTI PAINTER - Simple confetti animation
// ═════════════════════════════════════════════════════════════════════════════

class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random random = Random();

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.softSage,
      AppColors.warmCoral,
      AppColors.mutedLavender,
      AppColors.creamWhite,
    ];

    // Draw confetti particles
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height * progress) - 50;
      final color = colors[i % colors.length];
      final particleSize = 4 + random.nextDouble() * 8;

      final paint = Paint()
        ..color = color.withOpacity(1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);

      // Draw some squares too
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
              x + random.nextDouble() * 50 - 25,
              y + random.nextDouble() * 100,
            ),
            width: particleSize,
            height: particleSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
