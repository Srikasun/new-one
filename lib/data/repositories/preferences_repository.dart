import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/preferences_local_data_source.dart';
import '../models/user_preferences_model.dart';

/// Repository for UserPreferences operations
abstract class PreferencesRepository {
  /// Get user preferences
  Future<UserPreferencesModel> getPreferences();

  /// Save user preferences
  Future<void> savePreferences(UserPreferencesModel preferences);

  /// Update theme mode
  Future<void> updateTheme(AppThemeMode theme);

  /// Update premium status
  Future<void> updatePremiumStatus({
    required bool isPremium,
    DateTime? expiryDate,
    String? purchaseId,
  });

  /// Check if ads should be shown
  Future<bool> shouldShowAds();

  /// Increment actions since last ad
  Future<void> incrementAdCounter();

  /// Reset ad counter
  Future<void> resetAdCounter();

  /// Complete onboarding
  Future<void> completeOnboarding();

  /// Check if onboarding is completed
  Future<bool> hasCompletedOnboarding();

  /// Clear all preferences
  Future<void> clearPreferences();

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? enabled,
    int? hour,
    int? minute,
  });

  /// Update sort preferences
  Future<void> updateSortPreferences({
    String? sortBy,
    bool? ascending,
  });
}

/// Implementation of PreferencesRepository
class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource _localDataSource;

  PreferencesRepositoryImpl({
    required PreferencesLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      return await _localDataSource.getPreferences();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    try {
      await _localDataSource.savePreferences(preferences);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateTheme(AppThemeMode theme) async {
    try {
      await _localDataSource.updateTheme(theme);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updatePremiumStatus({
    required bool isPremium,
    DateTime? expiryDate,
    String? purchaseId,
  }) async {
    try {
      await _localDataSource.updatePremiumStatus(
        isPremium: isPremium,
        expiryDate: expiryDate,
        purchaseId: purchaseId,
      );
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<bool> shouldShowAds() async {
    try {
      final preferences = await _localDataSource.getPreferences();
      return preferences.shouldShowAdNow;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> incrementAdCounter() async {
    try {
      await _localDataSource.incrementAdCounter();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> resetAdCounter() async {
    try {
      await _localDataSource.resetAdCounter();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _localDataSource.completeOnboarding();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      final preferences = await _localDataSource.getPreferences();
      return preferences.hasCompletedOnboarding;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> clearPreferences() async {
    try {
      await _localDataSource.clearPreferences();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateNotificationSettings({
    bool? enabled,
    int? hour,
    int? minute,
  }) async {
    try {
      final preferences = await _localDataSource.getPreferences();
      final updatedPreferences = preferences.copyWith(
        dailyReminderEnabled: enabled ?? preferences.dailyReminderEnabled,
        dailyReminderHour: hour ?? preferences.dailyReminderHour,
        dailyReminderMinute: minute ?? preferences.dailyReminderMinute,
      );
      await _localDataSource.savePreferences(updatedPreferences);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateSortPreferences({
    String? sortBy,
    bool? ascending,
  }) async {
    try {
      final preferences = await _localDataSource.getPreferences();
      final updatedPreferences = preferences.copyWith(
        sortBooksBy: sortBy ?? preferences.sortBooksBy,
        sortBooksAscending: ascending ?? preferences.sortBooksAscending,
      );
      await _localDataSource.savePreferences(updatedPreferences);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }
}
