class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class StorageException extends AppException {
  const StorageException([
    super.message = 'Unable to save or load tasks. Please try again.',
  ]);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Task not found.']);
}
