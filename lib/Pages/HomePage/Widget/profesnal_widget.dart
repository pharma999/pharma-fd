import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/geo_controller.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

// ── Top Professionals — geo-sorted approved service providers ─────────────────

class NearbyProvidersSection extends StatefulWidget {
  const NearbyProvidersSection({super.key});

  @override
  State<NearbyProvidersSection> createState() => _NearbyProvidersSectionState();
}

class _NearbyProvidersSectionState extends State<NearbyProvidersSection>
    with WidgetsBindingObserver {
  final _client = ApiClient();
  List<Map<String, dynamic>> _providers = [];
  bool _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    // Poll every 30 s so provider availability changes are reflected quickly
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final geo = Get.find<GeoController>();
      double? lat = geo.locationReady.value ? geo.lat.value : null;
      double? lng = geo.locationReady.value ? geo.lng.value : null;

      if (lat == null || lng == null) {
        final pos = await _quickGps();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
          geo.lat.value = lat;
          geo.lng.value = lng;
          geo.locationReady.value = true;
          _client.post('patient/location',
              {'latitude': lat, 'longitude': lng}, requiresAuth: true);
        }
      }

      if (lat != null && lng != null) {
        final nearbyRes = await _client.get(
          'providers/nearby',
          requiresAuth: true,
          queryParams: {
            'lat': lat.toString(),
            'lng': lng.toString(),
            'radius': '50',
          },
        );
        final nearbyRaw = nearbyRes['data'];
        if (nearbyRaw is List && nearbyRaw.isNotEmpty) {
          final list = nearbyRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          if (mounted) setState(() { _providers = list; _loading = false; });
          return;
        }
      }

      final approvedRes =
          await _client.get('nurses/approved', requiresAuth: true);
      final approvedRaw = approvedRes['data'];
      final approvedList = (approvedRaw is List)
          ? approvedRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      if (mounted) setState(() { _providers = approvedList; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _filtered(String query) {
    if (query.isEmpty) return _providers;
    return _providers.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat  = (p['category'] ?? '').toString().toLowerCase();
      final qual = (p['qualification'] ?? '').toString().toLowerCase();
      return name.contains(query) || cat.contains(query) || qual.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(3, (_) => const _ProfessionalCardSkeleton()),
        ),
      );
    }

    return Obx(() {
      final query = Get.find<GeoController>().searchQuery.value;
      final list  = _filtered(query);

      if (_providers.isEmpty) {
        return _EmptyState(
          icon: Icons.person_search_rounded,
          message: 'No approved service providers found.',
          actionLabel: 'Retry',
          onAction: _load,
        );
      }

      if (list.isEmpty) {
        return _EmptyState(
          icon: Icons.search_off_rounded,
          message: 'No results for "$query"',
          actionLabel: 'Clear search',
          onAction: Get.find<GeoController>().clearSearch,
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final data = list[i];
          return TweenAnimationBuilder<double>(
            key: ValueKey('prov_${data['nurse_id'] ?? i}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 340 + i * 75),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, 28 * (1 - v)),
                child: child,
              ),
            ),
            child: _NearbyProviderCard(data: data),
          );
        },
      );
    });
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: kPrimary.withValues(alpha: 0.35)),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextMedium, fontSize: 13)),
            if (onAction != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(actionLabel, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: kPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shimmer box ───────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(8));

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE4E7EF),
      end: const Color(0xFFF2F4FF),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
            color: _color.value, borderRadius: widget.borderRadius),
      ),
    );
  }
}

// ── Pulse dot (online indicator) ──────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _scale = Tween<double>(begin: 1.0, end: 2.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0.7, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kSuccess.withValues(alpha: _fade.value),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: kSuccess),
          ),
        ],
      ),
    );
  }
}

// ── Nearby provider card ──────────────────────────────────────────────────────

class _NearbyProviderCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _NearbyProviderCard({required this.data});

  @override
  State<_NearbyProviderCard> createState() => _NearbyProviderCardState();
}

class _NearbyProviderCardState extends State<_NearbyProviderCard> {
  bool _pressed = false;

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

  @override
  Widget build(BuildContext context) {
    final name      = widget.data['name']?.toString() ?? 'Provider';
    final category  = widget.data['category']?.toString() ?? '';
    final qual      = widget.data['qualification']?.toString() ?? '';
    final rating    = (widget.data['rating'] ?? 0).toDouble();
    final hourlyRate = (widget.data['hourly_rate'] ?? 0).toDouble();
    final distKM    = (widget.data['distance_km'] ?? 0).toDouble();
    final nurseId   = widget.data['nurse_id']?.toString() ?? '';
    final isAvail   = widget.data['is_available'] ?? true;
    final yrsExp    = widget.data['years_of_experience'] ?? 0;

    final initial      = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final avatarColors = _avatarGradient(initial);

    return GestureDetector(
      onTap: () => Get.to(() => ProfessionalDetailPage(
            professionalId: nurseId,
            serviceId: '',
            name: name,
            role: category,
            serviceName: category,
            rating: rating,
            available: isAvail,
            yearsExperience: yrsExp,
            distance: distKM > 0 ? '${distKM.toStringAsFixed(1)} KM' : '',
            estimatedDuration: 60,
            price: hourlyRate,
          )),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent strip
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: isAvail
                          ? kPrimaryGradientV
                          : const LinearGradient(
                              colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Avatar + pulse
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: avatarColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: avatarColors.first
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(initial,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                              if (isAvail)
                                const Positioned(
                                    bottom: 0, right: 0, child: _PulseDot()),
                            ],
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(name,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: kTextDark),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (!isAvail)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kTextLight.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Busy',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: kTextLight,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ]),
                                const SizedBox(height: 2),
                                if (category.isNotEmpty)
                                  Text(
                                    qual.isNotEmpty
                                        ? '$category · $qual'
                                        : category,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  if (distKM > 0) ...[
                                    _Tag(
                                      icon: Icons.near_me_rounded,
                                      label: '${distKM.toStringAsFixed(1)} km',
                                      color: kSuccess,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (rating > 0)
                                    _Tag(
                                      icon: Icons.star_rounded,
                                      label: rating.toStringAsFixed(1),
                                      color: kWarning,
                                    ),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Price + Book
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hourlyRate > 0) ...[
                                Text('₹${hourlyRate.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimary)),
                                const Text('/hr',
                                    style: TextStyle(
                                        fontSize: 10, color: kTextLight)),
                                const SizedBox(height: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: isAvail ? kPrimaryGradient : null,
                                  color: isAvail ? null : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: isAvail
                                      ? [
                                          BoxShadow(
                                            color: kPrimary.withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  isAvail ? 'Book' : 'Busy',
                                  style: TextStyle(
                                    color: isAvail
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Tag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Professional card skeleton ────────────────────────────────────────────────

class _ProfessionalCardSkeleton extends StatelessWidget {
  const _ProfessionalCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            _ShimmerBox(
              width: 5,
              height: 92,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _ShimmerBox(
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(
                              width: 120,
                              height: 14,
                              borderRadius: BorderRadius.circular(4)),
                          const SizedBox(height: 8),
                          _ShimmerBox(
                              width: 88,
                              height: 10,
                              borderRadius: BorderRadius.circular(4)),
                          const SizedBox(height: 10),
                          Row(children: [
                            _ShimmerBox(
                                width: 58,
                                height: 18,
                                borderRadius: BorderRadius.circular(10)),
                            const SizedBox(width: 6),
                            _ShimmerBox(
                                width: 38,
                                height: 18,
                                borderRadius: BorderRadius.circular(10)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        _ShimmerBox(
                            width: 40,
                            height: 16,
                            borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 10),
                        _ShimmerBox(
                            width: 58,
                            height: 30,
                            borderRadius: BorderRadius.circular(22)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward-compat alias.
class AvailableProfessionalsUi extends StatelessWidget {
  const AvailableProfessionalsUi({super.key});
  @override
  Widget build(BuildContext context) => const NearbyProvidersSection();
}
