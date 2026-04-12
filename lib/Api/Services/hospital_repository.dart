import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';

class HospitalModel {
  final String hospitalId;
  final String name;
  final String address;
  final String city;
  final String phoneNumber;
  final String latitude;
  final String longitude;
  final bool hasEmergency;
  final int ambulanceCount;
  final String operatingHours;
  final String specialties;
  final double distanceKm;

  const HospitalModel({
    required this.hospitalId,
    required this.name,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.hasEmergency,
    required this.ambulanceCount,
    required this.operatingHours,
    required this.specialties,
    required this.distanceKm,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> j) => HospitalModel(
        hospitalId: j['hospital_id'] ?? '',
        name: j['name'] ?? '',
        address: j['address'] ?? '',
        city: j['city'] ?? '',
        phoneNumber: j['phone_number'] ?? '',
        latitude: j['latitude'] ?? '',
        longitude: j['longitude'] ?? '',
        hasEmergency: j['has_emergency'] == true,
        ambulanceCount: (j['ambulance_count'] as num?)?.toInt() ?? 0,
        operatingHours: j['operating_hours'] ?? '',
        specialties: j['specialties'] ?? '',
        distanceKm: (j['distance_km'] as num?)?.toDouble() ?? 0.0,
      );
}

class HospitalRepository {
  final ApiClient _client = ApiClient();

  /// Fetch nearby hospitals.
  /// Pass [lat] and [lng] for geo search, [radiusMetres] to control distance.
  /// Pass [city] as fallback when location is unavailable.
  Future<ApiResult<List<HospitalModel>>> getNearbyHospitals({
    double? lat,
    double? lng,
    double radiusMetres = 10000,
    bool? hasEmergency,
    String? city,
  }) async {
    try {
      final params = <String, String>{};
      if (lat != null) params['lat'] = lat.toStringAsFixed(6);
      if (lng != null) params['lng'] = lng.toStringAsFixed(6);
      if (lat != null) params['radius'] = radiusMetres.toStringAsFixed(0);
      if (hasEmergency == true) params['has_emergency'] = 'true';
      if (city != null && city.isNotEmpty) params['city'] = city;

      final response = await _client.get(
        ApiEndpoints.nearbyHospitals,
        requiresAuth: true,
        queryParams: params,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => HospitalModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<HospitalModel>> getHospital(String id) async {
    try {
      final response = await _client.get(
        ApiEndpoints.hospitalDetail(id),
        requiresAuth: true,
      );
      return Success(HospitalModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
