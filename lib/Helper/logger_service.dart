import 'package:flutter/foundation.dart';

/// Centralized logging service with different severity levels
class LoggerService {
  static void debug(String message) {
    if (kDebugMode) {
      print('🔵 DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(
    String message, [
    dynamic exception,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (exception != null) {
        print('Exception: $exception');
      }
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }
}
