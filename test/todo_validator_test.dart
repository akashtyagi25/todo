import 'package:flutter_test/flutter_test.dart';

import 'package:todo/utils/date_formatter.dart';
import 'package:todo/utils/todo_validator.dart';

void main() {
  group('TodoValidator', () {
    test('requires title', () {
      expect(TodoValidator.validateTitle(null), 'Title is required');
      expect(TodoValidator.validateTitle('   '), 'Title is required');
      expect(TodoValidator.validateTitle('Buy milk'), isNull);
    });

    test('rejects past due dates', () {
      final yesterday = DateFormatter.today().subtract(const Duration(days: 1));
      expect(
        TodoValidator.validateDueDate(yesterday),
        'Due date cannot be in the past',
      );
      expect(TodoValidator.validateDueDate(DateFormatter.today()), isNull);
    });

    test('allows keeping original due date when editing', () {
      final yesterday = DateFormatter.today().subtract(const Duration(days: 1));
      expect(
        TodoValidator.validateDueDate(
          yesterday,
          originalDueDate: yesterday,
        ),
        isNull,
      );
    });
  });
}
