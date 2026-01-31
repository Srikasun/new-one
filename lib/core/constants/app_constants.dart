/// App-wide constants for DreamShelf
library;

/// API Configuration
class ApiConstants {
  ApiConstants._();

  /// Base URL for Open Library API (free book data)
  static const String openLibraryBaseUrl = 'https://openlibrary.org';

  /// Google Books API base URL
  static const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1';

  /// API Key placeholder - Replace with actual key
  static const String googleBooksApiKey = 'YOUR_GOOGLE_BOOKS_API_KEY';

  /// API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Ad Unit IDs for Google Mobile Ads
class AdConstants {
  AdConstants._();

  // Android Ad Unit IDs
  static const String androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidNativeId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // iOS Ad Unit IDs
  static const String iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String iosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String iosNativeId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Test Ad Unit IDs (for development)
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';

  /// Default ad frequency (show ad every N actions)
  static const int defaultAdFrequency = 5;
}

/// In-App Purchase Product IDs
class PurchaseConstants {
  PurchaseConstants._();

  /// Premium subscription product ID
  static const String premiumMonthlyId = 'dreamshelf_premium_monthly';
  static const String premiumYearlyId = 'dreamshelf_premium_yearly';
  static const String premiumLifetimeId = 'dreamshelf_premium_lifetime';

  /// Consumable product IDs
  static const String removeAdsId = 'dreamshelf_remove_ads';

  /// List of all subscription IDs
  static const List<String> subscriptionIds = [
    premiumMonthlyId,
    premiumYearlyId,
  ];

  /// List of all non-consumable IDs
  static const List<String> nonConsumableIds = [
    premiumLifetimeId,
    removeAdsId,
  ];
}

/// Hive Box Names
class HiveConstants {
  HiveConstants._();

  static const String booksBox = 'books_box';
  static const String sessionsBox = 'reading_sessions_box';
  static const String goalsBox = 'user_goals_box';
  static const String preferencesBox = 'user_preferences_box';

  // Type Adapter IDs
  static const int bookTypeId = 0;
  static const int readingSessionTypeId = 1;
  static const int userGoalTypeId = 2;
  static const int userPreferencesTypeId = 3;
  static const int bookStatusTypeId = 4;
  static const int goalTypeTypeId = 5;
  static const int appThemeModeTypeId = 6;
}

/// App Configuration
class AppConstants {
  AppConstants._();

  static const String appName = 'DreamShelf';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  /// Default reading goal (pages per day)
  static const int defaultDailyPagesGoal = 30;

  /// Default books per year goal
  static const int defaultYearlyBooksGoal = 12;

  /// Maximum rating value
  static const double maxRating = 5.0;

  /// Cover image placeholder
  static const String defaultCoverUrl = 'assets/images/book_placeholder.png';
}

/// Route Names
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String home = '/home';
  static const String bookDetails = '/book/:id';
  static const String addBook = '/add-book';
  static const String editBook = '/edit-book/:id';
  static const String scanBook = '/scan';
  static const String statistics = '/statistics';
  static const String goals = '/goals';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String search = '/search';
}
