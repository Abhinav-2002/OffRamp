// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'user_stats.dart';

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 3;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      date: fields[0] as DateTime,
      urgesResisted: fields[1] as int,
      urgesTotal: fields[2] as int,
      winTasksCompleted: fields[3] as int,
      humanConnections: fields[4] as int,
      sleepModeActivations: fields[5] as int,
      focusMinutes: fields[6] as int,
      moodEntries: (fields[7] as List).cast<MoodEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.urgesResisted)
      ..writeByte(2)
      ..write(obj.urgesTotal)
      ..writeByte(3)
      ..write(obj.winTasksCompleted)
      ..writeByte(4)
      ..write(obj.humanConnections)
      ..writeByte(5)
      ..write(obj.sleepModeActivations)
      ..writeByte(6)
      ..write(obj.focusMinutes)
      ..writeByte(7)
      ..write(obj.moodEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 4;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      timestamp: fields[0] as DateTime,
      moodRating: fields[1] as int,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.moodRating)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
