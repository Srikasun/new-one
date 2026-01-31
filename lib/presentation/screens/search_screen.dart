import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/services/google_books_service.dart';
import '../bloc/book/book_bloc.dart';
import '../widgets/common_widgets.dart';

/// Search screen for finding books in library and Google Books
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GoogleBooksService _booksService = GoogleBooksService();
  final FocusNode _focusNode = FocusNode();

  List<BookModel> _libraryResults = [];
  List<BookModel> _onlineResults = [];
  bool _isSearchingLibrary = false;
  bool _isSearchingOnline = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _booksService.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _query = query);

    if (query.isEmpty) {
      setState(() {
        _libraryResults = [];
        _onlineResults = [];
      });
      return;
    }

    // Search library
    _searchLibrary(query);

    // Debounce online search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_query == query) {
        _searchOnline(query);
      }
    });
  }

  void _searchLibrary(String query) {
    setState(() => _isSearchingLibrary = true);
    context.read<BookBloc>().add(SearchBooks(query));
  }

  Future<void> _searchOnline(String query) async {
    setState(() => _isSearchingOnline = true);

    try {
      final results = await _booksService.searchBooks(query);
      if (mounted && _query == query) {
        setState(() {
          _onlineResults = results;
          _isSearchingOnline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingOnline = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search books...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.neutral400),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Library'),
            Tab(text: 'Online'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Library search results
          _buildLibraryResults(),

          // Online search results
          _buildOnlineResults(),
        ],
      ),
    );
  }

  Widget _buildLibraryResults() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (_query.isEmpty) {
          return _buildEmptySearchState(
            icon: Icons.search,
            title: 'Search your library',
            subtitle: 'Find books by title, author, or ISBN',
          );
        }

        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BooksLoaded) {
          if (state.books.isEmpty) {
            return _buildEmptySearchState(
              icon: Icons.search_off,
              title: 'No books found',
              subtitle: 'Try a different search term or add a new book',
              action: ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.addBook),
                icon: const Icon(Icons.add),
                label: const Text('Add Book'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.books.length,
            itemBuilder: (context, index) {
              final book = state.books[index];
              return _LibraryBookItem(
                book: book,
                onTap: () => context.go('/book/${book.id}'),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOnlineResults() {
    if (_query.isEmpty) {
      return _buildEmptySearchState(
        icon: Icons.public,
        title: 'Search Google Books',
        subtitle: 'Find books from millions of titles',
      );
    }

    if (_isSearchingOnline) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_onlineResults.isEmpty) {
      return _buildEmptySearchState(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _onlineResults.length,
      itemBuilder: (context, index) {
        final book = _onlineResults[index];
        return _OnlineBookItem(
          book: book,
          onAdd: () => _addBookToLibrary(book),
        );
      },
    );
  }

  Widget _buildEmptySearchState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  void _addBookToLibrary(BookModel book) {
    context.read<BookBloc>().add(AddBook(book));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book.title} added to your library!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => context.go('/book/${book.id}'),
        ),
      ),
    );
  }
}

/// Library book item widget
class _LibraryBookItem extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;

  const _LibraryBookItem({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Hero(
          tag: 'book_cover_${book.id}',
          child: BookCoverWidget(
            imageUrl: book.coverUrl,
            width: 50,
            height: 70,
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            const SizedBox(height: 4),
            Row(
              children: [
                BookStatusChip(status: book.status),
                if (book.rating != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 14, color: AppColors.accent),
                  const SizedBox(width: 2),
                  Text('${book.rating}'),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}

/// Online book item widget
class _OnlineBookItem extends StatelessWidget {
  final BookModel book;
  final VoidCallback onAdd;

  const _OnlineBookItem({
    required this.book,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCoverWidget(
              imageUrl: book.coverUrl,
              width: 70,
              height: 100,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (book.totalPages > 0)
                    Text(
                      '${book.totalPages} pages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (book.publishYear != null)
                    Text(
                      'Published ${book.publishYear}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ],
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
