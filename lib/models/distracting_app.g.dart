// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'distracting_app.dart';

class DistractingAppAdapter extends TypeAdapter<DistractingApp> {
  @override
  final int typeId = 2;

  @override
  DistractingApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DistractingApp(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      isSelected: fields[2] as bool,
      addedAt: fields[3] as DateTime,
      urgeCount: fields[4] as int,
      resistedCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DistractingApp obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.isSelected)
      ..writeByte(3)
      ..write(obj.addedAt)
      ..writeByte(4)
      ..write(obj.urgeCount)
      ..writeByte(5)
      ..write(obj.resistedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistractingAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
