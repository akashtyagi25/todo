class OperationResult {
  const OperationResult._({required this.success, this.errorMessage});

  const OperationResult.success() : this._(success: true);

  const OperationResult.failure(String message)
      : this._(success: false, errorMessage: message);

  final bool success;
  final String? errorMessage;
}
