import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../bloc/book/book_bloc.dart';

/// Home screen displaying the user's book library
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load books when screen initializes
    context.read<BookBloc>().add(const LoadBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(RouteNames.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(RouteNames.settings),
          ),
        ],
      ),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BookError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading books',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BookBloc>().add(const LoadBooks()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BooksLoaded) {
            if (state.books.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildBooksList(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RouteNames.addBook),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.read<BookBloc>().add(const LoadBooks());
              break;
            case 1:
              context.go(RouteNames.statistics);
              break;
            case 2:
              context.go(RouteNames.goals);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 100,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 24),
          Text(
            'Your library is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first book!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral500,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go(RouteNames.addBook),
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go(RouteNames.scanBook),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan ISBN'),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(BuildContext context, BooksLoaded state) {
    return CustomScrollView(
      slivers: [
        // Currently reading section
        if (state.currentlyReading.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Currently Reading',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: state.currentlyReading.length,
                itemBuilder: (context, index) {
                  final book = state.currentlyReading[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () => context.go('/book/${book.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.1),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: book.progressPercentage,
                                    backgroundColor: AppColors.neutral200,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(book.progressPercentage * 100).toInt()}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // All books section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Books',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${state.books.length} books',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = state.books[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.book,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(book.title),
                subtitle: Text(book.author),
                trailing: Chip(
                  label: Text(book.status.displayName),
                  backgroundColor: _getStatusColor(book.status),
                ),
                onTap: () => context.go('/book/${book.id}'),
              );
            },
            childCount: state.books.length,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(dynamic status) {
    switch (status.index) {
      case 0:
        return AppColors.toRead.withOpacity(0.2);
      case 1:
        return AppColors.reading.withOpacity(0.2);
      case 2:
        return AppColors.completed.withOpacity(0.2);
      case 3:
        return AppColors.abandoned.withOpacity(0.2);
      default:
        return AppColors.neutral200;
    }
  }
}
