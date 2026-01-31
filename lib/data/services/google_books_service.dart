import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../models/book_model.dart';

/// Service for interacting with Google Books API
class GoogleBooksService {
  final http.Client _client;
  static const _uuid = Uuid();

  GoogleBooksService({http.Client? client}) : _client = client ?? http.Client();

  /// Search books by ISBN
  Future<BookModel?> searchByIsbn(String isbn) async {
    try {
      final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
      final url = Uri.parse(
        '${ApiConstants.googleBooksBaseUrl}/volumes?q=isbn:$cleanIsbn',
      );

      final response = await _client
          .get(url)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items != null && items.isNotEmpty) {
          return _parseBookFromVolume(items.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw GoogleBooksException('Failed to search by ISBN: $e');
    }
  }

  /// Search books by query (title, author, etc.)
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 20}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '${ApiConstants.googleBooksBaseUrl}/volumes?q=$encodedQuery&maxResults=$maxResults',
      );

      final response = await _client
          .get(url)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items != null) {
          return items
              .map((item) => _parseBookFromVolume(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw GoogleBooksException('Failed to search books: $e');
    }
  }

  /// Search books by title
  Future<List<BookModel>> searchByTitle(String title, {int maxResults = 20}) async {
    return searchBooks('intitle:$title', maxResults: maxResults);
  }

  /// Search books by author
  Future<List<BookModel>> searchByAuthor(String author, {int maxResults = 20}) async {
    return searchBooks('inauthor:$author', maxResults: maxResults);
  }

  /// Get book details by volume ID
  Future<BookModel?> getBookDetails(String volumeId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.googleBooksBaseUrl}/volumes/$volumeId',
      );

      final response = await _client
          .get(url)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _parseBookFromVolume(data);
      }
      return null;
    } catch (e) {
      throw GoogleBooksException('Failed to get book details: $e');
    }
  }

  /// Parse a book from Google Books API volume response
  BookModel _parseBookFromVolume(Map<String, dynamic> volume) {
    final volumeInfo = volume['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final industryIdentifiers =
        volumeInfo['industryIdentifiers'] as List<dynamic>?;

    // Extract ISBN
    String? isbn;
    if (industryIdentifiers != null) {
      for (final identifier in industryIdentifiers) {
        final type = identifier['type'] as String?;
        if (type == 'ISBN_13' || type == 'ISBN_10') {
          isbn = identifier['identifier'] as String?;
          if (type == 'ISBN_13') break; // Prefer ISBN-13
        }
      }
    }

    // Extract cover URL (prefer larger images)
    String? coverUrl;
    if (imageLinks != null) {
      coverUrl = imageLinks['large'] as String? ??
          imageLinks['medium'] as String? ??
          imageLinks['small'] as String? ??
          imageLinks['thumbnail'] as String? ??
          imageLinks['smallThumbnail'] as String?;
      // Convert to HTTPS
      if (coverUrl != null && coverUrl.startsWith('http:')) {
        coverUrl = coverUrl.replaceFirst('http:', 'https:');
      }
    }

    // Extract authors
    final authors = volumeInfo['authors'] as List<dynamic>?;
    final author = authors?.join(', ') ?? 'Unknown Author';

    // Extract categories
    final categories = (volumeInfo['categories'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        [];

    // Extract page count
    final pageCount = volumeInfo['pageCount'] as int? ?? 0;

    // Extract publish year
    final publishedDate = volumeInfo['publishedDate'] as String?;
    int? publishYear;
    if (publishedDate != null && publishedDate.length >= 4) {
      publishYear = int.tryParse(publishedDate.substring(0, 4));
    }

    return BookModel(
      id: _uuid.v4(),
      title: volumeInfo['title'] as String? ?? 'Unknown Title',
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      totalPages: pageCount,
      currentPage: 0,
      status: BookStatus.toRead,
      dateAdded: DateTime.now(),
      description: volumeInfo['description'] as String?,
      publisher: volumeInfo['publisher'] as String?,
      publishYear: publishYear,
      categories: categories,
    );
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Exception for Google Books API errors
class GoogleBooksException implements Exception {
  final String message;

  GoogleBooksException(this.message);

  @override
  String toString() => 'GoogleBooksException: $message';
}
