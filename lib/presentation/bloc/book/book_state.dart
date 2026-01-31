part of 'book_bloc.dart';

/// Base state for BookBloc
abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookInitial extends BookState {
  const BookInitial();
}

/// Loading state
class BookLoading extends BookState {
  const BookLoading();
}

/// Books loaded successfully
class BooksLoaded extends BookState {
  final List<BookModel> books;
  final List<BookModel> currentlyReading;
  final List<String> categories;
  final String? activeCategory;
  final BookStatus? activeStatus;
  final String? searchQuery;

  const BooksLoaded({
    required this.books,
    this.currentlyReading = const [],
    this.categories = const [],
    this.activeCategory,
    this.activeStatus,
    this.searchQuery,
  });

  BooksLoaded copyWith({
    List<BookModel>? books,
    List<BookModel>? currentlyReading,
    List<String>? categories,
    String? activeCategory,
    BookStatus? activeStatus,
    String? searchQuery,
  }) {
    return BooksLoaded(
      books: books ?? this.books,
      currentlyReading: currentlyReading ?? this.currentlyReading,
      categories: categories ?? this.categories,
      activeCategory: activeCategory ?? this.activeCategory,
      activeStatus: activeStatus ?? this.activeStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        books,
        currentlyReading,
        categories,
        activeCategory,
        activeStatus,
        searchQuery,
      ];
}

/// Single book loaded
class BookDetailLoaded extends BookState {
  final BookModel book;

  const BookDetailLoaded(this.book);

  @override
  List<Object?> get props => [book];
}

/// Book operation successful (add, update, delete)
class BookOperationSuccess extends BookState {
  final String message;

  const BookOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object?> get props => [message];
}
