import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_care/Api/Services/geo_repository.dart';

class GeoController extends GetxController {
  final _repo = GeoRepository();

  // ── Location state ────────────────────────────────────────────────────────
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxBool locationReady = false.obs;
  final RxBool isLocating = false.obs;
  final RxString locationError = ''.obs;

  /// Human-readable address from reverse geocoding (shown in the header).
  final RxString currentAddress = 'Fetching location…'.obs;

  /// Search query — filters the Top Professionals list reactively.
  final RxString searchQuery = ''.obs;

  void search(String q) => searchQuery.value = q.trim().toLowerCase();
  void clearSearch() => searchQuery.value = '';

  // ── Provider state ────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> approvedProviders =
      <Map<String, dynamic>>[].obs;
  final RxBool loadingProviders = false.obs;

  // Backend-controlled radius — loaded once on fetchAndSync()
  double _radiusKm = 10;

  // Live location stream subscription
  StreamSubscription<Position>? _liveStream;

  @override
  void onClose() {
    _liveStream?.cancel();
    super.onClose();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called from HomePageUi.initState() — user is already logged in.
  Future<void> fetchAndSync() async {
    isLocating.value = true;
    currentAddress.value = 'Fetching location…';
    locationError.value = '';

    // Fetch backend-controlled radius before anything else
    final cfg = await _repo.getGeoSettings();
    _radiusKm = cfg.defaultRadiusKm;

    // Load approved providers immediately (no GPS needed)
    await _fetchAllApproved();

    // Get GPS
    try {
      final pos = await _getPosition();
      if (pos != null) {
        await _applyPosition(pos);
        _startLiveStream(); // keep updating as user moves
      } else {
        currentAddress.value = 'Tap to enable location';
      }
    } catch (e) {
      locationError.value = e.toString();
      currentAddress.value = 'Tap to retry location';
    } finally {
      isLocating.value = false;
    }
  }

  /// Tapped the location icon — refreshes GPS immediately.
  Future<void> refreshLocation() async {
    if (isLocating.value) return;
    isLocating.value = true;
    currentAddress.value = 'Updating…';
    try {
      final pos = await _getPosition();
      if (pos != null) {
        await _applyPosition(pos);
        _startLiveStream();
      } else {
        currentAddress.value = 'Location unavailable';
      }
    } catch (e) {
      locationError.value = e.toString();
      currentAddress.value = 'Location unavailable';
    } finally {
      isLocating.value = false;
    }
  }

  // Keep backward compat
  Future<void> fetchNearby({double? radius}) => _enrichWithDistance();

  @override
  // ignore: must_call_super
  Future<void> refresh() async {
    await _fetchAllApproved();
    if (locationReady.value) await _enrichWithDistance();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _applyPosition(Position pos) async {
    lat.value = pos.latitude;
    lng.value = pos.longitude;
    locationReady.value = true;

    // Reverse geocode to human-readable address
    _reverseGeocode(pos.latitude, pos.longitude);

    // Push to backend (fire-and-forget)
    _repo.updatePatientLocation(pos.latitude, pos.longitude);

    // Enrich providers with distance
    await _enrichWithDistance();
  }

  /// Reverse-geocodes [lat]/[lng] and updates [currentAddress].
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        currentAddress.value = parts.isNotEmpty ? parts : '$lat, $lng';
      }
    } catch (_) {
      currentAddress.value =
          '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  /// Starts a live Geolocator position stream to keep the address current.
  void _startLiveStream() {
    _liveStream?.cancel();
    _liveStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // only update when moved 100 m
      ),
    ).listen((pos) {
      lat.value = pos.latitude;
      lng.value = pos.longitude;
      _reverseGeocode(pos.latitude, pos.longitude);
      _repo.updatePatientLocation(pos.latitude, pos.longitude);
    });
  }

  Future<void> _fetchAllApproved() async {
    loadingProviders.value = true;
    try {
      final list = await _repo.getAllApprovedProviders();
      approvedProviders.assignAll(list);
    } catch (_) {
      approvedProviders.clear();
    } finally {
      loadingProviders.value = false;
    }
  }

  Future<void> _enrichWithDistance() async {
    if (!locationReady.value) return;
    final result = await _repo.getNearbyProviders(
      lat: lat.value,
      lng: lng.value,
      radius: _radiusKm, // backend-controlled, no hardcoded value
    );
    result.when(
      onSuccess: (nearby) {
        final distMap = <String, double>{};
        for (final n in nearby) {
          final id = n['nurse_id']?.toString() ?? '';
          if (id.isNotEmpty) {
            distMap[id] = (n['distance_km'] ?? 0).toDouble();
          }
        }
        final enriched = approvedProviders.map((p) {
          final id = p['nurse_id']?.toString() ?? '';
          final dist = distMap[id];
          return dist != null
              ? (Map<String, dynamic>.from(p)..['distance_km'] = dist)
              : p;
        }).toList();

        enriched.sort((a, b) {
          final da = (a['distance_km'] as double?) ?? double.infinity;
          final db = (b['distance_km'] as double?) ?? double.infinity;
          return da.compareTo(db);
        });
        approvedProviders.assignAll(enriched);
      },
      onError: (_) {},
    );
  }

  Future<Position?> _getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      locationError.value = 'Location services disabled.';
      return null;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      locationError.value = 'Location permission denied.';
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}
