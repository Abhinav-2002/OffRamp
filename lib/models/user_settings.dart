import 'package:hive/hive.dart';

part 'user_settings.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// USER SETTINGS MODEL - App preferences and configuration
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 5)
class UserSettings extends HiveObject {
  @HiveField(0)
  String userName;

  @HiveField(1)
  bool onboardingComplete;

  @HiveField(2)
  int winTaskDuration; // minutes, default 50

  @HiveField(3)
  String winTaskReward;

  @HiveField(4)
  DateTime sleepModeTime; // default 21:00 (9 PM)

  @HiveField(5)
  DateTime wakeTime; // default 07:00 (7 AM)

  @HiveField(6)
  bool dndEnabled;

  @HiveField(7)
  bool grayscaleEnabled;

  @HiveField(8)
  bool notificationsEnabled;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  UserSettings({
    this.userName = '',
    this.onboardingComplete = false,
    this.winTaskDuration = 50,
    this.winTaskReward = '',
    DateTime? sleepModeTime,
    DateTime? wakeTime,
    this.dndEnabled = true,
    this.grayscaleEnabled = true,
    this.notificationsEnabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : sleepModeTime = sleepModeTime ?? _defaultSleepTime(),
        wakeTime = wakeTime ?? _defaultWakeTime(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static DateTime _defaultSleepTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 21, 0);
  }

  static DateTime _defaultWakeTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 7, 0);
  }

  String get sleepTimeFormatted {
    final hour = sleepModeTime.hour;
    final minute = sleepModeTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get wakeTimeFormatted {
    final hour = wakeTime.hour;
    final minute = wakeTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  UserSettings copyWith({
    String? userName,
    bool? onboardingComplete,
    int? winTaskDuration,
    String? winTaskReward,
    DateTime? sleepModeTime,
    DateTime? wakeTime,
    bool? dndEnabled,
    bool? grayscaleEnabled,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      winTaskDuration: winTaskDuration ?? this.winTaskDuration,
      winTaskReward: winTaskReward ?? this.winTaskReward,
      sleepModeTime: sleepModeTime ?? this.sleepModeTime,
      wakeTime: wakeTime ?? this.wakeTime,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      grayscaleEnabled: grayscaleEnabled ?? this.grayscaleEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'onboardingComplete': onboardingComplete,
        'winTaskDuration': winTaskDuration,
        'winTaskReward': winTaskReward,
        'sleepModeTime': sleepModeTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'dndEnabled': dndEnabled,
        'grayscaleEnabled': grayscaleEnabled,
        'notificationsEnabled': notificationsEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
