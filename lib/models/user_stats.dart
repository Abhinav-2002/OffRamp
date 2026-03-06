import 'package:hive/hive.dart';

part 'user_stats.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// USER STATS MODEL - Daily statistics tracking
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 3)
class UserStats extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int urgesResisted;

  @HiveField(2)
  int urgesTotal;

  @HiveField(3)
  int winTasksCompleted;

  @HiveField(4)
  int humanConnections;

  @HiveField(5)
  int sleepModeActivations;

  @HiveField(6)
  int focusMinutes;

  @HiveField(7)
  List<MoodEntry> moodEntries;

  UserStats({
    DateTime? date,
    this.urgesResisted = 0,
    this.urgesTotal = 0,
    this.winTasksCompleted = 0,
    this.humanConnections = 0,
    this.sleepModeActivations = 0,
    this.focusMinutes = 0,
    List<MoodEntry>? moodEntries,
  })  : date = date ?? DateTime.now(),
        moodEntries = moodEntries ?? [];

  double get resistanceRate => urgesTotal > 0 ? urgesResisted / urgesTotal : 0.0;

  void recordUrge({bool resisted = false}) {
    urgesTotal++;
    if (resisted) urgesResisted++;
    save();
  }

  void recordWinTask() {
    winTasksCompleted++;
    save();
  }

  void recordHumanConnection() {
    humanConnections++;
    save();
  }

  void recordSleepMode() {
    sleepModeActivations++;
    save();
  }

  void addFocusMinutes(int minutes) {
    focusMinutes += minutes;
    save();
  }

  void addMoodEntry(MoodEntry entry) {
    moodEntries.add(entry);
    save();
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'urgesResisted': urgesResisted,
        'urgesTotal': urgesTotal,
        'winTasksCompleted': winTasksCompleted,
        'humanConnections': humanConnections,
        'sleepModeActivations': sleepModeActivations,
        'focusMinutes': focusMinutes,
        'moodEntries': moodEntries.map((e) => e.toJson()).toList(),
      };
}

@HiveType(typeId: 4)
class MoodEntry extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  int moodRating; // 1-4 (😔 😐 🙂 😄)

  @HiveField(2)
  String? note;

  MoodEntry({
    DateTime? timestamp,
    required this.moodRating,
    this.note,
  }) : timestamp = timestamp ?? DateTime.now();

  String get emoji {
    switch (moodRating) {
      case 1:
        return '😔';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😄';
      default:
        return '😐';
    }
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'moodRating': moodRating,
        'note': note,
      };
}
