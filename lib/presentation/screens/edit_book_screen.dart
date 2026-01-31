import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../bloc/book/book_bloc.dart';
import '../widgets/common_widgets.dart';

/// Screen for editing an existing book
class EditBookScreen extends StatefulWidget {
  final String bookId;

  const EditBookScreen({super.key, required this.bookId});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _pagesController;
  late TextEditingController _currentPageController;
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
  BookModel? _originalBook;

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
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController();
    _pagesController = TextEditingController();
    _currentPageController = TextEditingController();
    _publisherController = TextEditingController();
    _yearController = TextEditingController();
    _descriptionController = TextEditingController();
    _notesController = TextEditingController();
    _coverUrlController = TextEditingController();

    // Load book data
    context.read<BookBloc>().add(LoadBookById(widget.bookId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    _currentPageController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  void _populateForm(BookModel book) {
    _titleController.text = book.title;
    _authorController.text = book.author;
    _isbnController.text = book.isbn ?? '';
    _pagesController.text = book.totalPages.toString();
    _currentPageController.text = book.currentPage.toString();
    _publisherController.text = book.publisher ?? '';
    _yearController.text = book.publishYear?.toString() ?? '';
    _descriptionController.text = book.description ?? '';
    _notesController.text = book.notes ?? '';
    _coverUrlController.text = book.coverUrl ?? '';
    _status = book.status;
    _rating = book.rating ?? 0;
    _selectedCategories = List.from(book.categories);
    _dateStarted = book.dateStarted;
    _dateFinished = book.dateFinished;
    _coverUrl = book.coverUrl;
    _originalBook = book;
  }

  void _saveBook() {
    if (!_formKey.currentState!.validate()) return;
    if (_originalBook == null) return;

    final updatedBook = _originalBook!.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
      coverUrl: _coverUrl,
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      currentPage: int.tryParse(_currentPageController.text) ?? 0,
      status: _status,
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

    context.read<BookBloc>().add(UpdateBook(updatedBook));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Book updated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );

    context.go(RouteNames.home);
  }

  void _deleteBook() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text(
          'Are you sure you want to delete this book? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookBloc>().add(DeleteBook(widget.bookId));
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookDetailLoaded && _originalBook == null) {
          setState(() {
            _populateForm(state.book);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Book'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteBook,
              tooltip: 'Delete Book',
            ),
            TextButton.icon(
              onPressed: _saveBook,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
        body: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookLoading && _originalBook == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookError && _originalBook == null) {
              return Center(
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
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image section
                    _buildCoverSection(),
                    const SizedBox(height: 24),

                    // Basic info
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Progress
                    _buildProgressSection(),
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
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _deleteBook,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Book'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildProgressSection() {
    final totalPages = int.tryParse(_pagesController.text) ?? 0;
    final currentPage = int.tryParse(_currentPageController.text) ?? 0;
    final progress = totalPages > 0 ? currentPage / totalPages : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Progress',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _currentPageController,
          decoration: InputDecoration(
            labelText: 'Current Page',
            prefixIcon: const Icon(Icons.bookmark),
            suffixText: 'of ${_pagesController.text}',
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ReadingProgressWidget(
          progress: progress.clamp(0.0, 1.0),
          currentPage: currentPage,
          totalPages: totalPages,
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
