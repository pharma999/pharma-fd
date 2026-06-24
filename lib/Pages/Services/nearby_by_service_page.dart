import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/geo_controller.dart';
import 'package:home_care/Pages/Booking/confirm_booking_page.dart';

// ── NearbyByServicePage ───────────────────────────────────────────────────────
// Opened when the user taps a Quick-Book card (Nurse, Caregiver, etc.).
// Fetches nearby providers from the backend filtered by [category],
// geo-sorted nearest first.  Falls back to all approved providers in
// that category when GPS is unavailable.

class NearbyByServicePage extends StatefulWidget {
  final String serviceLabel;   // display name: "Nurse", "Caregiver"…
  final String category;       // backend NurseCategory: "GENERAL", "ELDERLY"…
  final IconData icon;
  final Color color;

  const NearbyByServicePage({
    super.key,
    required this.serviceLabel,
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  State<NearbyByServicePage> createState() => _NearbyByServicePageState();
}

class _NearbyByServicePageState extends State<NearbyByServicePage> {
  final _client = ApiClient();

  List<Map<String, dynamic>> _providers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });

    try {
      final geo = Get.find<GeoController>();
      double? lat = geo.locationReady.value ? geo.lat.value : null;
      double? lng = geo.locationReady.value ? geo.lng.value : null;

      // Try to get fresh GPS if not already available
      if (lat == null || lng == null) {
        final pos = await _quickGps();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
          geo.lat.value = lat;
          geo.lng.value = lng;
          geo.locationReady.value = true;
          // Upload patient location silently
          _client.post('patient/location',
              {'latitude': lat, 'longitude': lng}, requiresAuth: true);
        }
      }

      List<Map<String, dynamic>> result = [];

      if (lat != null && lng != null) {
        // ── Geo-sorted nearby providers with category filter ─────────────
        final params = <String, String>{
          'lat':    lat.toString(),
          'lng':    lng.toString(),
          'radius': '50',
          if (widget.category.isNotEmpty) 'category': widget.category,
        };
        final query = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        final res = await _client.get('providers/nearby?$query',
            requiresAuth: true);
        final raw = res['data'];
        if (raw is List && raw.isNotEmpty) {
          result = raw.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // ── Fallback: approved nurses for this category ───────────────────
      if (result.isEmpty) {
        final catQ = widget.category.isNotEmpty
            ? '?category=${Uri.encodeComponent(widget.category)}'
            : '';
        final res = await _client.get('nurses/approved$catQ',
            requiresAuth: true);
        final raw = res['data'];
        if (raw is List) {
          result = raw.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      if (mounted) setState(() { _providers = result; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<Position?> _quickGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 5)),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kSurface, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: kSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, color: kSurface, size: 18),
          ),
          const SizedBox(width: 10),
          Text(widget.serviceLabel,
              style: const TextStyle(
                  color: kSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: kSurface, size: 22),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? _buildSkeleton()
          : _error != null
              ? _buildError()
              : _providers.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _providers.length,
                        itemBuilder: (_, i) => _ProviderCard(
                          data: _providers[i],
                          accentColor: widget.color,
                          serviceLabel: widget.serviceLabel,
                        ),
                      ),
                    ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded,
              size: 52, color: kError.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextMedium)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: kSurface),
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.08),
                shape: BoxShape.circle),
            child: Icon(widget.icon,
                size: 44,
                color: widget.color.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('No ${widget.serviceLabel}s Available Nearby',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text(
              'Try increasing the search radius\nor check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMedium, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: kSurface),
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ]),
      ),
    );
  }
}

// ── Provider card ─────────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color accentColor;
  final String serviceLabel;

  const _ProviderCard({
    required this.data,
    required this.accentColor,
    required this.serviceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name      = data['name']?.toString()          ?? 'Provider';
    final category  = data['category']?.toString()      ?? serviceLabel;
    final qual      = data['qualification']?.toString() ?? '';
    final rating    = (data['rating']   ?? 0).toDouble();
    final distKm    = (data['distance_km'] ?? 0).toDouble();
    final hourly    = (data['hourly_rate']  ?? 0).toDouble();
    final nurseId   = data['nurse_id']?.toString()      ?? '';
    final isAvail   = data['is_available']  ?? true;
    final yrsExp    = data['years_of_experience'] ?? 0;

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    // Avatar gradient based on initial
    final colors = _avatarGradient(initial);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: accentColor.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          // Avatar
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              boxShadow: [
                BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Center(
              child: Text(initial,
                  style: const TextStyle(
                      color: kSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
                const SizedBox(height: 2),
                Text(
                  qual.isNotEmpty ? '$category · $qual' : category,
                  style: const TextStyle(
                      fontSize: 11, color: kTextMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(children: [
                  if (rating > 0) ...[
                    const Icon(Icons.star_rounded,
                        size: 13, color: kWarning),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTextDark)),
                    const SizedBox(width: 10),
                  ],
                  if (distKm > 0) ...[
                    const Icon(Icons.near_me_rounded,
                        size: 12, color: kSuccess),
                    const SizedBox(width: 3),
                    Text('${distKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                            fontSize: 11, color: kSuccess)),
                    const SizedBox(width: 10),
                  ],
                  if (yrsExp > 0)
                    Text('${yrsExp}y exp',
                        style: const TextStyle(
                            fontSize: 11, color: kTextLight)),
                ]),
              ],
            ),
          ),

          // Price + Book button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hourly > 0) ...[
                Text('₹${hourly.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimary)),
                const Text('/hr',
                    style: TextStyle(
                        fontSize: 9, color: kTextLight)),
                const SizedBox(height: 8),
              ],
              GestureDetector(
                onTap: isAvail
                    ? () => Get.to(() => ConfirmBookingPage(
                          professionalId: nurseId,
                          serviceId: '',
                          professionalName: name,
                          professionalRole: category,
                          serviceName: serviceLabel,
                          rating: rating,
                          yearsExperience: yrsExp,
                          distance: distKm > 0
                              ? '${distKm.toStringAsFixed(1)} KM'
                              : '',
                          estimatedDuration: 60,
                          availableTimeStart: '',
                          availableTimeEnd: '',
                          price: hourly,
                        ))
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient:
                        isAvail ? kPrimaryGradient : null,
                    color: isAvail
                        ? null
                        : kBorder,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isAvail
                        ? [
                            BoxShadow(
                                color: kPrimary
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ]
                        : [],
                  ),
                  child: Text(
                    isAvail ? 'Book' : 'Busy',
                    style: TextStyle(
                        color: isAvail
                            ? kSurface
                            : kTextLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  static List<Color> _avatarGradient(String initial) {
    const palettes = <List<Color>>[
      [kPrimary, kPrimaryMid],
      [kPurple, Color(0xFF6D28D9)],
      [kTeal, Color(0xFF0D9488)],
      [kError, Color(0xFFDC2626)],
      [kSuccess, Color(0xFF059669)],
      [kOrange, Color(0xFFEA580C)],
      [kPink, Color(0xFFDB2777)],
      [kAmber, Color(0xFFD97706)],
    ];
    final code = initial.isEmpty ? 0 : initial.codeUnitAt(0);
    return palettes[code % palettes.length];
  }
}

// ── Skeleton card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _c;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _c = ColorTween(begin: kBorder, end: kDivider)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 90,
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder)),
        child: Row(children: [
          Container(
              margin: const EdgeInsets.all(14),
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: _c.value,
                  shape: BoxShape.circle)),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Container(height: 14, width: 120,
                  decoration: BoxDecoration(
                      color: _c.value,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 8),
              Container(height: 10, width: 80,
                  decoration: BoxDecoration(
                      color: _c.value?.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(width: 54, height: 32,
                decoration: BoxDecoration(
                    color: _c.value,
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      ),
    );
  }
}
