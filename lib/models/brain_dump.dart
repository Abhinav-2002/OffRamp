import 'package:hive/hive.dart';

part 'brain_dump.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// BRAIN DUMP MODEL - Voice/text brain dumps before sleep
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 8)
class BrainDump extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  bool isVoiceTranscription;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  String? oneTinyStep; // Action item for tomorrow

  @HiveField(5)
  DateTime? scheduledFor;

  @HiveField(6)
  bool isArchived;

  @HiveField(7)
  DateTime? archivedAt;

  BrainDump({
    String? id,
    required this.content,
    this.isVoiceTranscription = false,
    DateTime? createdAt,
    this.oneTinyStep,
    this.scheduledFor,
    this.isArchived = false,
    this.archivedAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  String get formattedDate {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDay(createdAt, now)) {
      return 'Today';
    } else if (_isSameDay(createdAt, yesterday)) {
      return 'Yesterday';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void archive() {
    isArchived = true;
    archivedAt = DateTime.now();
    save();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isVoiceTranscription': isVoiceTranscription,
        'createdAt': createdAt.toIso8601String(),
        'oneTinyStep': oneTinyStep,
        'scheduledFor': scheduledFor?.toIso8601String(),
        'isArchived': isArchived,
        'archivedAt': archivedAt?.toIso8601String(),
      };
}
