import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/wallet_repository.dart';
import 'package:home_care/utils/token_storage.dart';

class BookingTrackingPage extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String status;

  const BookingTrackingPage({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.status,
  });

  @override
  State<BookingTrackingPage> createState() => _BookingTrackingPageState();
}

class _BookingTrackingPageState extends State<BookingTrackingPage> {
  final _repo = WalletRepository();

  // Status tracking
  late String _status;

  // Map
  GoogleMapController? _mapCtrl;
  LatLng? _providerLoc;
  static const _defaultCam = CameraPosition(
    target: LatLng(20.5937, 78.9629), // India center
    zoom: 5,
  );

  // WS
  WebSocket? _ws;
  Timer? _wsReconnect;
  Timer? _pollTimer;
  bool _disposed = false;

  static const _steps = [
    _Step('PENDING', 'Booking Placed', Icons.receipt_long,
        'Waiting for professional assignment'),
    _Step('ACCEPTED', 'Accepted', Icons.check_circle,
        'Professional is on the way'),
    _Step('IN_PROGRESS', 'In Progress', Icons.engineering,
        'Service is underway'),
    _Step('COMPLETED', 'Completed', Icons.verified,
        'Service completed successfully'),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _fetchTracking();
    _connectWS();
    // Poll every 15 s as fallback when WS is down
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_ws == null &&
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
    _mapCtrl?.dispose();
    super.dispose();
  }

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
      if (_disposed) {
        _ws?.close();
        return;
      }
      _ws!.listen(
        _onWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _ws = null;
    _wsReconnect?.cancel();
    _wsReconnect = Timer(const Duration(seconds: 3), () {
      if (!_disposed) _connectWS();
    });
  }

  void _onWsMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String? ?? '';

      if (type == 'booking_location') {
        final p = msg['payload'];
        final Map<String, dynamic> payload = p is String
            ? jsonDecode(p) as Map<String, dynamic>
            : Map<String, dynamic>.from(p as Map);
        final lat = (payload['latitude'] as num?)?.toDouble();
        final lng = (payload['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null && mounted) {
          final newLoc = LatLng(lat, lng);
          setState(() => _providerLoc = newLoc);
          _mapCtrl?.animateCamera(CameraUpdate.newLatLng(newLoc));
        }
      } else if (type == 'booking_status') {
        final p = msg['payload'];
        final Map<String, dynamic> payload = p is String
            ? jsonDecode(p) as Map<String, dynamic>
            : Map<String, dynamic>.from(p as Map);
        final status = payload['status'] as String? ?? '';
        if (status.isNotEmpty && mounted) {
          setState(() => _status = status);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchTracking() async {
    final res = await _repo.getBookingTracking(widget.bookingId);
    res.when(
      onSuccess: (d) {
        if (!mounted) return;
        final lat = (d['latitude'] as num?)?.toDouble();
        final lng = (d['longitude'] as num?)?.toDouble();
        setState(() {
          if (lat != null && lng != null) {
            _providerLoc = LatLng(lat, lng);
          }
        });
        if (_providerLoc != null) {
          _mapCtrl?.animateCamera(
              CameraUpdate.newLatLngZoom(_providerLoc!, 15));
        }
      },
      onError: (_) {},
    );
  }

  int get _currentStepIndex {
    if (_status == 'CANCELLED') return -1;
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].status == _status) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(widget.serviceName,
            style: const TextStyle(
                color: Color(0xFF312E81), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF312E81),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTracking,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildMapCard(),
            const SizedBox(height: 16),
            _buildStepTracker(),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isCancelled = _status == 'CANCELLED';
    final color = isCancelled ? Colors.red : const Color(0xFF6BC4FF);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: Icon(
              isCancelled ? Icons.cancel : Icons.local_shipping,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCancelled
                      ? 'Booking Cancelled'
                      : 'Booking #${widget.bookingId.length > 8 ? widget.bookingId.substring(0, 8) : widget.bookingId}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  _status.replaceAll('_', ' '),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _providerLoc != null
                    ? CameraPosition(target: _providerLoc!, zoom: 15)
                    : _defaultCam,
                onMapCreated: (c) {
                  _mapCtrl = c;
                  if (_providerLoc != null) {
                    c.animateCamera(
                        CameraUpdate.newLatLngZoom(_providerLoc!, 15));
                  }
                },
                markers: _providerLoc != null
                    ? {
                        Marker(
                          markerId: const MarkerId('provider'),
                          position: _providerLoc!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                          infoWindow: const InfoWindow(title: 'Professional'),
                        ),
                      }
                    : {},
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              if (_providerLoc == null)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_searching,
                            color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Waiting for provider location…',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              // Status badge overlay
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(_status.replaceAll('_', ' '),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (_status) {
      case 'ACCEPTED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildStepTracker() {
    if (_status == 'CANCELLED') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text('This booking has been cancelled.',
                style: TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    final current = _currentStepIndex;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            ...List.generate(_steps.length, (i) {
              final step = _steps[i];
              final isDone = i <= current;
              final isActive = i == current;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFF6BC4FF)
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check : step.icon,
                            color: isDone ? Colors.white : Colors.grey,
                            size: 18,
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Container(
                              width: 2,
                              height: 20,
                              color: isDone
                                  ? const Color(0xFF6BC4FF)
                                  : Colors.grey.shade200),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.label,
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isDone
                                    ? const Color(0xFF312E81)
                                    : Colors.grey,
                              )),
                          if (isActive)
                            Text(step.description,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_status == 'COMPLETED' || _status == 'CANCELLED') {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        if (_status == 'PENDING' || _status == 'ACCEPTED')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showDisputeDialog(context),
              icon: const Icon(Icons.report_problem_outlined, size: 18),
              label: const Text('Report Issue'),
            ),
          ),
      ],
    );
  }

  void _showDisputeDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Issue'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await _repo.raiseDispute(
                bookingId: widget.bookingId,
                description: ctrl.text.trim(),
              );
              if (!context.mounted) return;
              res.when(
                onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Issue reported. Our team will look into it.'),
                    backgroundColor: Colors.green,
                  ),
                ),
                onError: (e) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e))),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final String status;
  final String label;
  final IconData icon;
  final String description;
  const _Step(this.status, this.label, this.icon, this.description);
}
