import 'package:equatable/equatable.dart';

/// Book entity representing a book in the user's library
/// This is the domain layer representation of a book
class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final int totalPages;
  final int currentPage;
  final BookReadingStatus status;
  final DateTime dateAdded;
  final DateTime? dateStarted;
  final DateTime? dateFinished;
  final double? rating;
  final String? notes;
  final List<String> categories;
  final String? publisher;
  final int? publishYear;
  final String? description;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    required this.totalPages,
    this.currentPage = 0,
    this.status = BookReadingStatus.toRead,
    required this.dateAdded,
    this.dateStarted,
    this.dateFinished,
    this.rating,
    this.notes,
    this.categories = const [],
    this.publisher,
    this.publishYear,
    this.description,
  });

  /// Calculate reading progress as a percentage
  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  /// Check if book is finished
  bool get isFinished => status == BookReadingStatus.completed;

  /// Get remaining pages
  int get remainingPages => totalPages - currentPage;

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        isbn,
        coverUrl,
        totalPages,
        currentPage,
        status,
        dateAdded,
        dateStarted,
        dateFinished,
        rating,
        notes,
        categories,
        publisher,
        publishYear,
        description,
      ];
}

/// Enum representing the reading status of a book
enum BookReadingStatus {
  toRead,
  reading,
  completed,
  abandoned,
}

/// Extension to get display name for BookReadingStatus
extension BookReadingStatusExtension on BookReadingStatus {
  String get displayName {
    switch (this) {
      case BookReadingStatus.toRead:
        return 'To Read';
      case BookReadingStatus.reading:
        return 'Reading';
      case BookReadingStatus.completed:
        return 'Completed';
      case BookReadingStatus.abandoned:
        return 'Abandoned';
    }
  }
}
