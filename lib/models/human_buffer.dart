import 'package:hive/hive.dart';

part 'human_buffer.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// HUMAN BUFFER MODEL - Contact reminders for human connection
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 6)
class HumanBuffer extends HiveObject {
  @HiveField(0)
  String contactId;

  @HiveField(1)
  String contactName;

  @HiveField(2)
  String? contactPhone;

  @HiveField(3)
  DateTime preferredTime;

  @HiveField(4)
  ContactMethod preferredMethod;

  @HiveField(5)
  String messageTemplate;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime lastContacted;

  HumanBuffer({
    required this.contactId,
    required this.contactName,
    this.contactPhone,
    required this.preferredTime,
    this.preferredMethod = ContactMethod.text,
    this.messageTemplate = 'Hey! Just checking in. How are you doing?',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? lastContacted,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastContacted = lastContacted ?? DateTime.now();

  String get methodLabel {
    switch (preferredMethod) {
      case ContactMethod.call:
        return '📞 Call';
      case ContactMethod.text:
        return '💬 Text';
      case ContactMethod.voiceNote:
        return '🎙️ Voice Note';
    }
  }

  String get timeFormatted {
    final hour = preferredTime.hour;
    final minute = preferredTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Map<String, dynamic> toJson() => {
        'contactId': contactId,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'preferredTime': preferredTime.toIso8601String(),
        'preferredMethod': preferredMethod.index,
        'messageTemplate': messageTemplate,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'lastContacted': lastContacted.toIso8601String(),
      };
}

@HiveType(typeId: 7)
enum ContactMethod {
  @HiveField(0)
  call,
  @HiveField(1)
  text,
  @HiveField(2)
  voiceNote,
}
