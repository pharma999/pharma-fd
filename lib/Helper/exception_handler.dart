import 'package:home_care/Api/Core/api_exception.dart';
import 'logger_service.dart';

/// Centralized exception handling with user-friendly messages
class ExceptionHandler {
  static String getErrorMessage(dynamic exception) {
    if (exception is ApiException) {
      LoggerService.error('ApiException', exception.message);
      return exception.message;
    }

    if (exception is FormatException) {
      LoggerService.error('FormatException', exception.message);
      return 'Invalid response format. Please try again.';
    }

    if (exception is TimeoutException) {
      LoggerService.error('TimeoutException', 'Request timed out');
      return 'Request timed out. Please check your connection.';
    }

    LoggerService.error('Unknown Exception', exception.toString());
    return 'An unexpected error occurred. Please try again.';
  }

  static bool isNetworkError(dynamic exception) {
    final message = exception.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('failed host lookup');
  }

  static bool isTimeoutError(dynamic exception) {
    return exception is TimeoutException ||
        exception.toString().toLowerCase().contains('timeout');
  }

  static bool isUnauthorizedError(dynamic exception) {
    return exception.toString().contains('401') ||
        exception.toString().contains('Unauthorized');
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
