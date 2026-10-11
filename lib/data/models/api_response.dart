class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
  });
}
