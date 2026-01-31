import 'package:intl/intl.dart';

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Format date as "Jan 15, 2024"
  String toFormattedDate() {
    return DateFormat('MMM d, y').format(this);
  }

  /// Format date as "January 15, 2024"
  String toFullDate() {
    return DateFormat('MMMM d, y').format(this);
  }

  /// Format date as "01/15/2024"
  String toShortDate() {
    return DateFormat('MM/dd/y').format(this);
  }

  /// Format time as "2:30 PM"
  String toFormattedTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format datetime as "Jan 15, 2024 at 2:30 PM"
  String toFormattedDateTime() {
    return DateFormat('MMM d, y \'at\' h:mm a').format(this);
  }

  /// Get relative time string (e.g., "2 days ago", "just now")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is this year
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// Get start of day (midnight)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format duration as "X hours Y minutes" or "X minutes"
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Less than a minute';
    }
  }

  /// Format duration as "1h 30m"
  String toShortString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '< 1m';
    }
  }
}
