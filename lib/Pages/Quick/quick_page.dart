import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/Booking/confirm_booking_page.dart';

class QuickServicesPage extends StatefulWidget {
  const QuickServicesPage({super.key});

  @override
  State<QuickServicesPage> createState() => _QuickServicesPageState();
}

class _QuickServicesPageState extends State<QuickServicesPage> {
  final _client = ApiClient();
  List<ServiceModel> _services = [];
  List<ServiceModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  // Icon mapping (same as services_widget.dart)
  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('nurs')) return Icons.health_and_safety;
    if (n.contains('physio') || n.contains('rehab')) return Icons.accessibility_new;
    if (n.contains('elder') || n.contains('senior')) return Icons.elderly;
    if (n.contains('mental') || n.contains('psych')) return Icons.psychology;
    if (n.contains('check') || n.contains('consul')) return Icons.medical_services;
    if (n.contains('emergency') || n.contains('sos')) return Icons.emergency;
    if (n.contains('therap')) return Icons.self_improvement;
    if (n.contains('baby') || n.contains('child') || n.contains('pedi')) return Icons.child_care;
    if (n.contains('lab') || n.contains('test')) return Icons.science;
    if (n.contains('vaccin') || n.contains('immun')) return Icons.vaccines;
    if (n.contains('diet') || n.contains('nutri')) return Icons.restaurant_menu;
    if (n.contains('dental')) return Icons.sentiment_satisfied;
    if (n.contains('cardio') || n.contains('heart')) return Icons.favorite;
    if (n.contains('eye') || n.contains('ophthal')) return Icons.remove_red_eye;
    if (n.contains('ambulance')) return Icons.local_hospital;
    if (n.contains('doctor') || n.contains('physician')) return Icons.medical_information;
    if (n.contains('medic')) return Icons.medication;
    return Icons.health_and_safety;
  }

  static const List<List<Color>> _palettes = [
    [kPrimary, kPrimaryMid],
    [Color(0xFF0EA5E9), kTeal],
    [kError, kPink],
    [kSuccess, Color(0xFF059669)],
    [kWarning, kOrange],
    [kPurple, kPink],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [kTeal, Color(0xFF0D9488)],
    [kOrange, kError],
    [kPurple, Color(0xFF4338CA)],
  ];

  List<Color> _gradientFor(int i) => _palettes[i % _palettes.length];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    try {
      // Try the ServiceController cache first
      final ctrl = Get.find<ServiceController>();
      if (ctrl.services.isNotEmpty) {
        setState(() {
          _services = List<ServiceModel>.from(ctrl.services);
          _filtered  = _services;
        });
        return;
      }
      // Fall back to direct API call
      final res = await _client.get('services', requiresAuth: true);
      final raw = (res['data'] as List<dynamic>?) ?? [];
      final list = raw.whereType<Map>()
          .map((s) => ServiceModel.fromJson(Map<String, dynamic>.from(s)))
          .toList();
      setState(() {
        _services = list;
        _filtered  = list;
      });
    } catch (_) {
      setState(() { _services = []; _filtered = []; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _services
          : _services
              .where((s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.description.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: const Text('Quick Book',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search services…',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: kPrimary, size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                    gradient: kPrimaryGradientV,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text('Healthcare Services',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextDark)),
            ]),
          ),

          // Grid
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadServices,
                        color: kPrimary,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (_, i) {
                            final svc = _filtered[i];
                            final colors = _gradientFor(i);
                            return _ServiceTile(
                              service: svc,
                              gradient: colors,
                              icon: _iconFor(svc.name),
                              onTap: () => _onServiceTap(svc),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _onServiceTap(ServiceModel svc) {
    // Navigate directly to confirm booking with service pre-selected
    Get.to(() => ConfirmBookingPage(
          professionalId: '',
          serviceId: svc.id,
          professionalName: '',
          professionalRole: '',
          serviceName: svc.name,
          rating: 0,
          yearsExperience: 0,
          distance: '',
          estimatedDuration: 60, // default 60 min; updated when provider accepts
          availableTimeStart: '',
          availableTimeEnd: '',
          price: svc.basePrice,
        ));
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(Icons.medical_services_outlined,
                size: 44, color: kPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No services found',
              style: TextStyle(color: kTextMedium, fontSize: 14)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadServices,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: kPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Service tile ──────────────────────────────────────────────────────────────

class _ServiceTile extends StatefulWidget {
  final ServiceModel service;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;
  const _ServiceTile({
    required this.service,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.service.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${widget.service.basePrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.gradient.first,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
