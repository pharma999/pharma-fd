import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/geo_controller.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/HomePage/Widget/profesnal_widget.dart';
import 'package:home_care/Pages/Services/nearby_by_service_page.dart';
import 'package:home_care/Pages/Services/service_detail_page.dart';

// ── Services Tab Page (root tab — no back button) ─────────────────────────────
// Central discovery hub: categories, services, nearby professionals,
// and quick-book shortcuts. All data from backend via existing controllers.

class ServicesTabPage extends StatefulWidget {
  const ServicesTabPage({super.key});

  @override
  State<ServicesTabPage> createState() => _ServicesTabPageState();
}

class _ServicesTabPageState extends State<ServicesTabPage> {
  late final ServiceController _svcCtrl;
  late final ServiceProfessionalsController _proCtrl;
  late final GeoController _geoCtrl;

  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _selCategoryId;

  // Icon helper (same logic as services_widget.dart)
  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('nurs')) return Icons.health_and_safety_rounded;
    if (n.contains('physio') || n.contains('rehab')) return Icons.accessibility_new_rounded;
    if (n.contains('elder') || n.contains('senior')) return Icons.elderly_rounded;
    if (n.contains('mental') || n.contains('psych')) return Icons.psychology_rounded;
    if (n.contains('check') || n.contains('consul')) return Icons.medical_services_rounded;
    if (n.contains('emergency') || n.contains('sos')) return Icons.emergency_rounded;
    if (n.contains('therap')) return Icons.self_improvement_rounded;
    if (n.contains('baby') || n.contains('child') || n.contains('pedi')) return Icons.child_care_rounded;
    if (n.contains('lab') || n.contains('test')) return Icons.science_rounded;
    if (n.contains('vaccin') || n.contains('immun')) return Icons.vaccines_rounded;
    if (n.contains('diet') || n.contains('nutri')) return Icons.restaurant_menu_rounded;
    if (n.contains('dental')) return Icons.sentiment_satisfied_rounded;
    if (n.contains('cardio') || n.contains('heart')) return Icons.favorite_rounded;
    if (n.contains('eye') || n.contains('ophthal')) return Icons.remove_red_eye_rounded;
    if (n.contains('doctor') || n.contains('physician')) return Icons.medical_information_rounded;
    if (n.contains('surgery') || n.contains('post')) return Icons.healing_rounded;
    if (n.contains('inject')) return Icons.vaccines_rounded;
    return Icons.health_and_safety_rounded;
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

  List<Color> _gradient(int i) => _palettes[i % _palettes.length];

  @override
  void initState() {
    super.initState();
    _svcCtrl  = Get.find<ServiceController>();
    _proCtrl  = Get.find<ServiceProfessionalsController>();
    _geoCtrl  = Get.find<GeoController>();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
      _proCtrl.search(_query);
      _geoCtrl.search(_query);
    });
    // Refresh data when tab is opened
    _svcCtrl.loadAll();          // categories + all services
    _svcCtrl.fetchQuickServices(); // super-admin managed Quick Book services
    _proCtrl.fetchAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ServiceModel> get _filteredServices {
    final src = _svcCtrl.services.toList();
    if (_query.isEmpty) return src;
    return src
        .where((s) =>
            s.name.toLowerCase().contains(_query) ||
            s.description.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Search + location header ───────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchHeader()),

            // ── Category chips ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // ── Services grid ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildServicesSection()),

            // ── Quick Book ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildQuickBook()),

            // ── Nearby Professionals ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildNearbyProfessionals()),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── SEARCH HEADER ─────────────────────────────────────────────────────────

  Widget _buildSearchHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title row
        Row(children: [
          const Expanded(
            child: Text('Find Services',
                style: TextStyle(
                    color: kSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          // Location indicator
          Obx(() {
            final addr = _geoCtrl.currentAddress.value;
            if (addr.isEmpty || addr == 'Fetching location…') {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on_rounded,
                    color: kAccent, size: 13),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(addr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: kSurface, fontSize: 11)),
                ),
              ]),
            );
          }),
        ]),
        const SizedBox(height: 4),
        const Text('Healthcare at your doorstep',
            style: TextStyle(color: kAccent, fontSize: 12)),
        const SizedBox(height: 14),

        // Search bar
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: kPrimaryDark.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 14, color: kTextDark),
            decoration: InputDecoration(
              hintText: 'Search services, professionals…',
              hintStyle:
                  const TextStyle(color: kTextLight, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: kPrimary, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: kTextLight),
                      onPressed: () => _searchCtrl.clear())
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ]),
    );
  }

  // ── CATEGORY CHIPS ────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return Obx(() {
      if (_svcCtrl.categories.isEmpty) return const SizedBox(height: 8);
      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: _svcCtrl.categories.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return _Chip(
                label: 'All',
                selected: _selCategoryId == null,
                onTap: () {
                  setState(() => _selCategoryId = null);
                  _svcCtrl.fetchAllServices();
                  _proCtrl.clearFilter();
                },
              );
            }
            final cat = _svcCtrl.categories[i - 1];
            return _Chip(
              label: cat.name,
              selected: _selCategoryId == cat.id,
              onTap: () {
                setState(() => _selCategoryId = cat.id);
                _svcCtrl.fetchCategoryServices(cat.id);
                _proCtrl.filterByCategory(cat.id, cat.name);
              },
            );
          },
        ),
      );
    });
  }

  // ── SERVICES SECTION ──────────────────────────────────────────────────────

  Widget _buildServicesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      _SectionHeader(
        title: 'Healthcare Services',
        icon: Icons.medical_services_rounded,
        onSeeAll: () {},
      ),
      const SizedBox(height: 10),
      Obx(() {
        if (_svcCtrl.isLoadingServices.value) {
          return SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => _ServiceSkeleton(),
            ),
          );
        }
        final list = _filteredServices;
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.medical_services_outlined,
            message: 'No services available',
            onRetry: _svcCtrl.fetchAllServices,
          );
        }
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final svc = list[i];
              final colors = _gradient(i);
              return _ServiceCard(
                service: svc,
                gradient: colors,
                icon: _iconFor(svc.name),
                onTap: () {
                  _proCtrl.selectService(svc.id, svc.name);
                  Get.to(() => ServiceInfoPage(
                        service: svc,
                        gradient: colors,
                        icon: _iconFor(svc.name),
                      ));
                },
              );
            },
          ),
        );
      }),
    ]);
  }

  // ── QUICK BOOK ────────────────────────────────────────────────────────────

  Widget _buildQuickBook() {
    return Obx(() {
      final loading  = _svcCtrl.isLoadingQuickServices.value;
      final services = _svcCtrl.quickServices;

      // Nothing to show (no quick services defined yet by super admin)
      if (!loading && services.isEmpty) return const SizedBox.shrink();

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Quick Book',
          icon: Icons.flash_on_rounded,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: loading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: services.length,
                  itemBuilder: (_, i) {
                    final svc = services[i];
                    final colors = _gradient(i);
                    final icon   = _iconFor(svc.name);
                    final color  = colors.first;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _QuickBookCard(
                        item: _QuickItem(svc.name, icon, color),
                        onTap: () => Get.to(() => NearbyByServicePage(
                              serviceLabel: svc.name,
                              // Use empty string — NearbyByServicePage does
                              // fuzzy service_name matching on the backend
                              category: '',
                              icon:  icon,
                              color: color,
                            )),
                      ),
                    );
                  },
                ),
        ),
      ]);
    });
  }

  // ── NEARBY PROFESSIONALS ──────────────────────────────────────────────────

  Widget _buildNearbyProfessionals() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      _SectionHeader(
        title: 'Nearby Professionals',
        icon: Icons.near_me_rounded,
        onSeeAll: () {
          // Clear filter to show all professionals
          _proCtrl.clearFilter();
          _geoCtrl.clearSearch();
        },
      ),
      const SizedBox(height: 8),
      // Reuse the home page's geo-sorted professional list
      const NearbyProvidersSection(),
    ]);
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _Chip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
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
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            gradient: widget.selected ? kPrimaryGradient : null,
            color: widget.selected ? null : kSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.selected
                    ? kPrimary.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(widget.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.selected ? kSurface : kTextMedium)),
        ),
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;
  const _ServiceCard(
      {required this.service,
      required this.gradient,
      required this.icon,
      required this.onTap});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
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
          width: 116,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(widget.icon, color: kSurface, size: 28),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(widget.service.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kTextDark)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.gradient.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '₹${widget.service.basePrice.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: widget.gradient.first,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick book item model ─────────────────────────────────────────────────────

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickItem(this.label, this.icon, this.color);
}

// ── Quick book card ───────────────────────────────────────────────────────────

class _QuickBookCard extends StatefulWidget {
  final _QuickItem item;
  final VoidCallback onTap;
  const _QuickBookCard({required this.item, required this.onTap});

  @override
  State<_QuickBookCard> createState() => _QuickBookCardState();
}

class _QuickBookCardState extends State<_QuickBookCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: item.color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: item.color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.label,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kTextDark)),
                  Text('Quick book',
                      style: const TextStyle(
                          fontSize: 10, color: kTextLight)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;
  const _SectionHeader(
      {required this.title, required this.icon, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              gradient: kPrimaryGradientV,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: kPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kTextDark)),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('See all',
                  style: TextStyle(
                      fontSize: 12,
                      color: kPrimary,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 10, color: kPrimary),
            ]),
          ),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  const _EmptyState(
      {required this.icon, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(icon,
                size: 36, color: kPrimary.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: kTextMedium, fontSize: 13)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: kPrimary),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Service skeleton ──────────────────────────────────────────────────────────

class _ServiceSkeleton extends StatefulWidget {
  @override
  State<_ServiceSkeleton> createState() => _ServiceSkeletonState();
}

class _ServiceSkeletonState extends State<_ServiceSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _color = ColorTween(begin: kBorder, end: kDivider)
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
      animation: _color,
      builder: (_, __) => Container(
        width: 116,
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                  color: _color.value,
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 10),
          Container(
              width: 72, height: 10,
              decoration: BoxDecoration(
                  color: _color.value,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Container(
              width: 44, height: 18,
              decoration: BoxDecoration(
                  color: _color.value?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10))),
        ]),
      ),
    );
  }
}
