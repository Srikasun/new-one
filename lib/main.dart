import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/core.dart';
import 'data/data.dart';
import 'presentation/bloc/bloc.dart';
import 'presentation/router/app_router.dart';

/// Main entry point for DreamShelf app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initializeHive();

  // Initialize repositories
  final repositories = await _initializeRepositories();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(DreamShelfApp(repositories: repositories));
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BookModelAdapter());
  Hive.registerAdapter(BookStatusAdapter());
  Hive.registerAdapter(ReadingSessionModelAdapter());
  Hive.registerAdapter(UserGoalModelAdapter());
  Hive.registerAdapter(GoalTypeAdapter());
  Hive.registerAdapter(UserPreferencesModelAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());

  // Open boxes
  await openBooksBox();
  await openSessionsBox();
  await openGoalsBox();
  await openPreferencesBox();
}

/// Initialize all repositories
Future<Repositories> _initializeRepositories() async {
  // Get boxes
  final booksBox = await openBooksBox();
  final sessionsBox = await openSessionsBox();
  final goalsBox = await openGoalsBox();
  final preferencesBox = await openPreferencesBox();

  // Create data sources
  final bookLocalDataSource = BookLocalDataSourceImpl(booksBox: booksBox);
  final sessionLocalDataSource =
      SessionLocalDataSourceImpl(sessionsBox: sessionsBox);
  final goalLocalDataSource = GoalLocalDataSourceImpl(goalsBox: goalsBox);
  final preferencesLocalDataSource =
      PreferencesLocalDataSourceImpl(preferencesBox: preferencesBox);

  // Create repositories
  return Repositories(
    bookRepository: BookRepositoryImpl(localDataSource: bookLocalDataSource),
    sessionRepository:
        SessionRepositoryImpl(localDataSource: sessionLocalDataSource),
    goalRepository: GoalRepositoryImpl(localDataSource: goalLocalDataSource),
    preferencesRepository:
        PreferencesRepositoryImpl(localDataSource: preferencesLocalDataSource),
  );
}

/// Container for all repositories
class Repositories {
  final BookRepository bookRepository;
  final SessionRepository sessionRepository;
  final GoalRepository goalRepository;
  final PreferencesRepository preferencesRepository;

  const Repositories({
    required this.bookRepository,
    required this.sessionRepository,
    required this.goalRepository,
    required this.preferencesRepository,
  });
}

/// Main application widget
class DreamShelfApp extends StatelessWidget {
  final Repositories repositories;

  const DreamShelfApp({
    super.key,
    required this.repositories,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BookRepository>.value(
          value: repositories.bookRepository,
        ),
        RepositoryProvider<SessionRepository>.value(
          value: repositories.sessionRepository,
        ),
        RepositoryProvider<GoalRepository>.value(
          value: repositories.goalRepository,
        ),
        RepositoryProvider<PreferencesRepository>.value(
          value: repositories.preferencesRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookBloc>(
            create: (context) => BookBloc(
              bookRepository: repositories.bookRepository,
            ),
          ),
          BlocProvider<AdBloc>(
            create: (context) => AdBloc(
              preferencesRepository: repositories.preferencesRepository,
            )..add(const InitializeAds()),
          ),
          BlocProvider<PurchaseBloc>(
            create: (context) => PurchaseBloc(
              preferencesRepository: repositories.preferencesRepository,
            )..add(const InitializePurchases()),
          ),
        ],
        child: const AppRoot(),
      ),
    );
  }
}

/// Root widget that handles theme switching
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
