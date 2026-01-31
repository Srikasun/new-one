import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/services/google_books_service.dart';
import '../bloc/ad/ad_bloc.dart';
import '../bloc/book/book_bloc.dart';
import '../widgets/common_widgets.dart';

/// Screen for adding a new book
class AddBookScreen extends StatefulWidget {
  final BookModel? initialBook;

  const AddBookScreen({super.key, this.initialBook});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _pagesController;
  late TextEditingController _publisherController;
  late TextEditingController _yearController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TextEditingController _coverUrlController;

  // Form state
  BookStatus _status = BookStatus.toRead;
  double _rating = 0;
  List<String> _selectedCategories = [];
  DateTime? _dateStarted;
  DateTime? _dateFinished;
  String? _coverUrl;

  // Search state
  bool _isSearching = false;
  List<BookModel> _searchResults = [];
  final GoogleBooksService _booksService = GoogleBooksService();

  final List<String> _availableCategories = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Horror',
    'Biography',
    'History',
    'Science',
    'Technology',
    'Self-Help',
    'Business',
    'Philosophy',
    'Poetry',
    'Art',
    'Travel',
    'Cooking',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    final book = widget.initialBook;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _pagesController = TextEditingController(
      text: book?.totalPages.toString() ?? '',
    );
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _yearController = TextEditingController(
      text: book?.publishYear?.toString() ?? '',
    );
    _descriptionController = TextEditingController(text: book?.description ?? '');
    _notesController = TextEditingController(text: book?.notes ?? '');
    _coverUrlController = TextEditingController(text: book?.coverUrl ?? '');

    if (book != null) {
      _status = book.status;
      _rating = book.rating ?? 0;
      _selectedCategories = List.from(book.categories);
      _dateStarted = book.dateStarted;
      _dateFinished = book.dateFinished;
      _coverUrl = book.coverUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _coverUrlController.dispose();
    _booksService.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    final query = _titleController.text.isNotEmpty
        ? _titleController.text
        : _authorController.text;

    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await _booksService.searchBooks(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      _showSearchResultsSheet();
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _showSearchResultsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final book = _searchResults[index];
                          return ListTile(
                            leading: BookCoverWidget(
                              imageUrl: book.coverUrl,
                              width: 50,
                              height: 70,
                            ),
                            title: Text(book.title, maxLines: 2),
                            subtitle: Text(book.author),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              _fillFormWithBook(book);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fillFormWithBook(BookModel book) {
    setState(() {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _isbnController.text = book.isbn ?? '';
      _pagesController.text = book.totalPages.toString();
      _publisherController.text = book.publisher ?? '';
      _yearController.text = book.publishYear?.toString() ?? '';
      _descriptionController.text = book.description ?? '';
      _coverUrl = book.coverUrl;
      _coverUrlController.text = book.coverUrl ?? '';
      _selectedCategories = List.from(book.categories);
    });
  }

  void _saveBook() {
    if (!_formKey.currentState!.validate()) return;

    final book = BookModel(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
      coverUrl: _coverUrl,
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      currentPage: 0,
      status: _status,
      dateAdded: DateTime.now(),
      dateStarted: _dateStarted,
      dateFinished: _dateFinished,
      rating: _rating > 0 ? _rating : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      categories: _selectedCategories,
      publisher: _publisherController.text.trim().isEmpty
          ? null
          : _publisherController.text.trim(),
      publishYear: int.tryParse(_yearController.text),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    context.read<BookBloc>().add(AddBook(book));
    
    // Track book added for interstitial ad logic
    context.read<AdBloc>().add(const BookAdded());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Book added to your library!'),
        backgroundColor: AppColors.success,
      ),
    );

    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        actions: [
          TextButton.icon(
            onPressed: _saveBook,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image section
              _buildCoverSection(),
              const SizedBox(height: 24),

              // Search from Google Books
              _buildSearchSection(),
              const SizedBox(height: 24),

              // Basic info
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Status and Rating
              _buildStatusRatingSection(),
              const SizedBox(height: 24),

              // Categories
              _buildCategoriesSection(),
              const SizedBox(height: 24),

              // Dates
              _buildDatesSection(),
              const SizedBox(height: 24),

              // Description
              _buildDescriptionSection(),
              const SizedBox(height: 24),

              // Notes
              _buildNotesSection(),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveBook,
                icon: const Icon(Icons.add),
                label: const Text('Add Book'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showCoverUrlDialog,
            child: Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral300),
                image: _coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _coverUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Cover',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral500,
                              ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          if (_coverUrl != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _coverUrl = null),
              child: const Text('Remove Cover'),
            ),
          ],
        ],
      ),
    );
  }

  void _showCoverUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cover Image URL'),
        content: TextField(
          controller: _coverUrlController,
          decoration: const InputDecoration(
            hintText: 'Enter image URL',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _coverUrl = _coverUrlController.text.trim().isEmpty
                    ? null
                    : _coverUrlController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Google Books',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a title or author above, then tap search to find book details automatically.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSearching ? null : _searchBooks,
              icon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? 'Searching...' : 'Search Google Books'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title *',
            prefixIcon: Icon(Icons.book),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText: 'Author *',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an author';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pagesController,
                decoration: const InputDecoration(
                  labelText: 'Total Pages',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status & Rating',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: BookStatus.values.map((status) {
            return ChoiceChip(
              label: Text(status.displayName),
              selected: _status == status,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _status = status);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Rating:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16),
            RatingWidget(
              rating: _rating,
              size: 32,
              interactive: true,
              onRatingChanged: (rating) => setState(() => _rating = rating),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_selectedCategories.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedCategories.clear()),
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Dates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DatePickerField(
                label: 'Started',
                date: _dateStarted,
                onDateSelected: (date) => setState(() => _dateStarted = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DatePickerField(
                label: 'Finished',
                date: _dateFinished,
                onDateSelected: (date) => setState(() => _dateFinished = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Enter book description...',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Notes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Add your personal notes...',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}

/// Date picker field widget
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        onDateSelected(selectedDate);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onDateSelected(null),
                )
              : null,
        ),
        child: Text(
          date != null ? dateFormat.format(date!) : 'Select date',
          style: TextStyle(
            color: date != null ? null : AppColors.neutral400,
          ),
        ),
      ),
    );
  }
}
