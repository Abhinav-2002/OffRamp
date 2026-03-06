import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:offramp/config/theme.dart';
import 'package:offramp/services/hive_service.dart';
import 'package:offramp/models/human_buffer.dart';

// ═════════════════════════════════════════════════════════════════════════════
// CONTACT SETUP SCREEN - Human Buffer feature
// Contact picker, preferred time, method, message templates
// ═════════════════════════════════════════════════════════════════════════════

class ContactSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const ContactSetupScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<ContactSetupScreen> createState() => _ContactSetupScreenState();
}

class _ContactSetupScreenState extends State<ContactSetupScreen> {
  List<HumanBuffer> _buffers = [];
  List<Contact> _contacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.contacts.status;
    setState(() => _hasPermission = status.isGranted);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.contacts.request();
    setState(() => _hasPermission = status.isGranted);
    if (status.isGranted) {
      _loadContacts();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _buffers = HiveService().getHumanBuffers();
    setState(() => _isLoading = false);
  }

  Future<void> _loadContacts() async {
    if (!_hasPermission) return;

    setState(() => _isLoading = true);
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
        withPhoto: false,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddContactDialog() async {
    if (!_hasPermission) {
      await _requestPermission();
      return;
    }

    if (_contacts.isEmpty) {
      await _loadContacts();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      isScrollControlled: true,
      builder: (context) => _buildContactPicker(),
    );
  }

  Widget _buildContactPicker() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          Text(
            'Select a Contact',
            style: AppText.title,
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final displayName = contact.name.displayName ?? '${contact.name.first} ${contact.name.last}'.trim();
                final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : null;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.softSage,
                    child: Text(
                      displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?',
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  title: Text(
                    displayName.isNotEmpty ? displayName : 'Unknown',
                    style: AppText.body.copyWith(color: AppColors.creamWhite),
                  ),
                  subtitle: Text(
                    phoneNumber ?? 'No phone number',
                    style: AppText.caption,
                  ),
                  onTap: () => _showBufferConfigDialog(contact),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBufferConfigDialog(Contact contact) async {
    Navigator.pop(context);

    TimeOfDay? selectedTime;
    ContactMethod selectedMethod = ContactMethod.text;
    final messageController = TextEditingController(
      text: 'Hey! Just checking in. How are you doing?',
    );
    final displayName = contact.name.displayName ?? '${contact.name.first} ${contact.name.last}'.trim();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.charcoal,
          title: Text(
            'Configure Reminder',
            style: AppText.title.copyWith(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : 'Contact',
                  style: AppText.bodyMedium,
                ),
                SizedBox(height: AppSpacing.lg),

                // Time picker
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: AppDecorations.input,
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.softSage,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          selectedTime != null
                              ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Select Time',
                          style: AppText.body.copyWith(
                            color: selectedTime != null
                                ? AppColors.creamWhite
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Method selection
                Text(
                  'Preferred Method',
                  style: AppText.caption,
                ),
                SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: ContactMethod.values.map((method) {
                    final isSelected = selectedMethod == method;
                    return ChoiceChip(
                      label: Text(
                        method == ContactMethod.call
                            ? '📞 Call'
                            : method == ContactMethod.text
                                ? '💬 Text'
                                : '🎙️ Voice',
                        style: AppText.caption.copyWith(
                          color: isSelected
                              ? AppColors.deepNavy
                              : AppColors.creamWhite,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => selectedMethod = method);
                      },
                      selectedColor: AppColors.softSage,
                      backgroundColor: AppColors.deepNavy,
                    );
                  }).toList(),
                ),

                SizedBox(height: AppSpacing.md),

                // Message template
                Text(
                  'Message Template',
                  style: AppText.caption,
                ),
                SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: messageController,
                  style: AppText.body.copyWith(color: AppColors.creamWhite),
                  maxLines: 3,
                  decoration: AppInputDecoration.textField(
                    hint: 'Your message...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppText.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: AppButtons.smallPrimary,
              onPressed: selectedTime != null
                  ? () async {
                      await _saveBuffer(
                        contact,
                        selectedTime!,
                        selectedMethod,
                        messageController.text,
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBuffer(
    Contact contact,
    TimeOfDay time,
    ContactMethod method,
    String message,
  ) async {
    final now = DateTime.now();
    final displayName = contact.name.displayName ?? '${contact.name.first} ${contact.name.last}'.trim();
    final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : null;
    final buffer = HumanBuffer(
      contactId: contact.id,
      contactName: displayName.isNotEmpty ? displayName : 'Unknown',
      contactPhone: phoneNumber,
      preferredTime: DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ),
      preferredMethod: method,
      messageTemplate: message,
    );

    await HiveService().saveHumanBuffer(buffer);
    await _loadData();
  }

  Future<void> _deleteBuffer(String contactId) async {
    await HiveService().deleteHumanBuffer(contactId);
    await _loadData();
  }

  Future<void> _recordMoodAfterContact(HumanBuffer buffer) async {
    int? selectedMood;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text(
          'How did that feel?',
          style: AppText.title.copyWith(fontSize: 18),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMoodEmoji(1, '😔', selectedMood, (m) => selectedMood = m),
            _buildMoodEmoji(2, '😐', selectedMood, (m) => selectedMood = m),
            _buildMoodEmoji(3, '🙂', selectedMood, (m) => selectedMood = m),
            _buildMoodEmoji(4, '😄', selectedMood, (m) => selectedMood = m),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Skip',
              style: AppText.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: AppButtons.smallPrimary,
            onPressed: selectedMood != null
                ? () async {
                    final stats = HiveService().getTodayStats();
                    stats.addMoodEntry(MoodEntry(moodRating: selectedMood!));
                    await HiveService().recordHumanConnection();
                    Navigator.pop(context);
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEmoji(
    int rating,
    String emoji,
    int? selected,
    Function(int) onSelect,
  ) {
    final isSelected = selected == rating;
    return GestureDetector(
      onTap: () {
        onSelect(rating);
        (context as Element).markNeedsBuild();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.softSage.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.softSage
                : AppColors.mutedGray.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
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
          'Human Buffer',
          style: AppText.title.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAddContactDialog,
            icon: Icon(Icons.add, color: AppColors.softSage),
            label: Text(
              'Add',
              style: AppText.bodyMedium.copyWith(color: AppColors.softSage),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.softSage),
              )
            : _buffers.isEmpty
                ? _buildEmptyState()
                : _buildBufferList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 48)),
          SizedBox(height: AppSpacing.lg),
          Text(
            'No reminders set',
            style: AppText.body.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(
            style: AppButtons.secondary,
            onPressed: _showAddContactDialog,
            child: const Text('Add Contact Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferList() {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _buffers.length,
      itemBuilder: (context, index) {
        final buffer = _buffers[index];
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          decoration: AppDecorations.card,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.softSage,
              child: Text(
                buffer.contactName.substring(0, 1).toUpperCase(),
                style: AppText.bodyMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            title: Text(
              buffer.contactName,
              style: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buffer.timeFormatted,
                  style: AppText.caption.copyWith(color: AppColors.softSage),
                ),
                Text(
                  buffer.methodLabel,
                  style: AppText.caption,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _recordMoodAfterContact(buffer),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.softSage,
                  ),
                  tooltip: 'Mark as contacted',
                ),
                IconButton(
                  onPressed: () => _deleteBuffer(buffer.contactId),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.warmCoral,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
