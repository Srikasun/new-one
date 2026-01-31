import 'package:equatable/equatable.dart';

/// User goal entity representing a reading goal
class UserGoal extends Equatable {
  final String id;
  final ReadingGoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime? deadline;
  final DateTime createdAt;
  final bool isActive;
  final String? bookId;
  final String? title;

  const UserGoal({
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

/// Enum representing the type of reading goal
enum ReadingGoalType {
  dailyPages,
  dailyMinutes,
  weeklyBooks,
  monthlyBooks,
  yearlyBooks,
  finishBook,
  readingStreak,
}

/// Extension for ReadingGoalType
extension ReadingGoalTypeExtension on ReadingGoalType {
  String get displayName {
    switch (this) {
      case ReadingGoalType.dailyPages:
        return 'Daily Pages';
      case ReadingGoalType.dailyMinutes:
        return 'Daily Reading Time';
      case ReadingGoalType.weeklyBooks:
        return 'Weekly Books';
      case ReadingGoalType.monthlyBooks:
        return 'Monthly Books';
      case ReadingGoalType.yearlyBooks:
        return 'Yearly Books';
      case ReadingGoalType.finishBook:
        return 'Finish Book';
      case ReadingGoalType.readingStreak:
        return 'Reading Streak';
    }
  }

  String get unit {
    switch (this) {
      case ReadingGoalType.dailyPages:
        return 'pages';
      case ReadingGoalType.dailyMinutes:
        return 'minutes';
      case ReadingGoalType.weeklyBooks:
      case ReadingGoalType.monthlyBooks:
      case ReadingGoalType.yearlyBooks:
      case ReadingGoalType.finishBook:
        return 'books';
      case ReadingGoalType.readingStreak:
        return 'days';
    }
  }
}
