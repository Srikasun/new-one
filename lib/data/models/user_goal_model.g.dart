// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserGoalModelAdapter extends TypeAdapter<UserGoalModel> {
  @override
  final int typeId = HiveConstants.userGoalTypeId;

  @override
  UserGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserGoalModel(
      id: fields[0] as String,
      type: fields[1] as GoalType,
      targetValue: fields[2] as int,
      currentValue: fields[3] as int,
      deadline: fields[4] as DateTime?,
      createdAt: fields[5] as DateTime,
      isActive: fields[6] as bool,
      bookId: fields[7] as String?,
      title: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserGoalModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.targetValue)
      ..writeByte(3)
      ..write(obj.currentValue)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.bookId)
      ..writeByte(8)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = HiveConstants.goalTypeTypeId;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.dailyPages;
      case 1:
        return GoalType.dailyMinutes;
      case 2:
        return GoalType.weeklyBooks;
      case 3:
        return GoalType.monthlyBooks;
      case 4:
        return GoalType.yearlyBooks;
      case 5:
        return GoalType.finishBook;
      case 6:
        return GoalType.readingStreak;
      default:
        return GoalType.dailyPages;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.dailyPages:
        writer.writeByte(0);
        break;
      case GoalType.dailyMinutes:
        writer.writeByte(1);
        break;
      case GoalType.weeklyBooks:
        writer.writeByte(2);
        break;
      case GoalType.monthlyBooks:
        writer.writeByte(3);
        break;
      case GoalType.yearlyBooks:
        writer.writeByte(4);
        break;
      case GoalType.finishBook:
        writer.writeByte(5);
        break;
      case GoalType.readingStreak:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
