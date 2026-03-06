// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'four_things.dart';

class FourThingsAdapter extends TypeAdapter<FourThings> {
  @override
  final int typeId = 1;

  @override
  FourThings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FourThings(
      socialConnection: fields[0] as String,
      readLearn: fields[1] as String,
      drinkSelfCare: fields[2] as String,
      winTask: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      socialDone: fields[6] as bool,
      readDone: fields[7] as bool,
      drinkDone: fields[8] as bool,
      winDone: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FourThings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.socialConnection)
      ..writeByte(1)
      ..write(obj.readLearn)
      ..writeByte(2)
      ..write(obj.drinkSelfCare)
      ..writeByte(3)
      ..write(obj.winTask)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.socialDone)
      ..writeByte(7)
      ..write(obj.readDone)
      ..writeByte(8)
      ..write(obj.drinkDone)
      ..writeByte(9)
      ..write(obj.winDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FourThingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
