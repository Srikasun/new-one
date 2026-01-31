import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/achievement_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/session_repository.dart';

/// Achievements screen showing badges and progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<AchievementModel> _achievements = [];
  int _unlockedCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final bookRepo = context.read<BookRepository>();
      final sessionRepo = context.read<SessionRepository>();

      // Get current stats
      final allBooks = await bookRepo.getAllBooks();
      final completedBooks = allBooks.where((b) => b.isFinished).length;
      final totalPagesRead = await bookRepo.getTotalPagesRead();
      final streak = await sessionRepo.getReadingStreak();

      // Get unique genres
      final genres = <String>{};
      for (final book in allBooks.where((b) => b.isFinished)) {
        genres.addAll(book.categories);
      }

      // Update achievements based on current stats
      final achievements = PredefinedAchievements.all.map((achievement) {
        int currentValue = 0;
        bool isUnlocked = false;

        switch (achievement.type) {
          case AchievementType.booksRead:
            currentValue = completedBooks;
            break;
          case AchievementType.pagesRead:
            currentValue = totalPagesRead;
            break;
          case AchievementType.readingStreak:
          case AchievementType.consistent:
            currentValue = streak;
            break;
          case AchievementType.genreExplorer:
            currentValue = genres.length;
            break;
          case AchievementType.collector:
            currentValue = allBooks.length;
            break;
          case AchievementType.reviewer:
            currentValue = allBooks.where((b) => b.rating != null).length;
            break;
          default:
            currentValue = 0;
        }

        isUnlocked = currentValue >= achievement.targetValue;

        return achievement.copyWith(
          currentValue: currentValue,
          isUnlocked: isUnlocked,
          unlockedAt: isUnlocked ? DateTime.now() : null,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _unlockedCount = achievements.where((a) => a.isUnlocked).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AchievementModel> get _unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<AchievementModel> get _inProgressAchievements =>
      _achievements.where((a) => !a.isUnlocked && a.currentValue > 0).toList();

  List<AchievementModel> get _lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked && a.currentValue == 0).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Unlocked ($_unlockedCount)'),
            Tab(text: 'In Progress (${_inProgressAchievements.length})'),
            const Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats header
                _buildStatsHeader(),
                // Achievements list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementsList(_unlockedAchievements),
                      _buildAchievementsList(_inProgressAchievements),
                      _buildAchievementsList(_achievements),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    final totalPoints = _unlockedAchievements.fold<int>(
      0,
      (sum, a) => sum + (a.level * 100),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_unlockedCount / ${_achievements.length}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Achievements Unlocked',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _achievements.isEmpty
                      ? 0
                      : _unlockedCount / _achievements.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Points
          Column(
            children: [
              Text(
                '$totalPoints',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text(
                'Points',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<AchievementModel> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep reading to unlock achievements!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral500,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return _AchievementCard(
            achievement: achievements[index],
          );
        },
      ),
    );
  }
}

/// Achievement card widget
class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final levelColor = Color(
      int.parse(achievement.levelColorHex.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Badge icon
            _buildBadge(levelColor),
            const SizedBox(width: 16),
            // Achievement info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: achievement.isUnlocked
                                        ? null
                                        : AppColors.neutral500,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          achievement.levelName,
                          style: TextStyle(
                            color: levelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  if (!achievement.isUnlocked) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: achievement.progress,
                              backgroundColor: AppColors.neutral200,
                              valueColor: AlwaysStoppedAnimation(levelColor),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${achievement.currentValue}/${achievement.targetValue}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: achievement.isUnlocked
            ? LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: achievement.isUnlocked ? null : AppColors.neutral200,
        shape: BoxShape.circle,
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        _getIconData(achievement.type.iconName),
        color: achievement.isUnlocked ? Colors.white : AppColors.neutral400,
        size: 28,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'explore':
        return Icons.explore;
      case 'speed':
        return Icons.speed;
      case 'collections_bookmark':
        return Icons.collections_bookmark;
      case 'rate_review':
        return Icons.rate_review;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'timer':
        return Icons.timer;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.star;
    }
  }
}
