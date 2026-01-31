/// Validation utility class
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate ISBN (10 or 13 digits)
  static String? isbn(String? value) {
    if (value == null || value.isEmpty) {
      return null; // ISBN is optional
    }

    // Remove hyphens and spaces
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check for ISBN-10
    if (cleanedValue.length == 10) {
      if (!RegExp(r'^[0-9]{9}[0-9X]$').hasMatch(cleanedValue)) {
        return 'Invalid ISBN-10 format';
      }
      return null;
    }

    // Check for ISBN-13
    if (cleanedValue.length == 13) {
      if (!RegExp(r'^[0-9]{13}$').hasMatch(cleanedValue)) {
        return 'Invalid ISBN-13 format';
      }
      return null;
    }

    return 'ISBN must be 10 or 13 digits';
  }

  /// Validate page number
  static String? pageNumber(
    String? value, {
    int minValue = 0,
    int? maxValue,
  }) {
    if (value == null || value.isEmpty) {
      return 'Page number is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < minValue) {
      return 'Page number must be at least $minValue';
    }

    if (maxValue != null && number > maxValue) {
      return 'Page number cannot exceed $maxValue';
    }

    return null;
  }

  /// Validate rating (0-5)
  static String? rating(double? value) {
    if (value == null) {
      return null; // Rating is optional
    }

    if (value < 0 || value > 5) {
      return 'Rating must be between 0 and 5';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate date is not in the future
  static String? notFutureDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return null;
    }

    if (value.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }

    return null;
  }

  /// Validate end date is after start date
  static String? dateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String startFieldName = 'Start date',
    String endFieldName = 'End date',
  }) {
    if (startDate == null || endDate == null) {
      return null;
    }

    if (endDate.isBefore(startDate)) {
      return '$endFieldName must be after $startFieldName';
    }

    return null;
  }

  /// Validate current page is not greater than total pages
  static String? currentPage(int? currentPage, int? totalPages) {
    if (currentPage == null || totalPages == null) {
      return null;
    }

    if (currentPage > totalPages) {
      return 'Current page cannot exceed total pages';
    }

    if (currentPage < 0) {
      return 'Current page cannot be negative';
    }

    return null;
  }

  /// Validate goal target value
  static String? goalTarget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Target value is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Target must be greater than 0';
    }

    return null;
  }
}
