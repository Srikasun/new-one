import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'user_goal_model.g.dart';

/// Enum representing the type of reading goal
@HiveType(typeId: HiveConstants.goalTypeTypeId)
enum GoalType {
  @HiveField(0)
  dailyPages, // Read X pages per day

  @HiveField(1)
  dailyMinutes, // Read X minutes per day

  @HiveField(2)
  weeklyBooks, // Finish X books per week

  @HiveField(3)
  monthlyBooks, // Finish X books per month

  @HiveField(4)
  yearlyBooks, // Finish X books per year

  @HiveField(5)
  finishBook, // Finish a specific book by date

  @HiveField(6)
  readingStreak, // Maintain X day reading streak
}

/// Extension to get display name and description for GoalType
extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.dailyPages:
        return 'Daily Pages';
      case GoalType.dailyMinutes:
        return 'Daily Reading Time';
      case GoalType.weeklyBooks:
        return 'Weekly Books';
      case GoalType.monthlyBooks:
        return 'Monthly Books';
      case GoalType.yearlyBooks:
        return 'Yearly Books';
      case GoalType.finishBook:
        return 'Finish Book';
      case GoalType.readingStreak:
        return 'Reading Streak';
    }
  }

  String get unit {
    switch (this) {
      case GoalType.dailyPages:
        return 'pages';
      case GoalType.dailyMinutes:
        return 'minutes';
      case GoalType.weeklyBooks:
      case GoalType.monthlyBooks:
      case GoalType.yearlyBooks:
      case GoalType.finishBook:
        return 'books';
      case GoalType.readingStreak:
        return 'days';
    }
  }
}

/// Model representing a user's reading goal
@HiveType(typeId: HiveConstants.userGoalTypeId)
class UserGoalModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final GoalType type;

  @HiveField(2)
  final int targetValue;

  @HiveField(3)
  final int currentValue;

  @HiveField(4)
  final DateTime? deadline;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final String? bookId; // For finishBook goal type

  @HiveField(8)
  final String? title; // Custom goal title

  const UserGoalModel({
    required this.id,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.deadline,
    required this.createdAt,
    this.isActive = true,
    this.bookId,
    this.title,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Check if goal is completed
  bool get isCompleted => currentValue >= targetValue;

  /// Check if goal is overdue
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  /// Get remaining value to reach target
  int get remainingValue => (targetValue - currentValue).clamp(0, targetValue);

  /// Get days until deadline
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Create a copy with updated fields
  UserGoalModel copyWith({
    String? id,
    GoalType? type,
    int? targetValue,
    int? currentValue,
    DateTime? deadline,
    DateTime? createdAt,
    bool? isActive,
    String? bookId,
    String? title,
  }) {
    return UserGoalModel(
      id: id ?? this.id,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
    );
  }

  /// Create from JSON
  factory UserGoalModel.fromJson(Map<String, dynamic> json) {
    return UserGoalModel(
      id: json['id'] as String,
      type: GoalType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      bookId: json['bookId'] as String?,
      title: json['title'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'bookId': bookId,
      'title': title,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        targetValue,
        currentValue,
        deadline,
        createdAt,
        isActive,
        bookId,
        title,
      ];
}
