import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/goal_local_data_source.dart';
import '../models/user_goal_model.dart';

/// Repository for UserGoal operations
abstract class GoalRepository {
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

  /// Check and update daily goals progress
  Future<void> updateDailyGoalsProgress(int pagesRead, int minutesRead);

  /// Reset daily goals at midnight
  Future<void> resetDailyGoals();
}

/// Implementation of GoalRepository
class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _localDataSource;

  GoalRepositoryImpl({required GoalLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<UserGoalModel>> getAllGoals() async {
    try {
      return await _localDataSource.getAllGoals();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<UserGoalModel>> getActiveGoals() async {
    try {
      return await _localDataSource.getActiveGoals();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<UserGoalModel?> getGoalById(String id) async {
    try {
      return await _localDataSource.getGoalById(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<UserGoalModel>> getGoalsByType(GoalType type) async {
    try {
      return await _localDataSource.getGoalsByType(type);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> addGoal(UserGoalModel goal) async {
    try {
      await _localDataSource.addGoal(goal);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateGoal(UserGoalModel goal) async {
    try {
      await _localDataSource.updateGoal(goal);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _localDataSource.deleteGoal(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateGoalProgress(String id, int currentValue) async {
    try {
      await _localDataSource.updateGoalProgress(id, currentValue);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> deactivateGoal(String id) async {
    try {
      await _localDataSource.deactivateGoal(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<UserGoalModel>> getCompletedGoals() async {
    try {
      return await _localDataSource.getCompletedGoals();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateDailyGoalsProgress(int pagesRead, int minutesRead) async {
    try {
      final activeGoals = await _localDataSource.getActiveGoals();

      for (final goal in activeGoals) {
        switch (goal.type) {
          case GoalType.dailyPages:
            await _localDataSource.updateGoalProgress(
              goal.id,
              goal.currentValue + pagesRead,
            );
            break;
          case GoalType.dailyMinutes:
            await _localDataSource.updateGoalProgress(
              goal.id,
              goal.currentValue + minutesRead,
            );
            break;
          default:
            break;
        }
      }
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> resetDailyGoals() async {
    try {
      final activeGoals = await _localDataSource.getActiveGoals();

      for (final goal in activeGoals) {
        if (goal.type == GoalType.dailyPages ||
            goal.type == GoalType.dailyMinutes) {
          final updatedGoal = goal.copyWith(currentValue: 0);
          await _localDataSource.updateGoal(updatedGoal);
        }
      }
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }
}
