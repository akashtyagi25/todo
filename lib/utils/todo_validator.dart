import '../utils/date_formatter.dart';

class TodoValidator {
  TodoValidator._();

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  static String? validateDueDate(
    DateTime dueDate, {
    DateTime? originalDueDate,
  }) {
    if (originalDueDate != null &&
        DateFormatter.dateOnly(dueDate) ==
            DateFormatter.dateOnly(originalDueDate)) {
      return null;
    }

    if (DateFormatter.isBeforeToday(dueDate)) {
      return 'Due date cannot be in the past';
    }
    return null;
  }
}
