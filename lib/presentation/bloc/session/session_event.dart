part of 'session_bloc.dart';

/// Base event for SessionBloc
abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all sessions
class LoadSessions extends SessionEvent {
  const LoadSessions();
}

/// Event to load sessions for a specific book
class LoadSessionsForBook extends SessionEvent {
  final String bookId;

  const LoadSessionsForBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to start a new reading session
class StartSession extends SessionEvent {
  final String bookId;
  final int startPage;

  const StartSession({
    required this.bookId,
    required this.startPage,
  });

  @override
  List<Object?> get props => [bookId, startPage];
}

/// Event to end an active reading session
class EndSession extends SessionEvent {
  final String sessionId;
  final String bookId;
  final int pagesRead;

  const EndSession({
    required this.sessionId,
    required this.bookId,
    required this.pagesRead,
  });

  @override
  List<Object?> get props => [sessionId, bookId, pagesRead];
}

/// Event to update pages read during an active session
class UpdateSessionPages extends SessionEvent {
  final String sessionId;
  final int pagesRead;

  const UpdateSessionPages({
    required this.sessionId,
    required this.pagesRead,
  });

  @override
  List<Object?> get props => [sessionId, pagesRead];
}

/// Event to delete a session
class DeleteSession extends SessionEvent {
  final String sessionId;

  const DeleteSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to load today's reading statistics
class LoadTodayStats extends SessionEvent {
  const LoadTodayStats();
}

/// Event to update session timer
class TickSession extends SessionEvent {
  final String sessionId;

  const TickSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
