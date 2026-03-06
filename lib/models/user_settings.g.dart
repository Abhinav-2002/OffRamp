// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'user_settings.dart';

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 5;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      userName: fields[0] as String,
      onboardingComplete: fields[1] as bool,
      winTaskDuration: fields[2] as int,
      winTaskReward: fields[3] as String,
      sleepModeTime: fields[4] as DateTime,
      wakeTime: fields[5] as DateTime,
      dndEnabled: fields[6] as bool,
      grayscaleEnabled: fields[7] as bool,
      notificationsEnabled: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.onboardingComplete)
      ..writeByte(2)
      ..write(obj.winTaskDuration)
      ..writeByte(3)
      ..write(obj.winTaskReward)
      ..writeByte(4)
      ..write(obj.sleepModeTime)
      ..writeByte(5)
      ..write(obj.wakeTime)
      ..writeByte(6)
      ..write(obj.dndEnabled)
      ..writeByte(7)
      ..write(obj.grayscaleEnabled)
      ..writeByte(8)
      ..write(obj.notificationsEnabled)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
