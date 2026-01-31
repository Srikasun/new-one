import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/session_local_data_source.dart';
import '../models/reading_session_model.dart';

/// Repository for ReadingSession operations
abstract class SessionRepository {
  /// Get all sessions
  Future<List<ReadingSessionModel>> getAllSessions();

  /// Get sessions for a specific book
  Future<List<ReadingSessionModel>> getSessionsForBook(String bookId);

  /// Get sessions within a date range
  Future<List<ReadingSessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  );

  /// Get sessions for today
  Future<List<ReadingSessionModel>> getTodaySessions();

  /// Add a new session
  Future<void> addSession(ReadingSessionModel session);

  /// Update a session
  Future<void> updateSession(ReadingSessionModel session);

  /// Delete a session
  Future<void> deleteSession(String id);

  /// Delete all sessions for a book
  Future<void> deleteSessionsForBook(String bookId);

  /// Get total pages read today
  Future<int> getTotalPagesReadToday();

  /// Get total reading time today
  Future<Duration> getTotalReadingTimeToday();

  /// Get reading streak (consecutive days with reading sessions)
  Future<int> getReadingStreak();

  /// Get average pages per session
  Future<double> getAveragePagesPerSession();

  /// Get sessions grouped by date
  Future<Map<DateTime, List<ReadingSessionModel>>> getSessionsGroupedByDate();
}

/// Implementation of SessionRepository
class SessionRepositoryImpl implements SessionRepository {
  final SessionLocalDataSource _localDataSource;

  SessionRepositoryImpl({required SessionLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<ReadingSessionModel>> getAllSessions() async {
    try {
      return await _localDataSource.getAllSessions();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsForBook(String bookId) async {
    try {
      return await _localDataSource.getSessionsForBook(bookId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _localDataSource.getSessionsInRange(start, end);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<ReadingSessionModel>> getTodaySessions() async {
    try {
      return await _localDataSource.getTodaySessions();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> addSession(ReadingSessionModel session) async {
    try {
      await _localDataSource.addSession(session);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateSession(ReadingSessionModel session) async {
    try {
      await _localDataSource.updateSession(session);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await _localDataSource.deleteSession(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> deleteSessionsForBook(String bookId) async {
    try {
      await _localDataSource.deleteSessionsForBook(bookId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<int> getTotalPagesReadToday() async {
    try {
      return await _localDataSource.getTotalPagesReadToday();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<Duration> getTotalReadingTimeToday() async {
    try {
      return await _localDataSource.getTotalReadingTimeToday();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<int> getReadingStreak() async {
    try {
      final allSessions = await _localDataSource.getAllSessions();
      if (allSessions.isEmpty) return 0;

      // Group sessions by date
      final sessionDates = <DateTime>{};
      for (final session in allSessions) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        sessionDates.add(date);
      }

      // Count consecutive days
      int streak = 0;
      DateTime checkDate = DateTime.now();
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

      while (sessionDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      return streak;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<double> getAveragePagesPerSession() async {
    try {
      final allSessions = await _localDataSource.getAllSessions();
      if (allSessions.isEmpty) return 0.0;

      final totalPages =
          allSessions.fold<int>(0, (sum, session) => sum + session.pagesRead);
      return totalPages / allSessions.length;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<Map<DateTime, List<ReadingSessionModel>>>
      getSessionsGroupedByDate() async {
    try {
      final allSessions = await _localDataSource.getAllSessions();
      final grouped = <DateTime, List<ReadingSessionModel>>{};

      for (final session in allSessions) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );

        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(session);
      }

      return grouped;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }
}
