part of 'book_bloc.dart';

/// Base event for BookBloc
abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all books
class LoadBooks extends BookEvent {
  const LoadBooks();
}

/// Event to load books by status
class LoadBooksByStatus extends BookEvent {
  final BookStatus status;

  const LoadBooksByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Event to search books
class SearchBooks extends BookEvent {
  final String query;

  const SearchBooks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to add a new book
class AddBook extends BookEvent {
  final BookModel book;

  const AddBook(this.book);

  @override
  List<Object?> get props => [book];
}

/// Event to update an existing book
class UpdateBook extends BookEvent {
  final BookModel book;

  const UpdateBook(this.book);

  @override
  List<Object?> get props => [book];
}

/// Event to delete a book
class DeleteBook extends BookEvent {
  final String bookId;

  const DeleteBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to update reading progress
class UpdateProgress extends BookEvent {
  final String bookId;
  final int currentPage;

  const UpdateProgress({
    required this.bookId,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [bookId, currentPage];
}

/// Event to load a single book by ID
class LoadBookById extends BookEvent {
  final String bookId;

  const LoadBookById(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to filter books by category
class FilterByCategory extends BookEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to clear filters
class ClearFilters extends BookEvent {
  const ClearFilters();
}
