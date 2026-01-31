import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/book_model.dart';
import '../screens/screens.dart';

/// App router configuration using go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Home Screen
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Book Details Screen
      GoRoute(
        path: RouteNames.bookDetails,
        name: 'bookDetails',
        builder: (context, state) {
          final bookId = state.pathParameters['id'] ?? '';
          return BookDetailsScreen(bookId: bookId);
        },
      ),

      // Add Book Screen
      GoRoute(
        path: RouteNames.addBook,
        name: 'addBook',
        builder: (context, state) {
          final initialBook = state.extra as BookModel?;
          return AddBookScreen(initialBook: initialBook);
        },
      ),

      // Edit Book Screen
      GoRoute(
        path: RouteNames.editBook,
        name: 'editBook',
        builder: (context, state) {
          final bookId = state.pathParameters['id'] ?? '';
          return EditBookScreen(bookId: bookId);
        },
      ),

      // Scan Book Screen
      GoRoute(
        path: RouteNames.scanBook,
        name: 'scanBook',
        builder: (context, state) => const ScannerScreen(),
      ),

      // Statistics Screen
      GoRoute(
        path: RouteNames.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),

      // Goals Screen
      GoRoute(
        path: RouteNames.goals,
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),

      // Settings Screen
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Premium Screen
      GoRoute(
        path: RouteNames.premium,
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),

      // Search Screen
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Navigate to book details
  static void goToBookDetails(BuildContext context, String bookId) {
    context.go('/book/$bookId');
  }

  /// Navigate to edit book
  static void goToEditBook(BuildContext context, String bookId) {
    context.go('/edit-book/$bookId');
  }

  /// Navigate to home
  static void goToHome(BuildContext context) {
    context.go(RouteNames.home);
  }

  /// Navigate to add book
  static void goToAddBook(BuildContext context) {
    context.go(RouteNames.addBook);
  }

  /// Navigate to scan book
  static void goToScanBook(BuildContext context) {
    context.go(RouteNames.scanBook);
  }

  /// Navigate to statistics
  static void goToStatistics(BuildContext context) {
    context.go(RouteNames.statistics);
  }

  /// Navigate to goals
  static void goToGoals(BuildContext context) {
    context.go(RouteNames.goals);
  }

  /// Navigate to settings
  static void goToSettings(BuildContext context) {
    context.go(RouteNames.settings);
  }

  /// Navigate to premium
  static void goToPremium(BuildContext context) {
    context.go(RouteNames.premium);
  }

  /// Navigate to search
  static void goToSearch(BuildContext context) {
    context.go(RouteNames.search);
  }

  /// Go back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }
}
