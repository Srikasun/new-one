import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/session_repository.dart';

/// Statistics screen showing reading analytics
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;

  // Stats data
  int _totalBooks = 0;
  int _booksCompleted = 0;
  int _booksReading = 0;
  int _totalPagesRead = 0;
  int _readingStreak = 0;
  double _avgPagesPerSession = 0;
  Duration _totalReadingTime = Duration.zero;
  List<BookModel> _recentlyCompleted = [];
  Map<String, int> _booksByStatus = {};
  Map<String, int> _booksByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final bookRepo = context.read<BookRepository>();
      final sessionRepo = context.read<SessionRepository>();

      // Load book stats
      final allBooks = await bookRepo.getAllBooks();
      final completedBooks = await bookRepo.getBooksByStatus(BookStatus.completed);
      final readingBooks = await bookRepo.getBooksByStatus(BookStatus.reading);
      final totalPages = await bookRepo.getTotalPagesRead();

      // Load session stats
      final streak = await sessionRepo.getReadingStreak();
      final avgPages = await sessionRepo.getAveragePagesPerSession();
      final todayTime = await sessionRepo.getTotalReadingTimeToday();

      // Calculate books by status
      final byStatus = <String, int>{};
      for (final status in BookStatus.values) {
        final books = await bookRepo.getBooksByStatus(status);
        byStatus[status.displayName] = books.length;
      }

      // Calculate books by category
      final byCategory = <String, int>{};
      for (final book in allBooks) {
        for (final category in book.categories) {
          byCategory[category] = (byCategory[category] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _totalBooks = allBooks.length;
          _booksCompleted = completedBooks.length;
          _booksReading = readingBooks.length;
          _totalPagesRead = totalPages;
          _readingStreak = streak;
          _avgPagesPerSession = avgPages;
          _totalReadingTime = todayTime;
          _recentlyCompleted = completedBooks.take(5).toList();
          _booksByStatus = byStatus;
          _booksByCategory = byCategory;
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
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview cards
                    _buildOverviewSection(),
                    const SizedBox(height: 24),

                    // Reading streak
                    _buildStreakSection(),
                    const SizedBox(height: 24),

                    // Pages read this month (bar chart)
                    _buildMonthlyPagesChart(),
                    const SizedBox(height: 24),

                    // Books by status chart
                    _buildStatusChart(),
                    const SizedBox(height: 24),

                    // Categories chart
                    if (_booksByCategory.isNotEmpty) ...[
                      _buildCategoryChart(),
                      const SizedBox(height: 24),
                    ],

                    // Fastest/Slowest reads
                    _buildReadingSpeedSection(),
                    const SizedBox(height: 24),

                    // Recently completed
                    if (_recentlyCompleted.isNotEmpty) ...[
                      _buildRecentlyCompletedSection(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.library_books,
                label: 'Total Books',
                value: '$_totalBooks',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                label: 'Completed',
                value: '$_booksCompleted',
                color: AppColors.completed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book,
                label: 'Currently Reading',
                value: '$_booksReading',
                color: AppColors.reading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.auto_stories,
                label: 'Pages Read',
                value: '$_totalPagesRead',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.accent),
                  Text(
                    '$_readingStreak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Streak',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _readingStreak == 0
                        ? 'Start reading to build your streak!'
                        : _readingStreak == 1
                            ? 'Keep it up! Read today to continue.'
                            : '$_readingStreak days in a row!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_avgPagesPerSession > 0)
                    Text(
                      'Avg ${_avgPagesPerSession.toStringAsFixed(1)} pages/session',
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

  Widget _buildMonthlyPagesChart() {
    // Generate last 7 days data
    // In production, this would fetch actual reading session data from the repository
    // For now, we show simulated data to demonstrate the chart functionality
    final dailyPages = List.generate(7, (index) {
      // Simulated daily reading pages: varies between 20-80 pages per day
      // The formula creates a wave pattern for visual demonstration
      const basePagesPerDay = 40.0;
      const variationRange = 30.0;
      final variation = (index * 17) % 60 - 30; // Deterministic variation
      final pages = basePagesPerDay + variation.clamp(-variationRange, variationRange);
      return FlSpot(index.toDouble(), pages);
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pages This Week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_totalPagesRead} total',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.neutral200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyPages,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart() {
    final total = _booksByStatus.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Books by Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: _buildPieChartSections(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _booksByStatus.entries.map((entry) {
                return _ChartLegend(
                  label: entry.key,
                  value: entry.value,
                  color: _getStatusColor(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _booksByStatus.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [];

    return _booksByStatus.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: percentage >= 10 ? '${percentage.toInt()}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        color: _getStatusColor(entry.key),
        radius: 50,
      );
    }).toList();
  }

  Color _getStatusColor(String statusName) {
    switch (statusName) {
      case 'To Read':
        return AppColors.toRead;
      case 'Reading':
        return AppColors.reading;
      case 'Completed':
        return AppColors.completed;
      case 'Abandoned':
        return AppColors.abandoned;
      default:
        return AppColors.neutral400;
    }
  }

  Widget _buildCategoryChart() {
    // Sort categories by count
    final sortedCategories = _booksByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(6).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (topCategories.first.value.toDouble() * 1.2),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topCategories.length) {
                            final category = topCategories[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                category.length > 8
                                    ? '${category.substring(0, 6)}...'
                                    : category,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: topCategories.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: AppColors.primary.withOpacity(0.8),
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingSpeedSection() {
    // Find fastest and slowest reads from completed books
    final completedWithDates = _recentlyCompleted.where((b) =>
        b.dateStarted != null &&
        b.dateFinished != null &&
        b.totalPages > 0).toList();

    if (completedWithDates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate reading speed (days per book)
    final booksWithSpeed = completedWithDates.map((book) {
      final days = book.dateFinished!.difference(book.dateStarted!).inDays + 1;
      return MapEntry(book, days);
    }).toList();

    booksWithSpeed.sort((a, b) => a.value.compareTo(b.value));

    final fastest = booksWithSpeed.isNotEmpty ? booksWithSpeed.first : null;
    final slowest = booksWithSpeed.length > 1 ? booksWithSpeed.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Reading Speed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (fastest != null)
              _SpeedItem(
                icon: Icons.bolt,
                iconColor: AppColors.success,
                label: 'Fastest Read',
                bookTitle: fastest.key.title,
                detail: '${fastest.value} ${fastest.value == 1 ? 'day' : 'days'}',
              ),
            if (fastest != null && slowest != null) const Divider(height: 24),
            if (slowest != null && slowest.key.id != fastest?.key.id)
              _SpeedItem(
                icon: Icons.hourglass_full,
                iconColor: AppColors.warning,
                label: 'Most Dedicated Read',
                bookTitle: slowest.key.title,
                detail: '${slowest.value} days',
              ),
            const SizedBox(height: 16),
            if (_avgPagesPerSession > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SpeedStat(
                      label: 'Avg Pages/Session',
                      value: _avgPagesPerSession.toStringAsFixed(1),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.neutral300,
                    ),
                    _SpeedStat(
                      label: 'Books Completed',
                      value: '$_booksCompleted',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyCompletedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Completed',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentlyCompleted.length,
          itemBuilder: (context, index) {
            final book = _recentlyCompleted[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.completed.withOpacity(0.1),
                  child: const Icon(Icons.check, color: AppColors.completed),
                ),
                title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(book.author),
                trailing: book.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Text('${book.rating}'),
                        ],
                      )
                    : null,
                onTap: () => context.go('/book/${book.id}'),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }
}

/// Chart legend item
class _ChartLegend extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ChartLegend({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label ($value)'),
      ],
    );
  }
}

/// Speed item widget
class _SpeedItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String bookTitle;
  final String detail;

  const _SpeedItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.bookTitle,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
              ),
              Text(
                bookTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            detail,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Speed stat widget
class _SpeedStat extends StatelessWidget {
  final String label;
  final String value;

  const _SpeedStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral500,
              ),
        ),
      ],
    );
  }
}
