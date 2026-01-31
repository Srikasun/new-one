import 'package:equatable/equatable.dart';

/// Base class for all application failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory DatabaseFailure.read() => const DatabaseFailure(
        message: 'Failed to read from database',
        code: 'DB_READ_ERROR',
      );

  factory DatabaseFailure.write() => const DatabaseFailure(
        message: 'Failed to write to database',
        code: 'DB_WRITE_ERROR',
      );

  factory DatabaseFailure.delete() => const DatabaseFailure(
        message: 'Failed to delete from database',
        code: 'DB_DELETE_ERROR',
      );

  factory DatabaseFailure.notFound() => const DatabaseFailure(
        message: 'Record not found in database',
        code: 'DB_NOT_FOUND',
      );

  factory DatabaseFailure.initialization() => const DatabaseFailure(
        message: 'Failed to initialize database',
        code: 'DB_INIT_ERROR',
      );
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection',
        code: 'NO_CONNECTION',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timeout',
        code: 'TIMEOUT',
      );

  factory NetworkFailure.serverError() => const NetworkFailure(
        message: 'Server error occurred',
        code: 'SERVER_ERROR',
      );

  factory NetworkFailure.invalidResponse() => const NetworkFailure(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );

  factory NetworkFailure.notFound() => const NetworkFailure(
        message: 'Resource not found',
        code: 'NOT_FOUND',
      );
}

/// Purchase related failures
class PurchaseFailure extends Failure {
  const PurchaseFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory PurchaseFailure.cancelled() => const PurchaseFailure(
        message: 'Purchase was cancelled',
        code: 'PURCHASE_CANCELLED',
      );

  factory PurchaseFailure.failed() => const PurchaseFailure(
        message: 'Purchase failed',
        code: 'PURCHASE_FAILED',
      );

  factory PurchaseFailure.notAvailable() => const PurchaseFailure(
        message: 'In-app purchases are not available',
        code: 'PURCHASE_NOT_AVAILABLE',
      );

  factory PurchaseFailure.restoreFailed() => const PurchaseFailure(
        message: 'Failed to restore purchases',
        code: 'RESTORE_FAILED',
      );

  factory PurchaseFailure.invalidProduct() => const PurchaseFailure(
        message: 'Invalid product',
        code: 'INVALID_PRODUCT',
      );
}

/// Ad related failures
class AdFailure extends Failure {
  const AdFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AdFailure.loadFailed() => const AdFailure(
        message: 'Failed to load ad',
        code: 'AD_LOAD_FAILED',
      );

  factory AdFailure.showFailed() => const AdFailure(
        message: 'Failed to show ad',
        code: 'AD_SHOW_FAILED',
      );

  factory AdFailure.notReady() => const AdFailure(
        message: 'Ad is not ready',
        code: 'AD_NOT_READY',
      );
}

/// Scanner related failures
class ScannerFailure extends Failure {
  const ScannerFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory ScannerFailure.permissionDenied() => const ScannerFailure(
        message: 'Camera permission denied',
        code: 'PERMISSION_DENIED',
      );

  factory ScannerFailure.invalidCode() => const ScannerFailure(
        message: 'Invalid barcode',
        code: 'INVALID_CODE',
      );

  factory ScannerFailure.notSupported() => const ScannerFailure(
        message: 'Barcode scanning not supported',
        code: 'NOT_SUPPORTED',
      );
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory ValidationFailure.emptyField(String fieldName) => ValidationFailure(
        message: '$fieldName cannot be empty',
        code: 'EMPTY_FIELD',
      );

  factory ValidationFailure.invalidFormat(String fieldName) =>
      ValidationFailure(
        message: 'Invalid $fieldName format',
        code: 'INVALID_FORMAT',
      );

  factory ValidationFailure.outOfRange(String fieldName) => ValidationFailure(
        message: '$fieldName is out of valid range',
        code: 'OUT_OF_RANGE',
      );
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Cache not found',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheFailure.expired() => const CacheFailure(
        message: 'Cache has expired',
        code: 'CACHE_EXPIRED',
      );

  factory CacheFailure.saveFailed() => const CacheFailure(
        message: 'Failed to save to cache',
        code: 'CACHE_SAVE_FAILED',
      );
}

/// Unknown/unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'UNEXPECTED_ERROR',
    super.originalError,
  });
}
