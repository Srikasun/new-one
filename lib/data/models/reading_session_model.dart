import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'reading_session_model.g.dart';

/// Model representing a reading session
@HiveType(typeId: HiveConstants.readingSessionTypeId)
class ReadingSessionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final int pagesRead;

  @HiveField(5)
  final int startPage;

  @HiveField(6)
  final int endPage;

  @HiveField(7)
  final String? notes;

  const ReadingSessionModel({
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

  /// Calculate pages per minute
  double? get pagesPerMinute {
    final sessionDuration = duration;
    if (sessionDuration == null || sessionDuration.inMinutes == 0) return null;
    return pagesRead / sessionDuration.inMinutes;
  }

  /// Check if session is ongoing
  bool get isOngoing => endTime == null;

  /// Create a copy with updated fields
  ReadingSessionModel copyWith({
    String? id,
    String? bookId,
    DateTime? startTime,
    DateTime? endTime,
    int? pagesRead,
    int? startPage,
    int? endPage,
    String? notes,
  }) {
    return ReadingSessionModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pagesRead: pagesRead ?? this.pagesRead,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      notes: notes ?? this.notes,
    );
  }

  /// Create from JSON
  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      pagesRead: json['pagesRead'] as int,
      startPage: json['startPage'] as int,
      endPage: json['endPage'] as int,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'pagesRead': pagesRead,
      'startPage': startPage,
      'endPage': endPage,
      'notes': notes,
    };
  }

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
