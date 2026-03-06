// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'brain_dump.dart';

class BrainDumpAdapter extends TypeAdapter<BrainDump> {
  @override
  final int typeId = 8;

  @override
  BrainDump read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrainDump(
      id: fields[0] as String,
      content: fields[1] as String,
      isVoiceTranscription: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      oneTinyStep: fields[4] as String?,
      scheduledFor: fields[5] as DateTime?,
      isArchived: fields[6] as bool,
      archivedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BrainDump obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isVoiceTranscription)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.oneTinyStep)
      ..writeByte(5)
      ..write(obj.scheduledFor)
      ..writeByte(6)
      ..write(obj.isArchived)
      ..writeByte(7)
      ..write(obj.archivedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrainDumpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
