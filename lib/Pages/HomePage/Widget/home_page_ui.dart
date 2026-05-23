import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
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
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Sticky header ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: const Color(0xFF1A56DB),
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
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildActiveStatusBanner(),
                    const SizedBox(height: 24),
                    HealthCareServicesUi(),
                    const SizedBox(height: 24),
                    const _FeaturedProvidersSection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Top Professionals', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    AvailableProfessionalsUi(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

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
          colors: [Color(0xFF1A56DB), Color(0xFF0E3FA8), Color(0xFF0A2D7A)],
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
                // Location row
                Obx(() {
                  final addr1 = _profileCtrl.user.value?.address1;
                  final addr = addr1 != null
                      ? [addr1.street, addr1.landmark, addr1.pinCode]
                          .where((s) => s.isNotEmpty)
                          .join(', ')
                      : '';
                  return GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.location_on,
                              color: Color(0xFF6EE7F7), size: 14),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            addr.isNotEmpty ? addr : 'Set your location',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white54, size: 16),
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
              color: Color(0xFF6EE7F7), size: 28),
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
              color: const Color(0xFF6EE7F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Book Now',
                style: TextStyle(
                    color: Color(0xFF0A2D7A),
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
      color: const Color(0xFF0A2D7A),
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
          onChanged: (v) => _proCtrl.search(v),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search services, doctors...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                const Icon(Icons.search, color: Color(0xFF1A56DB), size: 20),
            suffixIcon: Obx(() => _proCtrl.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.grey.shade400, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _proCtrl.search('');
                    },
                  )
                : const SizedBox.shrink()),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF11998E).withValues(alpha: 0.35),
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
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36))),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('See all',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A56DB),
                      fontWeight: FontWeight.w600)),
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
                        color: Color(0xFF1A1F36))),
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

class _QuickActionTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isEmergency) {
      return Expanded(
          child: GestureDetector(onTap: onTap, child: const EmergencyUi()));
    }
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: gradient.first.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
