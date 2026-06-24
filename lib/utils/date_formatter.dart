import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');

  static String format(DateTime date) => _displayFormat.format(date);

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isBeforeToday(DateTime date) {
    return dateOnly(date).isBefore(today());
  }
}
