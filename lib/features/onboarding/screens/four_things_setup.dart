import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/widgets/mascot_widget.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/four_things.dart';

// ═════════════════════════════════════════════════════════════════════════════
// FOUR THINGS SETUP - 4 input fields with voice input
// 1. Social Connection (👤)
// 2. Read/Learn (📖)
// 3. Drink/Self-care (🍵)
// 4. Win Task 50min (✅)
// ═════════════════════════════════════════════════════════════════════════════

class FourThingsSetup extends StatefulWidget {
  final VoidCallback onComplete;

  const FourThingsSetup({
    super.key,
    required this.onComplete,
  });

  @override
  State<FourThingsSetup> createState() => _FourThingsSetupState();
}

class _FourThingsSetupState extends State<FourThingsSetup> {
  final _formKey = GlobalKey<FormState>();
  final _socialController = TextEditingController();
  final _readController = TextEditingController();
  final _drinkController = TextEditingController();
  final _winController = TextEditingController();

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  int? _activeField;

  final List<ThingField> _fields = [
    ThingField(
      id: 0,
      icon: '👤',
      label: 'Social Connection',
      hint: 'Who will you reach out to today?',
      controllerKey: 'social',
    ),
    ThingField(
      id: 1,
      icon: '📖',
      label: 'Read / Learn',
      hint: 'What will you read or learn?',
      controllerKey: 'read',
    ),
    ThingField(
      id: 2,
      icon: '🍵',
      label: 'Drink / Self-care',
      hint: 'How will you care for yourself?',
      controllerKey: 'drink',
    ),
    ThingField(
      id: 3,
      icon: '✅',
      label: 'Win Task (50 min)',
      hint: 'What\'s your one important task?',
      controllerKey: 'win',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadExistingData();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
    );
  }

  void _loadExistingData() {
    final existing = HiveService().getFourThings();
    if (existing != null) {
      _socialController.text = existing.socialConnection;
      _readController.text = existing.readLearn;
      _drinkController.text = existing.drinkSelfCare;
      _winController.text = existing.winTask;
    }
  }

  @override
  void dispose() {
    _socialController.dispose();
    _readController.dispose();
    _drinkController.dispose();
    _winController.dispose();
    super.dispose();
  }

  bool get _isFormComplete {
    return _socialController.text.trim().isNotEmpty &&
        _readController.text.trim().isNotEmpty &&
        _drinkController.text.trim().isNotEmpty &&
        _winController.text.trim().isNotEmpty;
  }

  TextEditingController _getController(int index) {
    switch (index) {
      case 0:
        return _socialController;
      case 1:
        return _readController;
      case 2:
        return _drinkController;
      case 3:
        return _winController;
      default:
        return _socialController;
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mascot writing
                    MascotWidget(
                      state: MascotState.write,
                      size: 120,
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // Title - centered
                    Text(
                      'Your 4 Things Today',
                      style: AppText.title,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.sm),

                    // Subtitle - centered
                    Text(
                      'Small wins that make evenings matter.',
                      style: AppText.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Input fields
                    ...List.generate(_fields.length, (index) {
                      return _buildInputField(index);
                    }),

                    SizedBox(height: AppSpacing.xxl),

                    // Save & Continue button
                    SizedBox(
                      width: 280,
                      height: 56,
                      child: ElevatedButton(
                        style: _isFormComplete
                            ? AppButtons.secondary
                            : AppButtons.tertiary,
                        onPressed: _isFormComplete ? _saveAndContinue : null,
                        child: Text(
                          'Save & Continue',
                          style: AppText.button,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Tip text
                    Text(
                      'Tap the mic to speak instead of type',
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
      ),
    );
  }

  Widget _buildInputField(int index) {
    final field = _fields[index];
    final controller = _getController(index);
    final isActive = _activeField == index;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Row(
            children: [
              Text(
                field.icon,
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                field.label,
                style: AppText.bodyMedium.copyWith(
                  color: AppColors.creamWhite,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xs),

          // Input field with voice button
          TextFormField(
            controller: controller,
            style: AppText.body.copyWith(color: AppColors.creamWhite),
            maxLength: 50,
            onChanged: (_) => setState(() {}),
            decoration: AppInputDecoration.textField(
              hint: field.hint,
              suffix: _buildVoiceButton(index),
            ).copyWith(
              counterStyle: AppText.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(int index) {
    final isListening = _isListening && _activeField == index;

    return IconButton(
      onPressed: () => _toggleListening(index),
      icon: isListening
          ? const Icon(
              Icons.mic,
              color: AppColors.warmCoral,
              size: 24,
            )
          : Icon(
              Icons.mic_none,
              color: AppColors.textMuted,
              size: 24,
            ),
      splashRadius: 20,
    );
  }

  Future<void> _toggleListening(int index) async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _activeField = null;
      });
      return;
    }

    final available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _activeField = index;
      });

      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            setState(() {
              _getController(index).text = result.recognizedWords;
            });
          }
        },
        listenMode: ListenMode.confirmation,
      );
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final fourThings = FourThings(
      socialConnection: _socialController.text.trim(),
      readLearn: _readController.text.trim(),
      drinkSelfCare: _drinkController.text.trim(),
      winTask: _winController.text.trim(),
    );

    await HiveService().saveFourThings(fourThings);
    widget.onComplete();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// THING FIELD DATA
// ═════════════════════════════════════════════════════════════════════════════

class ThingField {
  final int id;
  final String icon;
  final String label;
  final String hint;
  final String controllerKey;

  ThingField({
    required this.id,
    required this.icon,
    required this.label,
    required this.hint,
    required this.controllerKey,
  });
}
