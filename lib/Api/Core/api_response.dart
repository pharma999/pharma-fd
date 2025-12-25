class ApiResponse<T> {
  final T data;
  final bool success;
  final String? message;

  ApiResponse({
    required this.data,
    required this.success,
    this.message

  });
}
