import 'package:equatable/equatable.dart';

/// User preferences entity
class UserPreferences extends Equatable {
  final bool isPremium;
  final ThemeMode theme;
  final bool notificationsEnabled;
  final int adFrequency;
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final String? defaultCategory;
  final bool showProgressOnHome;
  final bool showGoalsOnHome;
  final DateTime? premiumExpiryDate;
  final String? purchaseId;
  final int actionsSinceLastAd;
  final bool hasCompletedOnboarding;
  final String sortBooksBy;
  final bool sortBooksAscending;

  const UserPreferences({
    this.isPremium = false,
    this.theme = ThemeMode.system,
    this.notificationsEnabled = true,
    this.adFrequency = 5,
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
    if (premiumExpiryDate == null) return true;
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  /// Check if ads should be shown
  bool get shouldShowAds => !isPremiumActive;

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

/// Theme mode enum for domain layer
enum ThemeMode {
  light,
  dark,
  system,
}
