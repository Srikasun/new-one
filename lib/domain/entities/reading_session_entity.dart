import 'package:equatable/equatable.dart';

/// Reading session entity representing a reading session
class ReadingSession extends Equatable {
  final String id;
  final String bookId;
  final DateTime startTime;
  final DateTime? endTime;
  final int pagesRead;
  final int startPage;
  final int endPage;
  final String? notes;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    this.endTime,
    required this.pagesRead,
    required this.startPage,
    required this.endPage,
    this.notes,
  });

  /// Calculate duration of the session
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Check if session is ongoing
  bool get isOngoing => endTime == null;

  @override
  List<Object?> get props => [
        id,
        bookId,
        startTime,
        endTime,
        pagesRead,
        startPage,
        endPage,
        notes,
      ];
}
