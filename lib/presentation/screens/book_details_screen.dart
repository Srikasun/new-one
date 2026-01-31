import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/reading_session_model.dart';
import '../../data/repositories/session_repository.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../widgets/common_widgets.dart';

/// Screen showing detailed information about a book
class BookDetailsScreen extends StatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  List<ReadingSessionModel> _sessions = [];
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(LoadBookById(widget.bookId));
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final repository = context.read<SessionRepository>();
      final sessions = await repository.getSessionsForBook(widget.bookId);
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSessions = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BookError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is BookDetailLoaded) {
          return _buildContent(context, state.book);
        }

        return const Scaffold(
          body: Center(child: Text('Loading...')),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, BookModel book) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header with cover
          _buildSliverAppBar(context, book),

          // Book info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  _buildHeader(context, book),
                  const SizedBox(height: 24),

                  // Progress section
                  _buildProgressSection(context, book),
                  const SizedBox(height: 24),

                  // Quick actions
                  _buildQuickActions(context, book),
                  const SizedBox(height: 24),

                  // Details section
                  _buildDetailsSection(context, book),
                  const SizedBox(height: 24),

                  // Description
                  if (book.description != null) ...[
                    _buildDescriptionSection(context, book),
                    const SizedBox(height: 24),
                  ],

                  // Categories
                  if (book.categories.isNotEmpty) ...[
                    _buildCategoriesSection(context, book),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  if (book.notes != null) ...[
                    _buildNotesSection(context, book),
                    const SizedBox(height: 24),
                  ],

                  // Reading sessions
                  _buildSessionsSection(context, book),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, book),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, BookModel book) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            ),
            // Book cover with hero animation
            Center(
              child: Hero(
                tag: 'book_cover_${book.id}',
                child: Container(
                  width: 150,
                  height: 220,
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.coverUrl != null
                        ? Image.network(
                            book.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                _buildPlaceholderCover(),
                          )
                        : _buildPlaceholderCover(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.go('/edit-book/${book.id}'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context, book);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete Book'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: AppColors.neutral200,
      child: const Center(
        child: Icon(Icons.book, size: 64, color: AppColors.primary),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'by ${book.author}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            BookStatusChip(status: book.status),
            const SizedBox(width: 12),
            if (book.rating != null)
              RatingWidget(rating: book.rating!, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, BookModel book) {
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
                  'Reading Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(book.progressPercentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: book.progressPercentage,
                          strokeWidth: 10,
                          backgroundColor: AppColors.neutral200,
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(book.progressPercentage),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${book.currentPage}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'of ${book.totalPages}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Stats
                Expanded(
                  child: Column(
                    children: [
                      _buildStatRow(
                        context,
                        'Pages Read',
                        '${book.currentPage}',
                        Icons.book,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Remaining',
                        '${book.remainingPages}',
                        Icons.bookmark_border,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Page update controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: book.currentPage > 0
                      ? () => _updateProgress(context, book, book.currentPage - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showUpdateProgressDialog(context, book),
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Page'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: book.currentPage < book.totalPages
                      ? () => _updateProgress(context, book, book.currentPage + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.neutral500),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, BookModel book) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.play_arrow,
            label: 'Start Reading',
            color: AppColors.secondary,
            onTap: () => _startReadingSession(context, book),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.share,
            label: 'Share',
            color: AppColors.info,
            onTap: () {
              // Share functionality
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.edit,
            label: 'Edit',
            color: AppColors.accent,
            onTap: () => context.go('/edit-book/${book.id}'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, BookModel book) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ISBN', book.isbn ?? 'Not specified'),
            _buildDetailRow('Publisher', book.publisher ?? 'Not specified'),
            _buildDetailRow(
              'Published',
              book.publishYear?.toString() ?? 'Not specified',
            ),
            _buildDetailRow('Pages', '${book.totalPages}'),
            _buildDetailRow('Added', dateFormat.format(book.dateAdded)),
            if (book.dateStarted != null)
              _buildDetailRow('Started', dateFormat.format(book.dateStarted!)),
            if (book.dateFinished != null)
              _buildDetailRow('Finished', dateFormat.format(book.dateFinished!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, BookModel book) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              book.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: book.categories
              .map((category) => Chip(
                    label: Text(category),
                    backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, BookModel book) {
    return Card(
      color: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Personal Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              book.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context, BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reading History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_sessions.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Show all sessions
                },
                child: Text('View All (${_sessions.length})'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingSessions)
          const Center(child: CircularProgressIndicator())
        else if (_sessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No reading sessions yet',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _startReadingSession(context, book),
                      child: const Text('Start Reading'),
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
            itemCount: _sessions.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final session = _sessions[index];
              return _SessionListItem(session: session);
            },
          ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, BookModel book) {
    return FloatingActionButton.extended(
      onPressed: () => _startReadingSession(context, book),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Read'),
      backgroundColor: AppColors.secondary,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.25) return AppColors.toRead;
    if (progress < 0.5) return AppColors.reading;
    if (progress < 0.75) return AppColors.secondary;
    return AppColors.completed;
  }

  void _updateProgress(BuildContext context, BookModel book, int newPage) {
    context.read<BookBloc>().add(UpdateProgress(
          bookId: book.id,
          currentPage: newPage,
        ));
  }

  void _showUpdateProgressDialog(BuildContext context, BookModel book) {
    final controller = TextEditingController(text: book.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Current Page',
            hintText: 'Enter page number (max ${book.totalPages})',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPage = int.tryParse(controller.text);
              if (newPage != null && newPage >= 0 && newPage <= book.totalPages) {
                _updateProgress(context, book, newPage);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _startReadingSession(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReadingSessionSheet(book: book),
    );
  }

  void _showDeleteDialog(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookBloc>().add(DeleteBook(book.id));
              context.go(RouteNames.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Quick action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reading session item widget
class _SessionListItem extends StatelessWidget {
  final ReadingSessionModel session;

  const _SessionListItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.history, color: AppColors.primary),
        ),
        title: Text('${session.pagesRead} pages read'),
        subtitle: Text(
          '${dateFormat.format(session.startTime)} at ${timeFormat.format(session.startTime)}',
        ),
        trailing: session.duration != null
            ? Text(
                _formatDuration(session.duration!),
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

/// Reading session bottom sheet
class _ReadingSessionSheet extends StatefulWidget {
  final BookModel book;

  const _ReadingSessionSheet({required this.book});

  @override
  State<_ReadingSessionSheet> createState() => _ReadingSessionSheetState();
}

class _ReadingSessionSheetState extends State<_ReadingSessionSheet> {
  bool _isReading = false;
  DateTime? _startTime;
  int _pagesRead = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                _isReading ? 'Reading Session' : 'Start Reading',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              if (_isReading) ...[
                // Timer display
                StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                    const Duration(seconds: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    final elapsed = DateTime.now().difference(_startTime!);
                    return Text(
                      _formatDuration(elapsed),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pages read controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _pagesRead > 0
                          ? () => setState(() => _pagesRead--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          '$_pagesRead',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Text('pages read'),
                      ],
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => setState(() => _pagesRead++),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _endSession,
                  icon: const Icon(Icons.stop),
                  label: const Text('End Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.menu_book,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Start tracking your reading session for "${widget.book.title}"',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isReading = true;
                      _startTime = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Session'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _endSession() {
    final duration = DateTime.now().difference(_startTime!);
    
    // Update book progress
    final newPage = (widget.book.currentPage + _pagesRead)
        .clamp(0, widget.book.totalPages);
    
    context.read<BookBloc>().add(UpdateProgress(
          bookId: widget.book.id,
          currentPage: newPage,
        ));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session complete! Read $_pagesRead pages in ${_formatDuration(duration)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
