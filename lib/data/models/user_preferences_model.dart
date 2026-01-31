import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'user_preferences_model.g.dart';

/// Enum representing the app theme mode
@HiveType(typeId: HiveConstants.appThemeModeTypeId)
enum AppThemeMode {
  @HiveField(0)
  light,

  @HiveField(1)
  dark,

  @HiveField(2)
  system,
}

/// Model representing user preferences
@HiveType(typeId: HiveConstants.userPreferencesTypeId)
class UserPreferencesModel extends Equatable {
  @HiveField(0)
  final bool isPremium;

  @HiveField(1)
  final AppThemeMode theme;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final int adFrequency;

  @HiveField(4)
  final bool dailyReminderEnabled;

  @HiveField(5)
  final int dailyReminderHour;

  @HiveField(6)
  final int dailyReminderMinute;

  @HiveField(7)
  final String? defaultCategory;

  @HiveField(8)
  final bool showProgressOnHome;

  @HiveField(9)
  final bool showGoalsOnHome;

  @HiveField(10)
  final DateTime? premiumExpiryDate;

  @HiveField(11)
  final String? purchaseId;

  @HiveField(12)
  final int actionsSinceLastAd;

  @HiveField(13)
  final bool hasCompletedOnboarding;

  @HiveField(14)
  final String sortBooksBy;

  @HiveField(15)
  final bool sortBooksAscending;

  const UserPreferencesModel({
    this.isPremium = false,
    this.theme = AppThemeMode.system,
    this.notificationsEnabled = true,
    this.adFrequency = AdConstants.defaultAdFrequency,
    this.dailyReminderEnabled = false,
    this.dailyReminderHour = 20,
    this.dailyReminderMinute = 0,
    this.defaultCategory,
    this.showProgressOnHome = true,
    this.showGoalsOnHome = true,
    this.premiumExpiryDate,
    this.purchaseId,
    this.actionsSinceLastAd = 0,
    this.hasCompletedOnboarding = false,
    this.sortBooksBy = 'dateAdded',
    this.sortBooksAscending = false,
  });

  /// Check if premium subscription is active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true; // Lifetime premium
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  /// Check if ads should be shown
  bool get shouldShowAds => !isPremiumActive;

  /// Check if ad should be shown based on frequency
  bool get shouldShowAdNow =>
      shouldShowAds && actionsSinceLastAd >= adFrequency;

  /// Create a copy with updated fields
  UserPreferencesModel copyWith({
    bool? isPremium,
    AppThemeMode? theme,
    bool? notificationsEnabled,
    int? adFrequency,
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    String? defaultCategory,
    bool? showProgressOnHome,
    bool? showGoalsOnHome,
    DateTime? premiumExpiryDate,
    String? purchaseId,
    int? actionsSinceLastAd,
    bool? hasCompletedOnboarding,
    String? sortBooksBy,
    bool? sortBooksAscending,
  }) {
    return UserPreferencesModel(
      isPremium: isPremium ?? this.isPremium,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      adFrequency: adFrequency ?? this.adFrequency,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      showProgressOnHome: showProgressOnHome ?? this.showProgressOnHome,
      showGoalsOnHome: showGoalsOnHome ?? this.showGoalsOnHome,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      purchaseId: purchaseId ?? this.purchaseId,
      actionsSinceLastAd: actionsSinceLastAd ?? this.actionsSinceLastAd,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      sortBooksBy: sortBooksBy ?? this.sortBooksBy,
      sortBooksAscending: sortBooksAscending ?? this.sortBooksAscending,
    );
  }

  /// Create from JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      isPremium: json['isPremium'] as bool? ?? false,
      theme: AppThemeMode.values[json['theme'] as int? ?? 2],
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      adFrequency: json['adFrequency'] as int? ?? AdConstants.defaultAdFrequency,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
      dailyReminderHour: json['dailyReminderHour'] as int? ?? 20,
      dailyReminderMinute: json['dailyReminderMinute'] as int? ?? 0,
      defaultCategory: json['defaultCategory'] as String?,
      showProgressOnHome: json['showProgressOnHome'] as bool? ?? true,
      showGoalsOnHome: json['showGoalsOnHome'] as bool? ?? true,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'] as String)
          : null,
      purchaseId: json['purchaseId'] as String?,
      actionsSinceLastAd: json['actionsSinceLastAd'] as int? ?? 0,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      sortBooksBy: json['sortBooksBy'] as String? ?? 'dateAdded',
      sortBooksAscending: json['sortBooksAscending'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'theme': theme.index,
      'notificationsEnabled': notificationsEnabled,
      'adFrequency': adFrequency,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderHour': dailyReminderHour,
      'dailyReminderMinute': dailyReminderMinute,
      'defaultCategory': defaultCategory,
      'showProgressOnHome': showProgressOnHome,
      'showGoalsOnHome': showGoalsOnHome,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'purchaseId': purchaseId,
      'actionsSinceLastAd': actionsSinceLastAd,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'sortBooksBy': sortBooksBy,
      'sortBooksAscending': sortBooksAscending,
    };
  }

  /// Default preferences instance
  static const UserPreferencesModel defaultPreferences = UserPreferencesModel();

  @override
  List<Object?> get props => [
        isPremium,
        theme,
        notificationsEnabled,
        adFrequency,
        dailyReminderEnabled,
        dailyReminderHour,
        dailyReminderMinute,
        defaultCategory,
        showProgressOnHome,
        showGoalsOnHome,
        premiumExpiryDate,
        purchaseId,
        actionsSinceLastAd,
        hasCompletedOnboarding,
        sortBooksBy,
        sortBooksAscending,
      ];
}
