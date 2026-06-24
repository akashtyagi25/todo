import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:todo/core/errors/app_exception.dart';
import 'package:todo/utils/error_message.dart';

void main() {
  group('ErrorMessage', () {
    test('maps app exceptions to user message', () {
      expect(
        ErrorMessage.from(const ValidationException('Title is required')),
        'Title is required',
      );
      expect(
        ErrorMessage.from(const StorageException()),
        'Unable to save or load tasks. Please try again.',
      );
    });

    test('maps hive errors to storage message', () {
      expect(
        ErrorMessage.from(HiveError('Box not found')),
        'Storage error. Please restart the app and try again.',
      );
    });

    test('maps unknown errors to generic message', () {
      expect(
        ErrorMessage.from(Exception('boom')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
