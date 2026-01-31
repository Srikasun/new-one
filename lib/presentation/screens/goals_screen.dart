import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/user_goal_model.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/session_repository.dart';

/// Goals screen for managing reading goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isLoading = true;
  List<UserGoalModel> _goals = [];
  int _booksThisYear = 0;
  int _pagesThisWeek = 0;
  int _pagesThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      final goalRepo = context.read<GoalRepository>();
      final bookRepo = context.read<BookRepository>();
      final sessionRepo = context.read<SessionRepository>();

      final goals = await goalRepo.getAllGoals();
      
      // Calculate progress for yearly book goal
      final thisYear = DateTime.now().year;
      final allBooks = await bookRepo.getAllBooks();
      final booksThisYear = allBooks.where((b) =>
          b.dateFinished != null && b.dateFinished!.year == thisYear).length;

      // Get pages this week
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekSessions = await sessionRepo.getSessionsInRange(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        now,
      );
      final pagesThisWeek = weekSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);

      // Get pages this month
      final startOfMonth = DateTime(now.year, now.month, 1);
      final monthSessions = await sessionRepo.getSessionsInRange(startOfMonth, now);
      final pagesThisMonth = monthSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);

      if (mounted) {
        setState(() {
          _goals = goals;
          _booksThisYear = booksThisYear;
          _pagesThisWeek = pagesThisWeek;
          _pagesThisMonth = pagesThisMonth;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Goals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // Active goals
                    _buildActiveGoals(),
                    const SizedBox(height: 24),

                    // Create new goal
                    _buildCreateGoalSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                title: 'Books This Year',
                current: _booksThisYear,
                target: AppConstants.defaultYearlyBooksGoal,
                icon: Icons.auto_stories,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Pages This Week',
                value: '$_pagesThisWeek',
                icon: Icons.calendar_view_week,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                label: 'Pages This Month',
                value: '$_pagesThisMonth',
                icon: Icons.calendar_month,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveGoals() {
    final activeGoals = _goals.where((g) => g.isActive && !g.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Goals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (activeGoals.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Show all goals
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeGoals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a goal to track your reading progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddGoalDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Goal'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeGoals.length,
            itemBuilder: (context, index) {
              return _GoalCard(
                goal: activeGoals[index],
                onDelete: () => _deleteGoal(activeGoals[index]),
                onUpdate: () => _updateGoalProgress(activeGoals[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCreateGoalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested Goals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _SuggestedGoalItem(
              title: 'Read 12 books this year',
              subtitle: 'One book per month',
              icon: Icons.auto_stories,
              onTap: () => _createQuickGoal(GoalType.yearlyBooks, 12, 'Read 12 books this year'),
            ),
            const Divider(),
            _SuggestedGoalItem(
              title: 'Read 30 pages daily',
              subtitle: 'Build a consistent habit',
              icon: Icons.menu_book,
              onTap: () => _createQuickGoal(GoalType.dailyPages, 30, 'Read 30 pages daily'),
            ),
            const Divider(),
            _SuggestedGoalItem(
              title: 'Maintain 7 day streak',
              subtitle: 'Read every day for a week',
              icon: Icons.local_fire_department,
              onTap: () => _createQuickGoal(GoalType.readingStreak, 7, 'Maintain 7 day streak'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    GoalType selectedType = GoalType.dailyPages;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  hintText: 'e.g., Read 30 pages daily',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target',
                  hintText: 'e.g., 30',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Goal Type',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GoalType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final target = int.tryParse(targetController.text) ?? 0;
                  if (titleController.text.isNotEmpty && target > 0) {
                    _createGoal(titleController.text, selectedType, target);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createGoal(String title, GoalType type, int target) async {
    final goalRepo = context.read<GoalRepository>();
    final goal = UserGoalModel(
      id: const Uuid().v4(),
      title: title,
      type: type,
      targetValue: target,
      currentValue: 0,
      createdAt: DateTime.now(),
      deadline: _calculateDeadline(type),
      isActive: true,
    );

    await goalRepo.addGoal(goal);
    _loadGoals();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _createQuickGoal(GoalType type, int target, String title) async {
    await _createGoal(title, type, target);
  }

  DateTime? _calculateDeadline(GoalType type) {
    final now = DateTime.now();
    switch (type) {
      case GoalType.dailyPages:
      case GoalType.dailyMinutes:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case GoalType.weeklyBooks:
        return now.add(Duration(days: 7 - now.weekday));
      case GoalType.monthlyBooks:
        return DateTime(now.year, now.month + 1, 0);
      case GoalType.yearlyBooks:
        return DateTime(now.year, 12, 31);
      case GoalType.finishBook:
      case GoalType.readingStreak:
        return null; // No specific deadline
    }
  }

  Future<void> _deleteGoal(UserGoalModel goal) async {
    final goalRepo = context.read<GoalRepository>();
    await goalRepo.deleteGoal(goal.id);
    _loadGoals();
  }

  Future<void> _updateGoalProgress(UserGoalModel goal) async {
    final controller = TextEditingController(text: goal.currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Current Progress',
            hintText: 'Max: ${goal.targetValue}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text) ?? 0;
              final updatedGoal = goal.copyWith(currentValue: value);
              final goalRepo = context.read<GoalRepository>();
              await goalRepo.updateGoal(updatedGoal);
              Navigator.pop(context);
              _loadGoals();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

/// Progress card with circular indicator
class _ProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.current,
    required this.target,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Icon(icon, color: color),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$current of $target',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini stat card
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Goal card widget
class _GoalCard extends StatelessWidget {
  final UserGoalModel goal;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _GoalCard({
    required this.goal,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage;
    final dateFormat = DateFormat('MMM dd');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title ?? goal.type.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'update') {
                      onUpdate();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'update',
                      child: Text('Update Progress'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.neutral200,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentValue} / ${goal.targetValue} ${goal.type.unit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (goal.deadline != null)
                  Text(
                    'Due: ${dateFormat.format(goal.deadline!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Suggested goal item
class _SuggestedGoalItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestedGoalItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: onTap,
    );
  }
}
