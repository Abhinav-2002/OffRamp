import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/brain_dump.dart';
import 'package:offramp/models/user_settings.dart';

// ═════════════════════════════════════════════════════════════════════════════
// LOOP CLOSER SCREEN - Voice brain dump, one tiny step, sleep mode
// Voice input, encrypted storage, sleep mode with DND
// ═════════════════════════════════════════════════════════════════════════════

class LoopCloserScreen extends StatefulWidget {
  final VoidCallback? onSleepModeTap;

  const LoopCloserScreen({
    super.key,
    this.onSleepModeTap,
  });

  @override
  State<LoopCloserScreen> createState() => _LoopCloserScreenState();
}

class _LoopCloserScreenState extends State<LoopCloserScreen> {
  final _brainDumpController = TextEditingController();
  final _tinyStepController = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  bool _isLoading = false;
  BrainDump? _todayDump;
  DateTime? _scheduledTime;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadTodayDump();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done') setState(() => _isListening = false);
      },
    );
  }

  Future<void> _loadTodayDump() async {
    setState(() => _isLoading = true);
    _todayDump = HiveService().getTodayBrainDump();
    if (_todayDump != null) {
      _brainDumpController.text = _todayDump!.content;
      _tinyStepController.text = _todayDump!.oneTinyStep ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            setState(() {
              _brainDumpController.text = result.recognizedWords;
            });
          }
        },
        listenMode: ListenMode.dictation,
      );
    }
  }

  Future<void> _saveBrainDump() async {
    if (_brainDumpController.text.trim().isEmpty) return;

    final dump = BrainDump(
      id: _todayDump?.id,
      content: _brainDumpController.text.trim(),
      isVoiceTranscription: _isListening,
      oneTinyStep: _tinyStepController.text.trim().isNotEmpty
          ? _tinyStepController.text.trim()
          : null,
      scheduledFor: _scheduledTime,
    );

    await HiveService().saveBrainDump(dump);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Brain dump saved',
          style: TextStyle(
            fontSize: AppText.bodyMedium.fontSize,
            fontWeight: AppText.bodyMedium.fontWeight,
            color: AppColors.mutedGray,
          ),
        ),
        backgroundColor: AppColors.softSage,
      ),
    );
  }

  Future<void> _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.charcoal,
              hourMinuteTextColor: AppColors.creamWhite,
              dialHandColor: AppColors.softSage,
              dialBackgroundColor: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _scheduledTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.creamWhite),
        ),
        title: Text(
          'Loop Closer',
          style: AppText.title,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppSpacing.cardMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mascot
                Center(
                  child: MascotWidget(
                    state: MascotState.think,
                    size: 100,
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  'Brain Dump',
                  style: AppText.title,
                ),

                SizedBox(height: AppSpacing.xs),

                Text(
                  'Dump everything on your mind. Get it out so you can sleep.',
                  style: AppText.body,
                ),

                SizedBox(height: AppSpacing.md),

                // Voice input button
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleListening,
                      style: AppButtons.smallPrimary.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          _isListening ? AppColors.warmCoral : AppColors.softSage,
                        ),
                      ),
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 18,
                      ),
                      label: const Text('Voice Input'),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                // Brain dump text field
                TextField(
                  controller: _brainDumpController,
                  style: TextStyle(
                    fontSize: AppText.body.fontSize,
                    fontWeight: AppText.body.fontWeight,
                    color: AppColors.creamWhite,
                  ),
                  maxLines: 6,
                  decoration: AppInputDecoration.textField(
                    hint: 'Everything on your mind goes here...',
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // One Tiny Step section
                Text(
                  'One Tiny Step for Tomorrow',
                  style: AppText.title,
                ),

                SizedBox(height: AppSpacing.xs),

                Text(
                  'What\'s the smallest next step you can take?',
                  style: AppText.body,
                ),

                SizedBox(height: AppSpacing.md),

                TextField(
                  controller: _tinyStepController,
                  style: TextStyle(
                    fontSize: AppText.body.fontSize,
                    fontWeight: AppText.body.fontWeight,
                    color: AppColors.creamWhite,
                  ),
                  decoration: AppInputDecoration.textField(
                    hint: 'e.g., Open the document, send one email...',
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Schedule time
                InkWell(
                  onTap: _showTimePicker,
                  child: Container(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: AppDecorations.cardOutlined,
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.softSage,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          _scheduledTime != null
                              ? 'Scheduled for ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                              : 'Schedule reminder time',
                          style: AppText.body.copyWith(
                            color: _scheduledTime != null
                                ? AppColors.creamWhite
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: AppButtons.secondary,
                    onPressed: _saveBrainDump,
                    child: Text(
                      'Save Brain Dump',
                      style: AppText.button,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Sleep Mode section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mutedLavender.withOpacity(0.2),
                        AppColors.sleepBg.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onSleepModeTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            MascotWidget(
                              state: MascotState.sleep,
                              size: 80,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Ready for Sleep Mode?',
                              style: AppText.title.copyWith(fontSize: 18),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Enable Do Not Disturb, grayscale, and lock until morning',
                              style: AppText.caption,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: widget.onSleepModeTap,
                              style: AppButtons.primary,
                              icon: Icon(Icons.nightlight_round),
                              label: const Text('Activate Sleep Mode'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
