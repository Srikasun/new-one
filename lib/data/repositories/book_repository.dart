import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../data_sources/book_local_data_source.dart';
import '../models/book_model.dart';

/// Repository for Book operations
abstract class BookRepository {
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

  /// Get currently reading books
  Future<List<BookModel>> getCurrentlyReading();

  /// Get recently added books
  Future<List<BookModel>> getRecentlyAdded({int limit = 5});

  /// Get completed books count
  Future<int> getCompletedBooksCount();

  /// Get total pages read
  Future<int> getTotalPagesRead();
}

/// Implementation of BookRepository
class BookRepositoryImpl implements BookRepository {
  final BookLocalDataSource _localDataSource;

  BookRepositoryImpl({required BookLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<BookModel>> getAllBooks() async {
    try {
      return await _localDataSource.getAllBooks();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    try {
      return await _localDataSource.getBookById(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<BookModel>> getBooksByStatus(BookStatus status) async {
    try {
      return await _localDataSource.getBooksByStatus(status);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      return await _localDataSource.getBooksByCategory(category);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      return await _localDataSource.searchBooks(query);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> addBook(BookModel book) async {
    try {
      await _localDataSource.addBook(book);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateBook(BookModel book) async {
    try {
      await _localDataSource.updateBook(book);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      await _localDataSource.deleteBook(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<void> updateProgress(String id, int currentPage) async {
    try {
      await _localDataSource.updateProgress(id, currentPage);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      return await _localDataSource.getAllCategories();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<BookModel>> getCurrentlyReading() async {
    try {
      final books = await _localDataSource.getBooksByStatus(BookStatus.reading);
      // Sort by most recently started
      books.sort((a, b) {
        if (a.dateStarted != null && b.dateStarted != null) {
          return b.dateStarted!.compareTo(a.dateStarted!);
        }
        return 0;
      });
      return books;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<List<BookModel>> getRecentlyAdded({int limit = 5}) async {
    try {
      final books = await _localDataSource.getAllBooks();
      books.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return books.take(limit).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<int> getCompletedBooksCount() async {
    try {
      final completedBooks =
          await _localDataSource.getBooksByStatus(BookStatus.completed);
      return completedBooks.length;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }

  @override
  Future<int> getTotalPagesRead() async {
    try {
      final allBooks = await _localDataSource.getAllBooks();
      return allBooks.fold<int>(0, (sum, book) => sum + book.currentPage);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message, originalError: e);
    }
  }
}
