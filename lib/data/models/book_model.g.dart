// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookModelAdapter extends TypeAdapter<BookModel> {
  @override
  final int typeId = HiveConstants.bookTypeId;

  @override
  BookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookModel(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      isbn: fields[3] as String?,
      coverUrl: fields[4] as String?,
      totalPages: fields[5] as int,
      currentPage: fields[6] as int,
      status: fields[7] as BookStatus,
      dateAdded: fields[8] as DateTime,
      dateStarted: fields[9] as DateTime?,
      dateFinished: fields[10] as DateTime?,
      rating: fields[11] as double?,
      notes: fields[12] as String?,
      categories: (fields[13] as List).cast<String>(),
      publisher: fields[14] as String?,
      publishYear: fields[15] as int?,
      description: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BookModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.isbn)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.totalPages)
      ..writeByte(6)
      ..write(obj.currentPage)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.dateAdded)
      ..writeByte(9)
      ..write(obj.dateStarted)
      ..writeByte(10)
      ..write(obj.dateFinished)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.categories)
      ..writeByte(14)
      ..write(obj.publisher)
      ..writeByte(15)
      ..write(obj.publishYear)
      ..writeByte(16)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookStatusAdapter extends TypeAdapter<BookStatus> {
  @override
  final int typeId = HiveConstants.bookStatusTypeId;

  @override
  BookStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookStatus.toRead;
      case 1:
        return BookStatus.reading;
      case 2:
        return BookStatus.completed;
      case 3:
        return BookStatus.abandoned;
      default:
        return BookStatus.toRead;
    }
  }

  @override
  void write(BinaryWriter writer, BookStatus obj) {
    switch (obj) {
      case BookStatus.toRead:
        writer.writeByte(0);
        break;
      case BookStatus.reading:
        writer.writeByte(1);
        break;
      case BookStatus.completed:
        writer.writeByte(2);
        break;
      case BookStatus.abandoned:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
