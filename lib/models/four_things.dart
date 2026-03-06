import 'package:hive/hive.dart';

part 'four_things.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// FOUR THINGS MODEL - User's daily 4 things
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 1)
class FourThings extends HiveObject {
  @HiveField(0)
  String socialConnection;

  @HiveField(1)
  String readLearn;

  @HiveField(2)
  String drinkSelfCare;

  @HiveField(3)
  String winTask;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool socialDone;

  @HiveField(7)
  bool readDone;

  @HiveField(8)
  bool drinkDone;

  @HiveField(9)
  bool winDone;

  FourThings({
    this.socialConnection = '',
    this.readLearn = '',
    this.drinkSelfCare = '',
    this.winTask = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.socialDone = false,
    this.readDone = false,
    this.drinkDone = false,
    this.winDone = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isComplete =>
      socialConnection.isNotEmpty &&
      readLearn.isNotEmpty &&
      drinkSelfCare.isNotEmpty &&
      winTask.isNotEmpty;

  int get completedCount {
    int count = 0;
    if (socialDone) count++;
    if (readDone) count++;
    if (drinkDone) count++;
    if (winDone) count++;
    return count;
  }

  double get progress => isComplete ? completedCount / 4 : 0.0;

  FourThings copyWith({
    String? socialConnection,
    String? readLearn,
    String? drinkSelfCare,
    String? winTask,
    bool? socialDone,
    bool? readDone,
    bool? drinkDone,
    bool? winDone,
  }) {
    return FourThings(
      socialConnection: socialConnection ?? this.socialConnection,
      readLearn: readLearn ?? this.readLearn,
      drinkSelfCare: drinkSelfCare ?? this.drinkSelfCare,
      winTask: winTask ?? this.winTask,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      socialDone: socialDone ?? this.socialDone,
      readDone: readDone ?? this.readDone,
      drinkDone: drinkDone ?? this.drinkDone,
      winDone: winDone ?? this.winDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'socialConnection': socialConnection,
        'readLearn': readLearn,
        'drinkSelfCare': drinkSelfCare,
        'winTask': winTask,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'socialDone': socialDone,
        'readDone': readDone,
        'drinkDone': drinkDone,
        'winDone': winDone,
      };
}
