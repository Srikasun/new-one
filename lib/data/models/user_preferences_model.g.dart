// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = HiveConstants.userPreferencesTypeId;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      isPremium: fields[0] as bool,
      theme: fields[1] as AppThemeMode,
      notificationsEnabled: fields[2] as bool,
      adFrequency: fields[3] as int,
      dailyReminderEnabled: fields[4] as bool,
      dailyReminderHour: fields[5] as int,
      dailyReminderMinute: fields[6] as int,
      defaultCategory: fields[7] as String?,
      showProgressOnHome: fields[8] as bool,
      showGoalsOnHome: fields[9] as bool,
      premiumExpiryDate: fields[10] as DateTime?,
      purchaseId: fields[11] as String?,
      actionsSinceLastAd: fields[12] as int,
      hasCompletedOnboarding: fields[13] as bool,
      sortBooksBy: fields[14] as String,
      sortBooksAscending: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.isPremium)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.adFrequency)
      ..writeByte(4)
      ..write(obj.dailyReminderEnabled)
      ..writeByte(5)
      ..write(obj.dailyReminderHour)
      ..writeByte(6)
      ..write(obj.dailyReminderMinute)
      ..writeByte(7)
      ..write(obj.defaultCategory)
      ..writeByte(8)
      ..write(obj.showProgressOnHome)
      ..writeByte(9)
      ..write(obj.showGoalsOnHome)
      ..writeByte(10)
      ..write(obj.premiumExpiryDate)
      ..writeByte(11)
      ..write(obj.purchaseId)
      ..writeByte(12)
      ..write(obj.actionsSinceLastAd)
      ..writeByte(13)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(14)
      ..write(obj.sortBooksBy)
      ..writeByte(15)
      ..write(obj.sortBooksAscending);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = HiveConstants.appThemeModeTypeId;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.dark;
      case 2:
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.light:
        writer.writeByte(0);
        break;
      case AppThemeMode.dark:
        writer.writeByte(1);
        break;
      case AppThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
