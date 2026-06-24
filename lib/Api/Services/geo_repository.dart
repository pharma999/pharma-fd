import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';

// Backend-controlled geo/booking configuration — fetched on app start.
// Shape matches GeoSettings in the backend models.
class GeoConfig {
  final double defaultRadiusKm;
  final double maxRadiusKm;
  final bool autoExpandRadius;
  final int bookingTimeoutSec;
  final bool enableRingtone;

  const GeoConfig({
    this.defaultRadiusKm = 10,
    this.maxRadiusKm = 50,
    this.autoExpandRadius = true,
    this.bookingTimeoutSec = 60,
    this.enableRingtone = true,
  });

  factory GeoConfig.fromJson(Map<String, dynamic> j) => GeoConfig(
        defaultRadiusKm: (j['default_radius_km'] ?? 10).toDouble(),
        maxRadiusKm: (j['max_radius_km'] ?? 50).toDouble(),
        autoExpandRadius: j['auto_expand_radius'] ?? true,
        bookingTimeoutSec: (j['booking_timeout_sec'] ?? 60) as int,
        enableRingtone: j['enable_ringtone'] ?? true,
      );
}

class GeoRepository {
  final _client = ApiClient();

  /// Fetches the backend-controlled geo/booking configuration.
  /// No auth required — safe to call before login.
  Future<GeoConfig> getGeoSettings() async {
    try {
      final res = await _client.get('config/geo-settings', requiresAuth: false);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      return GeoConfig.fromJson(data);
    } catch (_) {
      return const GeoConfig(); // safe defaults
    }
  }

  /// Sends patient GPS coordinates to the backend.
  Future<void> updatePatientLocation(double lat, double lng) async {
    try {
      await _client.post(
        'patient/location',
        {'latitude': lat, 'longitude': lng},
        requiresAuth: true,
      );
    } catch (_) {}
  }

  /// Fetches nearby approved providers sorted by distance.
  /// [radius] in kilometres (default 5).
  Future<ApiResult<List<Map<String, dynamic>>>> getNearbyProviders({
    required double lat,
    required double lng,
    double radius = 5,
    String category = '',
  }) async {
    try {
      final params = <String, String>{
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
        if (category.isNotEmpty) 'category': category,
      };
      final res = await _client.get(
        'providers/nearby',
        requiresAuth: true,
        queryParams: params,
      );
      final raw = res['data'];
      if (raw is List) {
        return Success(
          raw.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
      }
      return const Success([]);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Fetches ALL super-admin-approved providers regardless of availability.
  /// Uses GET /nurses/approved — no is_available filter, clean list response.
  Future<List<Map<String, dynamic>>> getAllApprovedProviders() async {
    try {
      final res = await _client.get(
        'nurses/approved',
        requiresAuth: true,
      );
      // Backend returns: {"status":200, "data": [...]}
      final raw = res['data'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetches nearby patients (used by the provider app).
  Future<List<Map<String, dynamic>>> getNearbyPatients({
    required double lat,
    required double lng,
    double radius = 5,
  }) async {
    try {
      final res = await _client.get(
        'patients/nearby',
        requiresAuth: true,
        queryParams: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radius': radius.toString(),
        },
      );
      final raw = res['data'];
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
