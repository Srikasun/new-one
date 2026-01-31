// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingSessionModelAdapter extends TypeAdapter<ReadingSessionModel> {
  @override
  final int typeId = HiveConstants.readingSessionTypeId;

  @override
  ReadingSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingSessionModel(
      id: fields[0] as String,
      bookId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      pagesRead: fields[4] as int,
      startPage: fields[5] as int,
      endPage: fields[6] as int,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingSessionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.pagesRead)
      ..writeByte(5)
      ..write(obj.startPage)
      ..writeByte(6)
      ..write(obj.endPage)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
