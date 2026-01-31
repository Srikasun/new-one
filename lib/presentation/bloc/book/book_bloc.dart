import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/book_model.dart';
import '../../../data/repositories/book_repository.dart';

part 'book_event.dart';
part 'book_state.dart';

/// BLoC for managing book operations
class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository _bookRepository;

  BookBloc({required BookRepository bookRepository})
      : _bookRepository = bookRepository,
        super(const BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadBooksByStatus>(_onLoadBooksByStatus);
    on<SearchBooks>(_onSearchBooks);
    on<AddBook>(_onAddBook);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
    on<UpdateProgress>(_onUpdateProgress);
    on<LoadBookById>(_onLoadBookById);
    on<FilterByCategory>(_onFilterByCategory);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final books = await _bookRepository.getAllBooks();
      final currentlyReading = await _bookRepository.getCurrentlyReading();
      final categories = await _bookRepository.getAllCategories();

      emit(BooksLoaded(
        books: books,
        currentlyReading: currentlyReading,
        categories: categories,
      ));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadBooksByStatus(
    LoadBooksByStatus event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final books = await _bookRepository.getBooksByStatus(event.status);
      final categories = await _bookRepository.getAllCategories();

      emit(BooksLoaded(
        books: books,
        categories: categories,
        activeStatus: event.status,
      ));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onSearchBooks(
    SearchBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final books = await _bookRepository.searchBooks(event.query);
      final categories = await _bookRepository.getAllCategories();

      emit(BooksLoaded(
        books: books,
        categories: categories,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onAddBook(
    AddBook event,
    Emitter<BookState> emit,
  ) async {
    try {
      await _bookRepository.addBook(event.book);
      emit(const BookOperationSuccess('Book added successfully'));
      add(const LoadBooks());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onUpdateBook(
    UpdateBook event,
    Emitter<BookState> emit,
  ) async {
    try {
      await _bookRepository.updateBook(event.book);
      emit(const BookOperationSuccess('Book updated successfully'));
      add(const LoadBooks());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onDeleteBook(
    DeleteBook event,
    Emitter<BookState> emit,
  ) async {
    try {
      await _bookRepository.deleteBook(event.bookId);
      emit(const BookOperationSuccess('Book deleted successfully'));
      add(const LoadBooks());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateProgress event,
    Emitter<BookState> emit,
  ) async {
    try {
      await _bookRepository.updateProgress(event.bookId, event.currentPage);
      emit(const BookOperationSuccess('Progress updated'));
      add(const LoadBooks());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadBookById(
    LoadBookById event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final book = await _bookRepository.getBookById(event.bookId);
      if (book != null) {
        emit(BookDetailLoaded(book));
      } else {
        emit(const BookError('Book not found'));
      }
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final books = await _bookRepository.getBooksByCategory(event.category);
      final categories = await _bookRepository.getAllCategories();

      emit(BooksLoaded(
        books: books,
        categories: categories,
        activeCategory: event.category,
      ));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<BookState> emit,
  ) async {
    add(const LoadBooks());
  }
}
