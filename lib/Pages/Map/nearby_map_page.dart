import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_care/Api/Services/hospital_repository.dart';
import 'package:home_care/Api/Services/websocket_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// NearbyMapPage shows:
///   • User's current location (blue dot)
///   • Nearby hospitals as red/green markers
///   • Live ambulance position when tracking an emergency
class NearbyMapPage extends StatefulWidget {
  final String? trackEmergencyId; // if set, subscribes to ambulance WS updates
  const NearbyMapPage({super.key, this.trackEmergencyId});

  @override
  State<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends State<NearbyMapPage> {
  final HospitalRepository _hospitalRepo = HospitalRepository();
  final Completer<GoogleMapController> _mapController = Completer();

  Position? _userPosition;
  List<HospitalModel> _hospitals = [];
  final Map<MarkerId, Marker> _markers = {};

  // Ambulance real-time
  Marker? _ambulanceMarker;
  StreamSubscription<WsMessage>? _wsSub;

  bool _loading = true;
  String? _error;

  static const _defaultPosition = LatLng(26.8467, 80.9462); // Lucknow

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getUserLocation();
    await _loadHospitals();
    if (widget.trackEmergencyId != null) {
      _subscribeAmbulance(widget.trackEmergencyId!);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        14,
      ));
    } catch (_) {}
  }

  Future<void> _loadHospitals() async {
    setState(() => _loading = true);

    final result = await _hospitalRepo.getNearbyHospitals(
      lat: _userPosition?.latitude,
      lng: _userPosition?.longitude,
      radiusMetres: 15000,
    );

    result.when(
      onSuccess: (hospitals) {
        _hospitals = hospitals;
        _buildHospitalMarkers();
        setState(() => _loading = false);
      },
      onError: (err) => setState(() {
        _error = err;
        _loading = false;
      }),
    );
  }

  void _buildHospitalMarkers() {
    _markers.clear();
    for (final h in _hospitals) {
      final lat = double.tryParse(h.latitude);
      final lng = double.tryParse(h.longitude);
      if (lat == null || lng == null) continue;

      final id = MarkerId(h.hospitalId);
      _markers[id] = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          h.hasEmergency
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: h.name,
          snippet: h.hasEmergency
              ? '🚑 Emergency • ${h.ambulanceCount} ambulance(s)'
              : h.city,
          onTap: () => _showHospitalSheet(h),
        ),
      );
    }
    setState(() {});
  }

  void _subscribeAmbulance(String emergencyId) {
    final ws = WebSocketService.instance;
    ws.subscribe('emergency:$emergencyId');

    _wsSub = ws.messages.listen((msg) {
      if (msg.type == WsMessageType.ambulanceLocation) {
        final lat = double.tryParse(msg.payload['latitude']?.toString() ?? '');
        final lng = double.tryParse(msg.payload['longitude']?.toString() ?? '');
        if (lat != null && lng != null && mounted) {
          final id = const MarkerId('ambulance');
          setState(() {
            _ambulanceMarker = Marker(
              markerId: id,
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
              infoWindow: const InfoWindow(title: '🚑 Ambulance en route'),
            );
          });
        }
      }
    });
  }

  void _showHospitalSheet(HospitalModel h) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(h.address, style: const TextStyle(color: Colors.grey)),
            if (h.distanceKm > 0)
              Text('${h.distanceKm.toStringAsFixed(1)} km away',
                  style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            if (h.hasEmergency)
              Row(children: [
                const Icon(Icons.emergency, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text('${h.ambulanceCount} ambulance(s) available',
                    style: const TextStyle(color: Colors.red)),
              ]),
            if (h.operatingHours.isNotEmpty)
              Text('Hours: ${h.operatingHours}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callHospital(h.phoneNumber),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openDirections(h),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _openDirections(HospitalModel h) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${h.latitude},${h.longitude}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : _defaultPosition;

    final allMarkers = {
      ..._markers,
      if (_ambulanceMarker != null)
        _ambulanceMarker!.markerId: _ambulanceMarker!,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackEmergencyId != null
            ? 'Tracking Ambulance'
            : 'Nearby Hospitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHospitals,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLatLng,
              zoom: 13,
            ),
            onMapCreated: (c) => _mapController.complete(c),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: allMarkers.values.toSet(),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Row(children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text('Emergency hospital', style: TextStyle(fontSize: 12)),
                    ]),
                    Row(children: [
                      Icon(Icons.location_on, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text('General hospital', style: TextStyle(fontSize: 12)),
                    ]),
                    Row(children: [
                      Icon(Icons.local_shipping,
                          color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text('Your ambulance', style: TextStyle(fontSize: 12)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
