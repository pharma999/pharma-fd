import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Pages/Call/video_call_page.dart';
import 'package:home_care/Pages/Chat/booking_chat_utils.dart';
import 'package:home_care/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' hide Path; // latlong2.Path conflicts with dart:ui.Path in CustomPainter
import 'package:url_launcher/url_launcher.dart';

// ── Booking Tracking Page ─────────────────────────────────────────────────────
// Uses OpenStreetMap tiles (no API key) + OSRM routing (free, open-source).
// Provider marker animates smoothly between GPS updates every 4 s.

class BookingTrackingPage extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String status;
  final String? providerPhone;

  const BookingTrackingPage({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.status,
    this.providerPhone,
  });

  @override
  State<BookingTrackingPage> createState() => _BookingTrackingPageState();
}

class _BookingTrackingPageState extends State<BookingTrackingPage>
    with TickerProviderStateMixin {
  final _client = ApiClient();
  final _mapController = MapController();

  // ── App state ─────────────────────────────────────────────────────────────
  late String _status;
  String _providerName = '';
  String _providerCategory = '';
  String _providerPhone = '';
  String _nurseUserId = '';   // provider's user_id — needed for video call
  bool _calling = false;
  double _distanceKm = 0;
  int _etaMinutes = 0;

  // ── Map state ─────────────────────────────────────────────────────────────
  LatLng? _providerLoc;
  LatLng? _patientLoc;
  List<LatLng> _routePoints = [];
  bool _routeFetched = false;
  double _heading = 0; // bearing in degrees from north

  // Smooth animation between GPS updates
  Timer? _animTimer;
  LatLng? _animFrom;

  // ── WebSocket ─────────────────────────────────────────────────────────────
  WebSocket? _ws;
  Timer? _wsReconnect;
  Timer? _pollTimer;
  bool _disposed = false;

  // Booking status steps
  static const _steps = [
    _Step('PENDING',     'Placed',     Icons.receipt_long_rounded),
    _Step('ASSIGNED',    'Assigned',   Icons.person_pin_rounded),
    _Step('ACCEPTED',    'En Route',   Icons.directions_run_rounded),
    _Step('IN_PROGRESS', 'In Service', Icons.engineering_rounded),
    _Step('COMPLETED',   'Done',       Icons.verified_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _providerPhone = widget.providerPhone ?? '';
    _fetchTracking();
    _connectWS();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_disposed &&
          _status != 'COMPLETED' &&
          _status != 'CANCELLED') {
        _fetchTracking();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _ws?.close();
    _wsReconnect?.cancel();
    _pollTimer?.cancel();
    _animTimer?.cancel();
    super.dispose();
  }

  // ── WebSocket ─────────────────────────────────────────────────────────────

  Future<void> _connectWS() async {
    if (_disposed) return;
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return;
      final wsBase = ApiConfig.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceAll('/api', '');
      final room = Uri.encodeComponent('booking:${widget.bookingId}');
      final uri = '$wsBase/api/ws?token=${Uri.encodeComponent(token)}&rooms=$room';
      _ws = await WebSocket.connect(uri).timeout(const Duration(seconds: 10));
      if (_disposed) { _ws?.close(); return; }
      _ws!.listen(_onWsMessage,
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
          cancelOnError: false);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _ws = null;
    _wsReconnect?.cancel();
    _wsReconnect = Timer(const Duration(seconds: 4), () {
      if (!_disposed) _connectWS();
    });
  }

  void _onWsMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String? ?? '';
      final rawP = msg['payload'];
      final p = rawP is String
          ? jsonDecode(rawP) as Map<String, dynamic>
          : Map<String, dynamic>.from(rawP as Map);

      if (type == 'booking_location') {
        final lat  = (p['latitude']    as num?)?.toDouble();
        final lng  = (p['longitude']   as num?)?.toDouble();
        final dist = (p['distance_km'] as num?)?.toDouble() ?? _distanceKm;
        final eta  = (p['eta_minutes'] as num?)?.toInt()    ?? _etaMinutes;
        if (lat != null && lng != null && mounted) {
          _animateProviderTo(LatLng(lat, lng));
          setState(() { _distanceKm = dist; _etaMinutes = eta; });
        }
      } else if (type == 'booking_update') {
        final status = p['status'] as String? ?? '';
        final svcName = p['service_name'] as String? ?? '';
        if (status.isNotEmpty && mounted) {
          setState(() { _status = status; });
          if (status == 'COMPLETED') _pollTimer?.cancel();
        }
        if (svcName.isNotEmpty) setState(() => _providerName = svcName);
      }
    } catch (_) {}
  }

  // ── REST polling ──────────────────────────────────────────────────────────

  Future<void> _fetchTracking() async {
    try {
      final res = await _client.get(
          'bookings/${widget.bookingId}/tracking', requiresAuth: true);
      final d = res['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;

      final hasLoc = d['has_location'] == true;
      setState(() {
        _status           = (d['status'] as String? ?? _status).isNotEmpty ? d['status']! : _status;
        _providerName     = d['provider_name']     as String? ?? _providerName;
        _providerCategory = d['provider_category'] as String? ?? _providerCategory;
        if ((d['nurse_user_id'] as String? ?? '').isNotEmpty) {
          _nurseUserId = d['nurse_user_id'] as String;
        }
        if (hasLoc) {
          _distanceKm = (d['distance_km'] as num?)?.toDouble() ?? _distanceKm;
          _etaMinutes = (d['eta_minutes'] as num?)?.toInt()    ?? _etaMinutes;
        }
      });

      if (hasLoc) {
        final pLat = (d['provider_lat'] as num?)?.toDouble();
        final pLng = (d['provider_lng'] as num?)?.toDouble();
        final ptLat = (d['patient_lat']  as num?)?.toDouble();
        final ptLng = (d['patient_lng']  as num?)?.toDouble();

        if (pLat != null && pLng != null) {
          _animateProviderTo(LatLng(pLat, pLng));
        }
        if (ptLat != null && ptLng != null && ptLat != 0) {
          if (mounted) setState(() => _patientLoc = LatLng(ptLat, ptLng));
        }
        // Fetch route once from OSRM when we have both locations
        if (!_routeFetched && _providerLoc != null && _patientLoc != null) {
          _routeFetched = true;
          _fetchRoute(_providerLoc!, _patientLoc!);
        }
      }
    } catch (_) {}
  }

  // ── OSRM route (OpenStreetMap routing — free, no key) ─────────────────────

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};'
          '${to.longitude},${to.latitude}'
          '?geometries=geojson&overview=full';
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        _setFallbackRoute(from, to);
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        _setFallbackRoute(from, to);
        return;
      }
      final coords = routes[0]['geometry']['coordinates'] as List;
      final points = coords
          .map((c) => LatLng(
              (c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      if (mounted) setState(() => _routePoints = points);
    } catch (_) {
      _setFallbackRoute(from, to);
    }
  }

  void _setFallbackRoute(LatLng from, LatLng to) {
    if (mounted) setState(() => _routePoints = [from, to]);
  }

  // ── Smooth marker animation ───────────────────────────────────────────────

  void _animateProviderTo(LatLng newLoc) {
    if (!mounted) return;
    final from = _providerLoc;

    // Calculate bearing before updating position
    if (from != null && from != newLoc) {
      _heading = _calcBearing(from, newLoc);
    }

    if (from == null) {
      setState(() => _providerLoc = newLoc);
      _moveCameraTo(newLoc);
      return;
    }

    _animFrom = from;
    _animTimer?.cancel();
    const totalSteps = 16; // 16 × 50 ms = 800 ms
    int step = 0;
    _animTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      final frac = step / totalSteps;
      final lat = _animFrom!.latitude  + (newLoc.latitude  - _animFrom!.latitude)  * frac;
      final lng = _animFrom!.longitude + (newLoc.longitude - _animFrom!.longitude) * frac;
      final cur = LatLng(lat, lng);
      setState(() => _providerLoc = cur);
      _moveCameraTo(cur);
      if (step >= totalSteps) { t.cancel(); _animFrom = null; }
    });
  }

  void _moveCameraTo(LatLng loc) {
    try {
      _mapController.move(loc, _mapController.camera.zoom);
    } catch (_) {}
  }

  double _calcBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude  * math.pi / 180;
    final lat2 = to.latitude    * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _callProvider() async {
    if (_providerPhone.isEmpty) {
      Get.snackbar('No phone', 'Provider phone not available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri.parse('tel:$_providerPhone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _cancelBooking() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kError),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _client.post('bookings/${widget.bookingId}/cancel', {}, requiresAuth: true);
      if (mounted) setState(() => _status = 'CANCELLED');
      Get.snackbar('Cancelled', 'Your booking has been cancelled',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showCallSnackbar(String title, String msg) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.snackbar(title, msg,
            backgroundColor: kError.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Future<void> _startVideoCall() async {
    if (_calling || _nurseUserId.isEmpty) {
      _showCallSnackbar('Unavailable',
          _nurseUserId.isEmpty
              ? 'Provider not yet assigned'
              : 'Call already in progress');
      return;
    }
    if (_status != 'ACCEPTED' && _status != 'IN_PROGRESS') {
      _showCallSnackbar('Unavailable',
          'Video call is only available once provider is on the way.');
      return;
    }
    setState(() => _calling = true);
    try {
      final res = await _client.post('calls', {
        'booking_id': widget.bookingId,
        'callee_id':  _nurseUserId,
      }, requiresAuth: true);
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final callId = data['call_id'] as String? ?? '';
      if (callId.isEmpty) throw Exception('No call_id returned');
      if (!mounted) return;
      Get.to(() => VideoCallPage(
            callId:       callId,
            remoteUserId: _nurseUserId,
            remoteName:   _providerName.isNotEmpty ? _providerName : 'Provider',
            bookingId:    widget.bookingId,
            isCaller:     true,
          ));
    } catch (e) {
      _showCallSnackbar('Call Failed', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _calling = false);
    }
  }

  Future<void> _fitBothMarkers() async {
    // If patient location isn't stored in the booking, try device GPS as fallback
    if (_patientLoc == null) {
      await _tryFetchPatientGps();
    }

    final points = <LatLng>[
      if (_providerLoc != null) _providerLoc!,
      if (_patientLoc  != null) _patientLoc!,
    ];

    if (points.isEmpty) {
      Get.snackbar(
        'Location Unavailable',
        'Provider location not received yet. Please wait a moment.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      if (points.length == 1) {
        // Only one location known — just centre on it
        _mapController.move(points.first, 15);
      } else {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: points,
            padding: const EdgeInsets.all(70),
          ),
        );
      }
    } catch (_) {
      // MapController not ready yet (map still building) — ignore silently
    }
  }

  /// Silently tries to get current device GPS to use as the patient's location
  /// when it wasn't stored in the booking (e.g. patient denied GPS at booking time).
  Future<void> _tryFetchPatientGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        setState(() => _patientLoc = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

  // ── Status helpers ────────────────────────────────────────────────────────

  Color get _statusColor {
    switch (_status) {
      case 'ASSIGNED':    return kWarning;
      case 'ACCEPTED':    return kPrimary;
      case 'IN_PROGRESS': return kPurple;
      case 'COMPLETED':   return kSuccess;
      case 'CANCELLED':   return kError;
      default:            return kWarning;
    }
  }

  String get _statusLabel {
    switch (_status) {
      case 'PENDING':     return 'Waiting for Provider';
      case 'ASSIGNED':    return 'Provider Assigned';
      case 'ACCEPTED':    return 'En Route to You';
      case 'IN_PROGRESS': return 'Service In Progress';
      case 'COMPLETED':   return 'Completed';
      case 'CANCELLED':   return 'Cancelled';
      default:            return _status.replaceAll('_', ' ');
    }
  }

  int get _stepIndex {
    if (_status == 'CANCELLED') return -1;
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].status == _status) return i;
    }
    return 0;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isActive = _status != 'COMPLETED' && _status != 'CANCELLED';
    final initialCenter =
        _providerLoc ?? _patientLoc ?? const LatLng(20.5937, 78.9629);

    return Scaffold(
      body: Stack(
        children: [
          // ── OpenStreetMap full-screen ───────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                // OSM tile layer
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.homecare.patient',
                  maxZoom: 19,
                ),
                // Route polyline
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: kPrimary.withValues(alpha: 0.85),
                        strokeWidth: 5,
                        borderColor: kPrimaryDark.withValues(alpha: 0.3),
                        borderStrokeWidth: 1,
                      ),
                    ],
                  ),
                // Patient / destination marker
                if (_patientLoc != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _patientLoc!,
                      width: 48,
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      child: const _DestinationPin(),
                    ),
                  ]),
                // Provider / vehicle marker
                if (_providerLoc != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _providerLoc!,
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      child: _VehicleMarker(heading: _heading),
                    ),
                  ]),
                // OSM attribution (required by terms)
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors',
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright'))),
                  ],
                ),
              ],
            ),
          ),

          // ── Top status bar ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildTopBar(),
          ),

          // ── Bottom sheet ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomSheet(isActive),
          ),

          // ── Fit-both FAB ────────────────────────────────────────────────
          if (_providerLoc != null && _patientLoc != null)
            Positioned(
              right: 16,
              bottom: isActive ? 330 : 250,
              child: FloatingActionButton.small(
                heroTag: 'fitBoth',
                backgroundColor: Colors.white,
                foregroundColor: kPrimary,
                elevation: 4,
                onPressed: _fitBothMarkers,
                child: const Icon(Icons.fit_screen_rounded),
              ),
            ),

          // ── Refresh FAB ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: isActive ? 385 : 305,
            child: FloatingActionButton.small(
              heroTag: 'refresh',
              backgroundColor: Colors.white,
              foregroundColor: kPrimary,
              elevation: 4,
              onPressed: _fetchTracking,
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _CircleBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            // Video call button — only shown when booking is active
            if (_status == 'ACCEPTED' || _status == 'IN_PROGRESS') ...[
              _CircleBtn(
                icon: _calling
                    ? Icons.hourglass_top_rounded
                    : Icons.videocam_rounded,
                color: kPrimary,
                onTap: _startVideoCall,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _statusColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_statusLabel,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _statusColor),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(bool isActive) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ETA strip (shown while en route)
                if (_status == 'ACCEPTED' || _status == 'ASSIGNED')
                  _buildEtaStrip(),

                // Provider info row
                _buildProviderRow(),
                const SizedBox(height: 14),

                // Horizontal status stepper
                _buildStepper(),
                const SizedBox(height: 14),

                // Action buttons
                if (isActive) _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaStrip() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _etaCol('Distance',
              _distanceKm > 0 ? '${_distanceKm.toStringAsFixed(1)} km' : '—'),
          const SizedBox(width: 20),
          Container(width: 1, height: 32,
              color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 20),
          _etaCol('Arriving in',
              _etaMinutes > 0 ? '$_etaMinutes min' : '—'),
          const Spacer(),
          const Icon(Icons.two_wheeler_rounded, color: Colors.white70, size: 28),
        ],
      ),
    );
  }

  Widget _etaCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildProviderRow() {
    return Row(
      children: [
        // Gradient avatar
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [kPrimary, kPrimaryMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: kPrimary.withValues(alpha: 0.3), blurRadius: 8)
            ],
          ),
          child: Center(
            child: Text(
              _providerName.isNotEmpty ? _providerName[0].toUpperCase() : 'P',
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _providerName.isNotEmpty ? _providerName : widget.serviceName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
              ),
              if (_providerCategory.isNotEmpty)
                Text(_providerCategory.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 12, color: kTextMedium)),
            ],
          ),
        ),
        _CircleBtn(
          icon: Icons.chat_bubble_outline_rounded,
          color: kPrimary,
          onTap: () => openBookingChat(widget.bookingId),
        ),
        const SizedBox(width: 8),
        if (_providerPhone.isNotEmpty)
          _CircleBtn(
            icon: Icons.phone_rounded,
            color: kSuccess,
            onTap: _callProvider,
          ),
      ],
    );
  }

  Widget _buildStepper() {
    final cur = _stepIndex;
    if (cur < 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kError.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kError.withValues(alpha: 0.2)),
        ),
        child: const Row(children: [
          Icon(Icons.cancel_rounded, color: kError, size: 18),
          SizedBox(width: 10),
          Text('Booking cancelled.', style: TextStyle(color: kError, fontSize: 13)),
        ]),
      );
    }
    return Row(
      children: List.generate(_steps.length, (i) {
        final done   = i <= cur;
        final active = i == cur;
        return Expanded(
          child: Row(children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 30 : 22,
                height: active ? 30 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? kPrimary : Colors.grey.shade200,
                  boxShadow: active
                      ? [BoxShadow(color: kPrimary.withValues(alpha: 0.4), blurRadius: 6)]
                      : [],
                ),
                child: Icon(
                  done ? Icons.check_rounded : _steps[i].icon,
                  color: done ? Colors.white : Colors.grey,
                  size: active ? 15 : 11,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 50,
                child: Text(_steps[i].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 8,
                        color: done ? kPrimary : kTextLight,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal)),
              ),
            ]),
            if (i < _steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: i < cur ? kPrimary : Colors.grey.shade200,
                ),
              ),
          ]),
        );
      }),
    );
  }

  Widget _buildActions() {
    final canCancel = _status == 'PENDING' || _status == 'ASSIGNED';
    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cancelBooking,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kError,
                side: BorderSide(color: kError.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: canCancel ? 2 : 1,
          child: ElevatedButton.icon(
            onPressed: _fitBothMarkers,
            icon: const Icon(Icons.map_rounded, size: 16),
            label: const Text('Show on Map', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Markers ────────────────────────────────────────────────────────────

/// Animated vehicle marker that rotates to match the provider's heading.
class _VehicleMarker extends StatefulWidget {
  final double heading;
  const _VehicleMarker({this.heading = 0});

  @override
  State<_VehicleMarker> createState() => _VehicleMarkerState();
}

class _VehicleMarkerState extends State<_VehicleMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.88, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Transform.rotate(
        angle: widget.heading * math.pi / 180,
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: kPrimary.withValues(alpha: 0.55),
                  blurRadius: 14,
                  spreadRadius: 1)
            ],
          ),
          child: const Icon(Icons.two_wheeler_rounded,
              color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

/// Fixed destination pin (patient's location).
class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: kSuccess,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: kSuccess.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 1)
            ],
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 24),
        ),
        // Pin needle
        CustomPaint(
          size: const Size(14, 10),
          painter: _NeedlePainter(kSuccess),
        ),
      ],
    );
  }
}

class _NeedlePainter extends CustomPainter {
  final Color color;
  const _NeedlePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter o) => o.color != color;
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _CircleBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final fg = color ?? kTextDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)
          ],
        ),
        child: Icon(icon, size: 18, color: fg),
      ),
    );
  }
}

class _Step {
  final String status;
  final String label;
  final IconData icon;
  const _Step(this.status, this.label, this.icon);
}
