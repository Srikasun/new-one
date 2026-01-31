import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'book_model.g.dart';

/// Enum representing the reading status of a book
@HiveType(typeId: HiveConstants.bookStatusTypeId)
enum BookStatus {
  @HiveField(0)
  toRead,

  @HiveField(1)
  reading,

  @HiveField(2)
  completed,

  @HiveField(3)
  abandoned,
}

/// Extension to get display name for BookStatus
extension BookStatusExtension on BookStatus {
  String get displayName {
    switch (this) {
      case BookStatus.toRead:
        return 'To Read';
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.abandoned:
        return 'Abandoned';
    }
  }
}

/// Book model representing a book in the user's library
@HiveType(typeId: HiveConstants.bookTypeId)
class BookModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String? isbn;

  @HiveField(4)
  final String? coverUrl;

  @HiveField(5)
  final int totalPages;

  @HiveField(6)
  final int currentPage;

  @HiveField(7)
  final BookStatus status;

  @HiveField(8)
  final DateTime dateAdded;

  @HiveField(9)
  final DateTime? dateStarted;

  @HiveField(10)
  final DateTime? dateFinished;

  @HiveField(11)
  final double? rating;

  @HiveField(12)
  final String? notes;

  @HiveField(13)
  final List<String> categories;

  @HiveField(14)
  final String? publisher;

  @HiveField(15)
  final int? publishYear;

  @HiveField(16)
  final String? description;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    required this.totalPages,
    this.currentPage = 0,
    this.status = BookStatus.toRead,
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
  bool get isFinished => status == BookStatus.completed;

  /// Get remaining pages
  int get remainingPages => totalPages - currentPage;

  /// Create a copy with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    int? totalPages,
    int? currentPage,
    BookStatus? status,
    DateTime? dateAdded,
    DateTime? dateStarted,
    DateTime? dateFinished,
    double? rating,
    String? notes,
    List<String>? categories,
    String? publisher,
    int? publishYear,
    String? description,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      dateStarted: dateStarted ?? this.dateStarted,
      dateFinished: dateFinished ?? this.dateFinished,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      categories: categories ?? this.categories,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      description: description ?? this.description,
    );
  }

  /// Create from JSON (for API responses)
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String?,
      coverUrl: json['coverUrl'] as String?,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int? ?? 0,
      status: BookStatus.values[json['status'] as int? ?? 0],
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      dateStarted: json['dateStarted'] != null
          ? DateTime.parse(json['dateStarted'] as String)
          : null,
      dateFinished: json['dateFinished'] != null
          ? DateTime.parse(json['dateFinished'] as String)
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      publisher: json['publisher'] as String?,
      publishYear: json['publishYear'] as int?,
      description: json['description'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status.index,
      'dateAdded': dateAdded.toIso8601String(),
      'dateStarted': dateStarted?.toIso8601String(),
      'dateFinished': dateFinished?.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'categories': categories,
      'publisher': publisher,
      'publishYear': publishYear,
      'description': description,
    };
  }

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
