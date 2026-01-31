import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/reading_session_model.dart';
import '../../../data/repositories/session_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

/// BLoC for managing reading sessions
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _sessionRepository;
  static const _uuid = Uuid();
  Timer? _autoSaveTimer;
  Timer? _sessionTimer;

  SessionBloc({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository,
        super(const SessionInitial()) {
    on<LoadSessions>(_onLoadSessions);
    on<LoadSessionsForBook>(_onLoadSessionsForBook);
    on<StartSession>(_onStartSession);
    on<EndSession>(_onEndSession);
    on<UpdateSessionPages>(_onUpdateSessionPages);
    on<DeleteSession>(_onDeleteSession);
    on<LoadTodayStats>(_onLoadTodayStats);
    on<TickSession>(_onTickSession);
  }

  Future<void> _onLoadSessions(
    LoadSessions event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final sessions = await _sessionRepository.getAllSessions();
      final streak = await _sessionRepository.getReadingStreak();
      final avgPages = await _sessionRepository.getAveragePagesPerSession();

      emit(SessionsLoaded(
        sessions: sessions,
        readingStreak: streak,
        averagePagesPerSession: avgPages,
      ));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onLoadSessionsForBook(
    LoadSessionsForBook event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final sessions = await _sessionRepository.getSessionsForBook(event.bookId);
      emit(BookSessionsLoaded(sessions: sessions, bookId: event.bookId));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionState> emit,
  ) async {
    try {
      final session = ReadingSessionModel(
        id: _uuid.v4(),
        bookId: event.bookId,
        startTime: DateTime.now(),
        pagesRead: 0,
        startPage: event.startPage,
        endPage: event.startPage,
      );

      await _sessionRepository.addSession(session);

      // Start auto-save timer (every 5 minutes)
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => add(UpdateSessionPages(
          sessionId: session.id,
          pagesRead: 0,
        )),
      );

      // Start session timer for UI updates
      _sessionTimer?.cancel();
      _sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(TickSession(session.id)),
      );

      emit(ActiveSession(
        session: session,
        elapsedTime: Duration.zero,
      ));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onEndSession(
    EndSession event,
    Emitter<SessionState> emit,
  ) async {
    try {
      _autoSaveTimer?.cancel();
      _sessionTimer?.cancel();

      final sessions = await _sessionRepository.getSessionsForBook(event.bookId);
      final currentSession = sessions.firstWhere(
        (s) => s.id == event.sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      final updatedSession = currentSession.copyWith(
        endTime: DateTime.now(),
        pagesRead: event.pagesRead,
        endPage: currentSession.startPage + event.pagesRead,
      );

      await _sessionRepository.updateSession(updatedSession);

      emit(SessionEnded(
        session: updatedSession,
        pagesRead: event.pagesRead,
        duration: updatedSession.duration ?? Duration.zero,
      ));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onUpdateSessionPages(
    UpdateSessionPages event,
    Emitter<SessionState> emit,
  ) async {
    try {
      if (state is ActiveSession) {
        final activeState = state as ActiveSession;
        final updatedSession = activeState.session.copyWith(
          pagesRead: event.pagesRead,
          endPage: activeState.session.startPage + event.pagesRead,
        );
        await _sessionRepository.updateSession(updatedSession);

        emit(ActiveSession(
          session: updatedSession,
          elapsedTime: activeState.elapsedTime,
        ));
      }
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onDeleteSession(
    DeleteSession event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _sessionRepository.deleteSession(event.sessionId);
      add(const LoadSessions());
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onLoadTodayStats(
    LoadTodayStats event,
    Emitter<SessionState> emit,
  ) async {
    try {
      final pagesRead = await _sessionRepository.getTotalPagesReadToday();
      final readingTime = await _sessionRepository.getTotalReadingTimeToday();
      final streak = await _sessionRepository.getReadingStreak();

      emit(TodayStatsLoaded(
        pagesReadToday: pagesRead,
        readingTimeToday: readingTime,
        currentStreak: streak,
      ));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  void _onTickSession(
    TickSession event,
    Emitter<SessionState> emit,
  ) {
    if (state is ActiveSession) {
      final activeState = state as ActiveSession;
      if (activeState.session.id == event.sessionId) {
        final elapsed = DateTime.now().difference(activeState.session.startTime);
        emit(ActiveSession(
          session: activeState.session,
          elapsedTime: elapsed,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    _sessionTimer?.cancel();
    return super.close();
  }
}
