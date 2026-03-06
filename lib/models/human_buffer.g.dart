// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'human_buffer.dart';

class HumanBufferAdapter extends TypeAdapter<HumanBuffer> {
  @override
  final int typeId = 6;

  @override
  HumanBuffer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HumanBuffer(
      contactId: fields[0] as String,
      contactName: fields[1] as String,
      contactPhone: fields[2] as String?,
      preferredTime: fields[3] as DateTime,
      preferredMethod: fields[4] as ContactMethod,
      messageTemplate: fields[5] as String,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      lastContacted: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HumanBuffer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.contactId)
      ..writeByte(1)
      ..write(obj.contactName)
      ..writeByte(2)
      ..write(obj.contactPhone)
      ..writeByte(3)
      ..write(obj.preferredTime)
      ..writeByte(4)
      ..write(obj.preferredMethod)
      ..writeByte(5)
      ..write(obj.messageTemplate)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastContacted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HumanBufferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContactMethodAdapter extends TypeAdapter<ContactMethod> {
  @override
  final int typeId = 7;

  @override
  ContactMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContactMethod.call;
      case 1:
        return ContactMethod.text;
      case 2:
        return ContactMethod.voiceNote;
      default:
        return ContactMethod.text;
    }
  }

  @override
  void write(BinaryWriter writer, ContactMethod obj) {
    switch (obj) {
      case ContactMethod.call:
        writer.writeByte(0);
        break;
      case ContactMethod.text:
        writer.writeByte(1);
        break;
      case ContactMethod.voiceNote:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
