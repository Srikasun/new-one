import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/reading_session_model.dart';

/// Local data source for ReadingSession operations using Hive
abstract class SessionLocalDataSource {
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
}

/// Implementation of SessionLocalDataSource using Hive
class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  final Box<ReadingSessionModel> _sessionsBox;

  SessionLocalDataSourceImpl({required Box<ReadingSessionModel> sessionsBox})
      : _sessionsBox = sessionsBox;

  @override
  Future<List<ReadingSessionModel>> getAllSessions() async {
    try {
      return _sessionsBox.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get all sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsForBook(String bookId) async {
    try {
      return _sessionsBox.values
          .where((session) => session.bookId == bookId)
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get sessions for book',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return _sessionsBox.values.where((session) {
        return session.startTime.isAfter(start) &&
            session.startTime.isBefore(end);
      }).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get sessions in range',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReadingSessionModel>> getTodaySessions() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return getSessionsInRange(startOfDay, endOfDay);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get today sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<void> addSession(ReadingSessionModel session) async {
    try {
      await _sessionsBox.put(session.id, session);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to add session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateSession(ReadingSessionModel session) async {
    try {
      await _sessionsBox.put(session.id, session);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await _sessionsBox.delete(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteSessionsForBook(String bookId) async {
    try {
      final sessionsToDelete = _sessionsBox.values
          .where((session) => session.bookId == bookId)
          .map((session) => session.id)
          .toList();

      await _sessionsBox.deleteAll(sessionsToDelete);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete sessions for book',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTotalPagesReadToday() async {
    try {
      final todaySessions = await getTodaySessions();
      return todaySessions.fold<int>(
        0,
        (sum, session) => sum + session.pagesRead,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total pages read today',
        originalException: e,
      );
    }
  }

  @override
  Future<Duration> getTotalReadingTimeToday() async {
    try {
      final todaySessions = await getTodaySessions();
      final totalMinutes = todaySessions.fold<int>(0, (sum, session) {
        final duration = session.duration;
        if (duration != null) {
          return sum + duration.inMinutes;
        }
        return sum;
      });
      return Duration(minutes: totalMinutes);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total reading time today',
        originalException: e,
      );
    }
  }
}

/// Factory to get sessions box
Future<Box<ReadingSessionModel>> openSessionsBox() async {
  if (!Hive.isBoxOpen(HiveConstants.sessionsBox)) {
    return await Hive.openBox<ReadingSessionModel>(HiveConstants.sessionsBox);
  }
  return Hive.box<ReadingSessionModel>(HiveConstants.sessionsBox);
}
