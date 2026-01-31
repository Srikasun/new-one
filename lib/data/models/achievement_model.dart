import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'achievement_model.g.dart';

/// Enum representing achievement types
@HiveType(typeId: HiveConstants.achievementTypeTypeId)
enum AchievementType {
  @HiveField(0)
  booksRead, // Read X books

  @HiveField(1)
  pagesRead, // Read X pages

  @HiveField(2)
  readingStreak, // Maintain X day streak

  @HiveField(3)
  genreExplorer, // Read books from X different genres

  @HiveField(4)
  speedReader, // Finish a book in X days

  @HiveField(5)
  collector, // Add X books to library

  @HiveField(6)
  reviewer, // Rate X books

  @HiveField(7)
  goalAchiever, // Complete X goals

  @HiveField(8)
  nightOwl, // Read late at night

  @HiveField(9)
  earlyBird, // Read early in the morning

  @HiveField(10)
  marathon, // Single reading session over X hours

  @HiveField(11)
  consistent, // Read every day for a month
}

/// Extension for achievement display info
extension AchievementTypeExtension on AchievementType {
  String get displayName {
    switch (this) {
      case AchievementType.booksRead:
        return 'Bookworm';
      case AchievementType.pagesRead:
        return 'Page Turner';
      case AchievementType.readingStreak:
        return 'On Fire';
      case AchievementType.genreExplorer:
        return 'Genre Explorer';
      case AchievementType.speedReader:
        return 'Speed Reader';
      case AchievementType.collector:
        return 'Collector';
      case AchievementType.reviewer:
        return 'Critic';
      case AchievementType.goalAchiever:
        return 'Goal Getter';
      case AchievementType.nightOwl:
        return 'Night Owl';
      case AchievementType.earlyBird:
        return 'Early Bird';
      case AchievementType.marathon:
        return 'Marathon Reader';
      case AchievementType.consistent:
        return 'Consistent';
    }
  }

  String get iconName {
    switch (this) {
      case AchievementType.booksRead:
        return 'menu_book';
      case AchievementType.pagesRead:
        return 'auto_stories';
      case AchievementType.readingStreak:
        return 'local_fire_department';
      case AchievementType.genreExplorer:
        return 'explore';
      case AchievementType.speedReader:
        return 'speed';
      case AchievementType.collector:
        return 'collections_bookmark';
      case AchievementType.reviewer:
        return 'rate_review';
      case AchievementType.goalAchiever:
        return 'emoji_events';
      case AchievementType.nightOwl:
        return 'dark_mode';
      case AchievementType.earlyBird:
        return 'wb_sunny';
      case AchievementType.marathon:
        return 'timer';
      case AchievementType.consistent:
        return 'calendar_today';
    }
  }
}

/// Model representing an achievement badge
@HiveType(typeId: HiveConstants.achievementTypeId)
class AchievementModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final AchievementType type;

  @HiveField(2)
  final int level; // Bronze = 1, Silver = 2, Gold = 3

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final int targetValue;

  @HiveField(6)
  final int currentValue;

  @HiveField(7)
  final DateTime? unlockedAt;

  @HiveField(8)
  final bool isUnlocked;

  const AchievementModel({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  /// Get progress percentage
  double get progress {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get level name
  String get levelName {
    switch (level) {
      case 1:
        return 'Bronze';
      case 2:
        return 'Silver';
      case 3:
        return 'Gold';
      default:
        return 'Bronze';
    }
  }

  /// Get level color hex
  String get levelColorHex {
    switch (level) {
      case 1:
        return '#CD7F32'; // Bronze
      case 2:
        return '#C0C0C0'; // Silver
      case 3:
        return '#FFD700'; // Gold
      default:
        return '#CD7F32';
    }
  }

  /// Create a copy with updated fields
  AchievementModel copyWith({
    String? id,
    AchievementType? type,
    int? level,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  /// Create from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      type: AchievementType.values[json['type'] as int],
      level: json['level'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'level': level,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        level,
        title,
        description,
        targetValue,
        currentValue,
        unlockedAt,
        isUnlocked,
      ];
}

/// Predefined achievements
class PredefinedAchievements {
  PredefinedAchievements._();

  static List<AchievementModel> get all => [
        // Books Read achievements
        const AchievementModel(
          id: 'books_read_bronze',
          type: AchievementType.booksRead,
          level: 1,
          title: 'Bookworm Bronze',
          description: 'Read your first 5 books',
          targetValue: 5,
        ),
        const AchievementModel(
          id: 'books_read_silver',
          type: AchievementType.booksRead,
          level: 2,
          title: 'Bookworm Silver',
          description: 'Read 25 books',
          targetValue: 25,
        ),
        const AchievementModel(
          id: 'books_read_gold',
          type: AchievementType.booksRead,
          level: 3,
          title: 'Bookworm Gold',
          description: 'Read 100 books',
          targetValue: 100,
        ),

        // Reading Streak achievements
        const AchievementModel(
          id: 'streak_bronze',
          type: AchievementType.readingStreak,
          level: 1,
          title: 'On Fire Bronze',
          description: 'Maintain a 7-day reading streak',
          targetValue: 7,
        ),
        const AchievementModel(
          id: 'streak_silver',
          type: AchievementType.readingStreak,
          level: 2,
          title: 'On Fire Silver',
          description: 'Maintain a 30-day reading streak',
          targetValue: 30,
        ),
        const AchievementModel(
          id: 'streak_gold',
          type: AchievementType.readingStreak,
          level: 3,
          title: 'On Fire Gold',
          description: 'Maintain a 100-day reading streak',
          targetValue: 100,
        ),

        // Pages Read achievements
        const AchievementModel(
          id: 'pages_bronze',
          type: AchievementType.pagesRead,
          level: 1,
          title: 'Page Turner Bronze',
          description: 'Read 1,000 pages',
          targetValue: 1000,
        ),
        const AchievementModel(
          id: 'pages_silver',
          type: AchievementType.pagesRead,
          level: 2,
          title: 'Page Turner Silver',
          description: 'Read 10,000 pages',
          targetValue: 10000,
        ),
        const AchievementModel(
          id: 'pages_gold',
          type: AchievementType.pagesRead,
          level: 3,
          title: 'Page Turner Gold',
          description: 'Read 50,000 pages',
          targetValue: 50000,
        ),

        // Genre Explorer achievements
        const AchievementModel(
          id: 'genre_bronze',
          type: AchievementType.genreExplorer,
          level: 1,
          title: 'Genre Explorer Bronze',
          description: 'Read books from 3 different genres',
          targetValue: 3,
        ),
        const AchievementModel(
          id: 'genre_silver',
          type: AchievementType.genreExplorer,
          level: 2,
          title: 'Genre Explorer Silver',
          description: 'Read books from 7 different genres',
          targetValue: 7,
        ),
        const AchievementModel(
          id: 'genre_gold',
          type: AchievementType.genreExplorer,
          level: 3,
          title: 'Genre Explorer Gold',
          description: 'Read books from 15 different genres',
          targetValue: 15,
        ),

        // Goal Achiever
        const AchievementModel(
          id: 'goals_bronze',
          type: AchievementType.goalAchiever,
          level: 1,
          title: 'Goal Getter Bronze',
          description: 'Complete your first reading goal',
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'goals_silver',
          type: AchievementType.goalAchiever,
          level: 2,
          title: 'Goal Getter Silver',
          description: 'Complete 10 reading goals',
          targetValue: 10,
        ),
        const AchievementModel(
          id: 'goals_gold',
          type: AchievementType.goalAchiever,
          level: 3,
          title: 'Goal Getter Gold',
          description: 'Complete 50 reading goals',
          targetValue: 50,
        ),

        // Consistent Reader
        const AchievementModel(
          id: 'consistent_bronze',
          type: AchievementType.consistent,
          level: 1,
          title: 'Consistent Bronze',
          description: 'Read every day for a week',
          targetValue: 7,
        ),
        const AchievementModel(
          id: 'consistent_silver',
          type: AchievementType.consistent,
          level: 2,
          title: 'Consistent Silver',
          description: 'Read every day for a month',
          targetValue: 30,
        ),
        const AchievementModel(
          id: 'consistent_gold',
          type: AchievementType.consistent,
          level: 3,
          title: 'Consistent Gold',
          description: 'Read every day for 3 months',
          targetValue: 90,
        ),
      ];
}
