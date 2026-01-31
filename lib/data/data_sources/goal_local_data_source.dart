import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_goal_model.dart';

/// Local data source for UserGoal operations using Hive
abstract class GoalLocalDataSource {
  /// Get all goals
  Future<List<UserGoalModel>> getAllGoals();

  /// Get active goals
  Future<List<UserGoalModel>> getActiveGoals();

  /// Get goal by ID
  Future<UserGoalModel?> getGoalById(String id);

  /// Get goals by type
  Future<List<UserGoalModel>> getGoalsByType(GoalType type);

  /// Add a new goal
  Future<void> addGoal(UserGoalModel goal);

  /// Update a goal
  Future<void> updateGoal(UserGoalModel goal);

  /// Delete a goal
  Future<void> deleteGoal(String id);

  /// Update goal progress
  Future<void> updateGoalProgress(String id, int currentValue);

  /// Deactivate a goal
  Future<void> deactivateGoal(String id);

  /// Get completed goals
  Future<List<UserGoalModel>> getCompletedGoals();
}

/// Implementation of GoalLocalDataSource using Hive
class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final Box<UserGoalModel> _goalsBox;

  GoalLocalDataSourceImpl({required Box<UserGoalModel> goalsBox})
      : _goalsBox = goalsBox;

  @override
  Future<List<UserGoalModel>> getAllGoals() async {
    try {
      return _goalsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get all goals',
        originalException: e,
      );
    }
  }

  @override
  Future<List<UserGoalModel>> getActiveGoals() async {
    try {
      return _goalsBox.values
          .where((goal) => goal.isActive && !goal.isCompleted)
          .toList()
        ..sort((a, b) {
          // Sort by deadline (goals with deadline first, then by date)
          if (a.deadline != null && b.deadline != null) {
            return a.deadline!.compareTo(b.deadline!);
          } else if (a.deadline != null) {
            return -1;
          } else if (b.deadline != null) {
            return 1;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get active goals',
        originalException: e,
      );
    }
  }

  @override
  Future<UserGoalModel?> getGoalById(String id) async {
    try {
      return _goalsBox.get(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get goal by ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<UserGoalModel>> getGoalsByType(GoalType type) async {
    try {
      return _goalsBox.values.where((goal) => goal.type == type).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get goals by type',
        originalException: e,
      );
    }
  }

  @override
  Future<void> addGoal(UserGoalModel goal) async {
    try {
      await _goalsBox.put(goal.id, goal);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to add goal',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateGoal(UserGoalModel goal) async {
    try {
      await _goalsBox.put(goal.id, goal);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update goal',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _goalsBox.delete(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete goal',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateGoalProgress(String id, int currentValue) async {
    try {
      final goal = _goalsBox.get(id);
      if (goal == null) {
        throw const DatabaseException(
          message: 'Goal not found',
          code: 'NOT_FOUND',
        );
      }

      final updatedGoal = goal.copyWith(currentValue: currentValue);
      await _goalsBox.put(id, updatedGoal);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update goal progress',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deactivateGoal(String id) async {
    try {
      final goal = _goalsBox.get(id);
      if (goal == null) {
        throw const DatabaseException(
          message: 'Goal not found',
          code: 'NOT_FOUND',
        );
      }

      final updatedGoal = goal.copyWith(isActive: false);
      await _goalsBox.put(id, updatedGoal);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to deactivate goal',
        originalException: e,
      );
    }
  }

  @override
  Future<List<UserGoalModel>> getCompletedGoals() async {
    try {
      return _goalsBox.values.where((goal) => goal.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get completed goals',
        originalException: e,
      );
    }
  }
}

/// Factory to get goals box
Future<Box<UserGoalModel>> openGoalsBox() async {
  if (!Hive.isBoxOpen(HiveConstants.goalsBox)) {
    return await Hive.openBox<UserGoalModel>(HiveConstants.goalsBox);
  }
  return Hive.box<UserGoalModel>(HiveConstants.goalsBox);
}
