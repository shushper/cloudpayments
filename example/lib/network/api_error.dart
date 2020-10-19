class ApiError implements Exception {
  final String message;

  ApiError(this.message);

  @override
  String toString() {
    return '$message';
  }
}