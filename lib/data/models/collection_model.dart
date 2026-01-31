import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'collection_model.g.dart';

/// Model representing a book collection (premium feature)
@HiveType(typeId: HiveConstants.collectionTypeId)
class CollectionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> bookIds;

  @HiveField(4)
  final String? coverColor;

  @HiveField(5)
  final String? iconName;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool isSystem; // For system collections like "Favorites"

  const CollectionModel({
    required this.id,
    required this.name,
    this.description,
    this.bookIds = const [],
    this.coverColor,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.isSystem = false,
  });

  /// Get book count
  int get bookCount => bookIds.length;

  /// Create a copy with updated fields
  CollectionModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? bookIds,
    String? coverColor,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bookIds: bookIds ?? this.bookIds,
      coverColor: coverColor ?? this.coverColor,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  /// Add a book to the collection
  CollectionModel addBook(String bookId) {
    if (bookIds.contains(bookId)) return this;
    return copyWith(
      bookIds: [...bookIds, bookId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a book from the collection
  CollectionModel removeBook(String bookId) {
    return copyWith(
      bookIds: bookIds.where((id) => id != bookId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if collection contains a book
  bool containsBook(String bookId) => bookIds.contains(bookId);

  /// Create from JSON
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      bookIds: (json['bookIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      coverColor: json['coverColor'] as String?,
      iconName: json['iconName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bookIds': bookIds,
      'coverColor': coverColor,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSystem': isSystem,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        bookIds,
        coverColor,
        iconName,
        createdAt,
        updatedAt,
        isSystem,
      ];
}
