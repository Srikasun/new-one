/// Custom exceptions for DreamShelf app
library;

/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Database exception
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
  });
}
