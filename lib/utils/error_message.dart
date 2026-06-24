import 'package:hive/hive.dart';

import '../core/errors/app_exception.dart';

class ErrorMessage {
  ErrorMessage._();

  static String from(Object error) {
    if (error is AppException) return error.message;
    if (error is HiveError) {
      return 'Storage error. Please restart the app and try again.';
    }
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
