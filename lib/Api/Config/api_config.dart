import 'package:flutter/foundation.dart';

// Override at build time:
//   flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080/api
//
// Current server LAN IP: 192.168.1.7
// - Android emulator  → 10.0.2.2:8080
// - Physical device   → 192.168.1.7:8080  (same WiFi as dev machine)
// - Linux desktop     → localhost:8080
class ApiConfig {
  static const String _serverLanIp = '192.168.1.7';

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:8080/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 only works on the Android emulator.
      // Physical Android devices need the LAN IP of the dev machine.
      return 'http://$_serverLanIp:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://$_serverLanIp:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const int timeout = 30;
}
