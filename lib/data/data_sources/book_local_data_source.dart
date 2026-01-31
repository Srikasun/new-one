import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/book_model.dart';

/// Local data source for Book operations using Hive
abstract class BookLocalDataSource {
  /// Get all books
  Future<List<BookModel>> getAllBooks();

  /// Get a book by ID
  Future<BookModel?> getBookById(String id);

  /// Get books by status
  Future<List<BookModel>> getBooksByStatus(BookStatus status);

  /// Get books by category
  Future<List<BookModel>> getBooksByCategory(String category);

  /// Search books by title or author
  Future<List<BookModel>> searchBooks(String query);

  /// Add a new book
  Future<void> addBook(BookModel book);

  /// Update an existing book
  Future<void> updateBook(BookModel book);

  /// Delete a book
  Future<void> deleteBook(String id);

  /// Update reading progress
  Future<void> updateProgress(String id, int currentPage);

  /// Get all unique categories
  Future<List<String>> getAllCategories();
}

/// Implementation of BookLocalDataSource using Hive
class BookLocalDataSourceImpl implements BookLocalDataSource {
  final Box<BookModel> _booksBox;

  BookLocalDataSourceImpl({required Box<BookModel> booksBox})
      : _booksBox = booksBox;

  @override
  Future<List<BookModel>> getAllBooks() async {
    try {
      return _booksBox.values.toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get all books',
        originalException: e,
      );
    }
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    try {
      return _booksBox.get(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get book by ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<BookModel>> getBooksByStatus(BookStatus status) async {
    try {
      return _booksBox.values.where((book) => book.status == status).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get books by status',
        originalException: e,
      );
    }
  }

  @override
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      return _booksBox.values
          .where((book) => book.categories.contains(category))
          .toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get books by category',
        originalException: e,
      );
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      return _booksBox.values.where((book) {
        return book.title.toLowerCase().contains(lowerQuery) ||
            book.author.toLowerCase().contains(lowerQuery) ||
            (book.isbn?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to search books',
        originalException: e,
      );
    }
  }

  @override
  Future<void> addBook(BookModel book) async {
    try {
      await _booksBox.put(book.id, book);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to add book',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateBook(BookModel book) async {
    try {
      await _booksBox.put(book.id, book);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update book',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      await _booksBox.delete(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete book',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateProgress(String id, int currentPage) async {
    try {
      final book = _booksBox.get(id);
      if (book == null) {
        throw const DatabaseException(
          message: 'Book not found',
          code: 'NOT_FOUND',
        );
      }

      BookStatus newStatus = book.status;
      DateTime? dateStarted = book.dateStarted;
      DateTime? dateFinished = book.dateFinished;

      // Update status based on progress
      if (currentPage > 0 && book.status == BookStatus.toRead) {
        newStatus = BookStatus.reading;
        dateStarted = DateTime.now();
      }

      if (currentPage >= book.totalPages) {
        newStatus = BookStatus.completed;
        dateFinished = DateTime.now();
      }

      final updatedBook = book.copyWith(
        currentPage: currentPage,
        status: newStatus,
        dateStarted: dateStarted,
        dateFinished: dateFinished,
      );

      await _booksBox.put(id, updatedBook);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update progress',
        originalException: e,
      );
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      final categories = <String>{};
      for (final book in _booksBox.values) {
        categories.addAll(book.categories);
      }
      return categories.toList()..sort();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get categories',
        originalException: e,
      );
    }
  }
}

/// Factory to get books box
Future<Box<BookModel>> openBooksBox() async {
  if (!Hive.isBoxOpen(HiveConstants.booksBox)) {
    return await Hive.openBox<BookModel>(HiveConstants.booksBox);
  }
  return Hive.box<BookModel>(HiveConstants.booksBox);
}
