import 'package:intl/intl.dart';

class DateHelper {
  /// Format date to display string
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format datetime with time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59);
  }

  /// Get start of year
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  /// Get display label for date range
  static String getDateRangeLabel(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = getStartOfDay(now);
    final todayEnd = getEndOfDay(now);

    if (start == today && end.compareTo(todayEnd) >= 0) {
      return 'Today';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayEnd = getEndOfDay(yesterday);
    if (start == yesterday && end.compareTo(yesterdayEnd) >= 0) {
      return 'Yesterday';
    }

    final monthStart = getStartOfMonth(now);
    final monthEnd = getEndOfMonth(now);
    if (start == monthStart && end.compareTo(monthEnd) >= 0) {
      return 'This Month';
    }

    final yearStart = getStartOfYear(now);
    final yearEnd = getEndOfYear(now);
    if (start == yearStart && end.compareTo(yearEnd) >= 0) {
      return 'This Year';
    }

    return '${formatDate(start)} - ${formatDate(end)}';
  }
}
