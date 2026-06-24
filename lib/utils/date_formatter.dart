import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');

  static String format(DateTime date) => _displayFormat.format(date);
}
