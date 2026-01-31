import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_preferences_model.dart';

/// Key for storing user preferences in the box
const String _preferencesKey = 'user_preferences';

/// Local data source for UserPreferences operations using Hive
abstract class PreferencesLocalDataSource {
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

  /// Increment actions since last ad
  Future<void> incrementAdCounter();

  /// Reset ad counter
  Future<void> resetAdCounter();

  /// Complete onboarding
  Future<void> completeOnboarding();

  /// Clear all preferences
  Future<void> clearPreferences();
}

/// Implementation of PreferencesLocalDataSource using Hive
class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  final Box<UserPreferencesModel> _preferencesBox;

  PreferencesLocalDataSourceImpl({
    required Box<UserPreferencesModel> preferencesBox,
  }) : _preferencesBox = preferencesBox;

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final preferences = _preferencesBox.get(_preferencesKey);
      return preferences ?? UserPreferencesModel.defaultPreferences;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get preferences',
        originalException: e,
      );
    }
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    try {
      await _preferencesBox.put(_preferencesKey, preferences);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to save preferences',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateTheme(AppThemeMode theme) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(theme: theme);
      await savePreferences(updatedPreferences);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update theme',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updatePremiumStatus({
    required bool isPremium,
    DateTime? expiryDate,
    String? purchaseId,
  }) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(
        isPremium: isPremium,
        premiumExpiryDate: expiryDate,
        purchaseId: purchaseId,
        actionsSinceLastAd: 0, // Reset ad counter when premium is updated
      );
      await savePreferences(updatedPreferences);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update premium status',
        originalException: e,
      );
    }
  }

  @override
  Future<void> incrementAdCounter() async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(
        actionsSinceLastAd: preferences.actionsSinceLastAd + 1,
      );
      await savePreferences(updatedPreferences);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to increment ad counter',
        originalException: e,
      );
    }
  }

  @override
  Future<void> resetAdCounter() async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(
        actionsSinceLastAd: 0,
      );
      await savePreferences(updatedPreferences);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to reset ad counter',
        originalException: e,
      );
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(
        hasCompletedOnboarding: true,
      );
      await savePreferences(updatedPreferences);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to complete onboarding',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearPreferences() async {
    try {
      await _preferencesBox.delete(_preferencesKey);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to clear preferences',
        originalException: e,
      );
    }
  }
}

/// Factory to get preferences box
Future<Box<UserPreferencesModel>> openPreferencesBox() async {
  if (!Hive.isBoxOpen(HiveConstants.preferencesBox)) {
    return await Hive.openBox<UserPreferencesModel>(
      HiveConstants.preferencesBox,
    );
  }
  return Hive.box<UserPreferencesModel>(HiveConstants.preferencesBox);
}
