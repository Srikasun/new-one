part of 'session_bloc.dart';

/// Base state for SessionBloc
abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SessionInitial extends SessionState {
  const SessionInitial();
}

/// Loading state
class SessionLoading extends SessionState {
  const SessionLoading();
}

/// Sessions loaded successfully
class SessionsLoaded extends SessionState {
  final List<ReadingSessionModel> sessions;
  final int readingStreak;
  final double averagePagesPerSession;

  const SessionsLoaded({
    required this.sessions,
    this.readingStreak = 0,
    this.averagePagesPerSession = 0,
  });

  @override
  List<Object?> get props => [sessions, readingStreak, averagePagesPerSession];
}

/// Sessions for a specific book loaded
class BookSessionsLoaded extends SessionState {
  final List<ReadingSessionModel> sessions;
  final String bookId;

  const BookSessionsLoaded({
    required this.sessions,
    required this.bookId,
  });

  @override
  List<Object?> get props => [sessions, bookId];
}

/// Active reading session state
class ActiveSession extends SessionState {
  final ReadingSessionModel session;
  final Duration elapsedTime;

  const ActiveSession({
    required this.session,
    required this.elapsedTime,
  });

  /// Calculate pages per hour based on elapsed time and pages read
  double get pagesPerHour {
    if (elapsedTime.inMinutes == 0) return 0;
    return (session.pagesRead / elapsedTime.inMinutes) * 60;
  }

  @override
  List<Object?> get props => [session, elapsedTime];
}

/// Session ended state
class SessionEnded extends SessionState {
  final ReadingSessionModel session;
  final int pagesRead;
  final Duration duration;

  const SessionEnded({
    required this.session,
    required this.pagesRead,
    required this.duration,
  });

  @override
  List<Object?> get props => [session, pagesRead, duration];
}

/// Today's reading stats loaded
class TodayStatsLoaded extends SessionState {
  final int pagesReadToday;
  final Duration readingTimeToday;
  final int currentStreak;

  const TodayStatsLoaded({
    required this.pagesReadToday,
    required this.readingTimeToday,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [pagesReadToday, readingTimeToday, currentStreak];
}

/// Error state
class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
