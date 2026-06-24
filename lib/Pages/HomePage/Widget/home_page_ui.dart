import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/geo_controller.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Pages/Bookings/booking_tracking_page.dart';
import 'package:home_care/Pages/Cart/cart_screen.dart';
import 'package:home_care/Pages/HomePage/Widget/emergency_floating.dart';
import 'package:home_care/Pages/HomePage/Widget/emergency_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/services_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/profesnal_widget.dart';
import 'package:home_care/Pages/Notifications/notifications_page.dart';
import 'package:home_care/Pages/Profile/profile_details_page.dart';
import 'package:home_care/Pages/Appointment/appointment_type_page.dart';
import 'package:home_care/Pages/Quick/quick_page.dart';

class HomePageUi extends StatefulWidget {
  const HomePageUi({super.key});
  @override
  State<HomePageUi> createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> with TickerProviderStateMixin {
  late final NotificationController _notifCtrl;
  late final ProfileController _profileCtrl;
  late final ServiceCartController _cartCtrl;
  late final ServiceController _serviceCtrl;
  late final ServiceProfessionalsController _proCtrl;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Chatbot FAB position
  double _fabX = 0;
  double _fabY = 0;
  bool _fabInitialized = false;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  // Changed on pull-to-refresh — forces NearbyProvidersSection to recreate its
  // state and re-call _load(), so provider availability changes show immediately.
  Key _providerSectionKey = UniqueKey();

  // Active booking — shown as a live-tracking banner on the home screen
  Map<String, dynamic>? _activeBooking;

  Future<void> _onRefresh() async {
    final geo = Get.find<GeoController>();
    await Future.wait([geo.fetchAndSync(), _fetchActiveBooking()]);
    if (mounted) setState(() => _providerSectionKey = UniqueKey());
  }

  Future<void> _fetchActiveBooking() async {
    try {
      final client = ApiClient();
      final res = await client.get('bookings', requiresAuth: true);
      final list = (res['data'] as List<dynamic>? ?? []).cast<Map>();
      final active = list.firstWhereOrNull((b) {
        final s = b['status'] as String? ?? '';
        return s == 'PENDING' ||
            s == 'ASSIGNED' ||
            s == 'ACCEPTED' ||
            s == 'IN_PROGRESS';
      });
      if (mounted) {
        setState(() => _activeBooking =
            active != null ? Map<String, dynamic>.from(active) : null);
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _notifCtrl = Get.find<NotificationController>();
    _profileCtrl = Get.find<ProfileController>();
    _cartCtrl = Get.find<ServiceCartController>();
    _serviceCtrl = Get.find<ServiceController>();
    _proCtrl = Get.find<ServiceProfessionalsController>();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();

    // Fetch services & professionals now that the user is logged in
    _serviceCtrl.loadAll();
    _proCtrl.fetchAll();

    // Load approved providers + GPS location (runs after login so token exists)
    Get.find<GeoController>().fetchAndSync();

    // Check for any active booking to show the live-tracking banner
    _fetchActiveBooking();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_fabInitialized) {
      _fabX = size.width - 80;
      _fabY = size.height * 0.72;
      _fabInitialized = true;
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: kPrimary,
            displacement: 80,
            child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Sticky header ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: kPrimary,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeader(),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: _buildSearchBar(),
                ),
              ),

              // ── Body sections ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    if (_activeBooking != null) ...[
                      _buildActiveBookingBanner(_activeBooking!),
                      const SizedBox(height: 16),
                    ],
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildActiveStatusBanner(),
                    const SizedBox(height: 24),
                    _PromoBanner(),
                    const SizedBox(height: 24),
                    HealthCareServicesUi(),
                    const SizedBox(height: 24),
                    const _FeaturedProvidersSection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Top Professionals',
                        onSeeAll: () => Get.toNamed('/professionals')),
                    const SizedBox(height: 12),
                    NearbyProvidersSection(key: _providerSectionKey),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          ),  // closes RefreshIndicator

          // ── Draggable chatbot FAB ───────────────────────────────────────
          Positioned(
            left: _fabX,
            top: _fabY,
            child: GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _fabX = (_fabX + d.delta.dx).clamp(0, size.width - 64);
                  _fabY = (_fabY + d.delta.dy)
                      .clamp(0, size.height - 64);
                });
              },
              child: const ChatbotFloatingButton(),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, kPrimaryMid, kPrimaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _headerFade,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    // Avatar + greeting
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => ProfileDetailsPage()),
                            child: Obx(() {
                              final u = _profileCtrl.user.value;
                              final name = u?.name ?? '';
                              final phone = u?.phoneNumber ?? '';
                              // Show name initials if profile created, else phone last 4 digits
                              String initials;
                              if (name.trim().isNotEmpty) {
                                initials = name
                                    .trim()
                                    .split(' ')
                                    .map((w) => w[0].toUpperCase())
                                    .take(2)
                                    .join();
                              } else if (phone.length >= 4) {
                                initials = phone.substring(phone.length - 4);
                              } else {
                                initials = phone.isNotEmpty ? phone : '?';
                              }
                              return Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      width: 1.5),
                                ),
                                child: Center(
                                  child: Text(initials,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: name.isNotEmpty ? 15 : 11)),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final u = _profileCtrl.user.value;
                              final name = u?.name ?? '';
                              final phone = u?.phoneNumber ?? '';
                              final hasProfile = name.trim().isNotEmpty;
                              return GestureDetector(
                                onTap: hasProfile
                                    ? null
                                    : () => Get.to(() => ProfileDetailsPage()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_greeting,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                    Text(
                                      hasProfile
                                          ? name.split(' ').first
                                          : phone,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (!hasProfile)
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade600,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text('Tap to create profile',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    // Cart
                    _TopIconBtn(
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Get.to(() => CartScreen()),
                      badge: Obx(() => _cartCtrl.totalItems > 0
                          ? _BadgeDot('${_cartCtrl.totalItems}')
                          : const SizedBox.shrink()),
                    ),
                    const SizedBox(width: 8),
                    // Notification bell
                    _TopIconBtn(
                      icon: Icons.notifications_outlined,
                      onTap: () => Get.to(() => const NotificationsPage()),
                      badge: Obx(() {
                        final c = _notifCtrl.unreadCount;
                        return c > 0
                            ? _BadgeDot(c > 99 ? '99+' : '$c')
                            : const SizedBox.shrink();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Live location row — auto-fetches GPS, updates as user moves
                Obx(() {
                  final geo = Get.find<GeoController>();
                  final locating = geo.isLocating.value;
                  final ready   = geo.locationReady.value;
                  final address = geo.currentAddress.value;

                  return GestureDetector(
                    onTap: locating ? null : geo.refreshLocation,
                    child: Row(
                      children: [
                        // Location icon / spinner
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: locating
                              ? Container(
                                  key: const ValueKey('spin'),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5, color: kAccent),
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('pin'),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: ready
                                        ? kAccent.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    ready
                                        ? Icons.my_location_rounded
                                        : Icons.location_on,
                                    color: kAccent, size: 14),
                                ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              color: ready
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!locating && ready)
                          const Icon(Icons.refresh_rounded,
                              color: Colors.white38, size: 13),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Health card
                _buildHealthCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety_outlined,
              color: kAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your health, our priority',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                SizedBox(height: 2),
                Text('24/7 professional care at home',
                    style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Book Now',
                style: TextStyle(
                    color: kPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kPrimaryDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) {
            _proCtrl.search(v);
            Get.find<GeoController>().search(v);
          },
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search professionals, services...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                const Icon(Icons.search, color: kPrimary, size: 20),
            suffixIcon: Obx(() {
              final geo = Get.find<GeoController>();
              return geo.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.grey.shade400, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _proCtrl.search('');
                        geo.clearSearch();
                      },
                    )
                  : const SizedBox.shrink();
            }),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── QUICK ACTIONS ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Quick Actions'),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickActionTile(
                icon: Icons.warning_amber_rounded,
                label: 'Emergency',
                gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                onTap: () => Get.toNamed('/sos'),
                isEmergency: true,
              ),
              const SizedBox(width: 12),
              _QuickActionTile(
                icon: Icons.calendar_today_rounded,
                label: 'Appointment',
                gradient: const [Color(0xFF4776E6), Color(0xFF8E54E9)],
                onTap: () => Get.to(() => const AppointmentTypePage()),
              ),
              const SizedBox(width: 12),
              _QuickActionTile(
                icon: Icons.flash_on_rounded,
                label: 'Quick Book',
                gradient: const [Color(0xFF00B09B), Color(0xFF96C93D)],
                onTap: () => Get.to(() => QuickServicesPage()),
              ),
              const SizedBox(width: 12),
              _QuickActionTile(
                icon: Icons.location_on_rounded,
                label: 'Nearby',
                gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
                onTap: () => Get.toNamed('/nearby-map'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ACTIVE STATUS BANNER ──────────────────────────────────────────────────

  Widget _buildActiveStatusBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.toNamed('/bookingHistory'),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kSuccessLight, Color(0xFF38EF7D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: kSuccessLight.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Healthcare at Your Doorstep',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  SizedBox(height: 3),
                  Text('Certified professionals ready to serve',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 14),
          ],
        ),
      ),
      ),  // closes GestureDetector
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────

  // ── ACTIVE BOOKING BANNER ─────────────────────────────────────────────────

  Widget _buildActiveBookingBanner(Map<String, dynamic> booking) {
    final bookingId = booking['booking_id'] as String? ?? '';
    final serviceName =
        booking['service_name'] as String? ?? 'Healthcare Service';
    final status = booking['status'] as String? ?? 'PENDING';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'ASSIGNED':
        statusColor = kWarning;
        statusLabel = 'Provider Assigned';
        statusIcon = Icons.person_pin_rounded;
        break;
      case 'ACCEPTED':
        statusColor = kPrimary;
        statusLabel = 'Provider En Route';
        statusIcon = Icons.directions_run_rounded;
        break;
      case 'IN_PROGRESS':
        statusColor = kPurple;
        statusLabel = 'Service In Progress';
        statusIcon = Icons.engineering_rounded;
        break;
      default:
        statusColor = kWarning;
        statusLabel = 'Booking Pending';
        statusIcon = Icons.hourglass_top_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.to(() => BookingTrackingPage(
              bookingId: bookingId,
              serviceName: serviceName,
              status: status,
            )),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: statusColor.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(serviceName,
                        style: const TextStyle(
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    const Text('Tap to track live →',
                        style:
                            TextStyle(color: kTextMedium, fontSize: 11)),
                  ],
                ),
              ),
              // Animated live dot
              _LiveDot(color: statusColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: kPrimaryGradientV,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: const [
                  Text('See all',
                      style: TextStyle(
                          fontSize: 13,
                          color: kPrimary,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 11, color: kPrimary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────────────────────────

class _TopIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Widget badge;
  const _TopIconBtn(
      {required this.icon, required this.onTap, required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Positioned(top: -4, right: -4, child: badge),
        ],
      ),
    );
  }
}

class _BadgeDot extends StatelessWidget {
  final String text;
  const _BadgeDot(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
          color: Color(0xFFFF416C), shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }
}

class _FeaturedProvidersSection extends StatelessWidget {
  const _FeaturedProvidersSection();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ServiceProfessionalsController>();
    return Obx(() {
      final list = ctrl.advertisedProfessionals;
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⭐ Featured',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(width: 8),
                const Text('Advertised Providers',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _FeaturedCard(pro: list[i]),
            ),
          ),
        ],
      );
    });
  }
}

class _FeaturedCard extends StatelessWidget {
  final dynamic pro;
  const _FeaturedCard({required this.pro});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFFFF8E1),
            backgroundImage: pro.profileImage.isNotEmpty
                ? NetworkImage(pro.profileImage)
                : null,
            child: pro.profileImage.isEmpty
                ? const Icon(Icons.person, color: Color(0xFFFFA500), size: 32)
                : null,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(pro.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 2),
          Text(pro.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
              const SizedBox(width: 2),
              Text('${pro.rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isEmergency;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.isEmergency = false,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isEmergency) {
      return Expanded(
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: const EmergencyUi(),
          ),
        ),
      );
    }
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: widget.gradient.first.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
                Text(widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Live pulsing dot for active booking banner ────────────────────────────────

class _LiveDot extends StatefulWidget {
  final Color color;
  const _LiveDot({required this.color});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _scale = Tween<double>(begin: 1.0, end: 2.2)
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
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: _fade.value),
                ),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ],
      ),
    );
  }
}

// ── Auto-scroll promotional banner ────────────────────────────────────────────

class _PromoBanner extends StatefulWidget {
  const _PromoBanner();

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;
  Timer? _timer;

  static const _banners = [
    _BannerData(
      title: '20% Off First Booking',
      subtitle: 'Book your first home nursing visit\nand get 20% discount.',
      icon: Icons.health_and_safety_rounded,
      colors: [kPrimary, kPrimaryDark],
    ),
    _BannerData(
      title: 'Certified Professionals',
      subtitle: 'All our providers are verified\nand background-checked.',
      icon: Icons.verified_rounded,
      colors: [kSuccess, Color(0xFF059669)],
    ),
    _BannerData(
      title: '24/7 Emergency Support',
      subtitle: 'Round-the-clock healthcare\nat your doorstep.',
      icon: Icons.local_hospital_rounded,
      colors: [kError, Color(0xFFDC2626)],
    ),
    _BannerData(
      title: 'Family Health Plans',
      subtitle: 'Protect your entire family\nwith our care packages.',
      icon: Icons.family_restroom_rounded,
      colors: [kPurple, Color(0xFF6D28D9)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (p) => setState(() => _page = p),
            itemCount: _banners.length,
            itemBuilder: (_, i) {
              final b = _banners[i];
              return AnimatedScale(
                scale: _page == i ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: b.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: b.colors.first.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(b.subtitle,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(b.icon, color: Colors.white, size: 28),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _page == i ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _page == i ? kPrimary : kBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
