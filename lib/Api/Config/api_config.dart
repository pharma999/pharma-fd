import 'package:flutter/foundation.dart';

// Override at build time: flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080/api
class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const int timeout = 30;
}
