import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/auth_repository.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/booking_controller.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Model/user_detail_model.dart';
import 'package:home_care/Pages/Chat/chat_list_page.dart';
import 'package:home_care/Pages/Notifications/notifications_page.dart';
import 'package:home_care/Pages/Profile/appointments_page.dart';
import 'package:home_care/Pages/Profile/FamilyReport/family_report.dart';
import 'package:home_care/Pages/Profile/help_support_page.dart';
import 'package:home_care/Pages/Profile/payments_page.dart';
import 'package:home_care/Pages/Profile/privacy_security_page.dart';
import 'package:home_care/Pages/Profile/profile_details_page.dart';
import 'package:home_care/Pages/Profile/records_page.dart';
import 'package:home_care/Pages/Profile/wallet_page.dart';

// ── Profile (root tab — no back button) ──────────────────────────────────────

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late final ProfileController _ctrl;
  late AnimationController _headerAnim;
  late AnimationController _contentAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _contentAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentAnim, curve: Curves.easeOut));
    _contentFade =
        CurvedAnimation(parent: _contentAnim, curve: Curves.easeOut);

    // Start animations after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerAnim.forward();
      Future.delayed(const Duration(milliseconds: 200),
          () => _contentAnim.forward());
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Obx(() {
        final u = _ctrl.user.value;
        final isLoading = _ctrl.isLoading.value;

        if (isLoading && u == null) return _buildSkeleton();

        return CustomScrollView(
          slivers: [
            // ── Animated gradient header ──────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeader(u),
              ),
            ),

            // ── Incomplete profile nudge ──────────────────────────────────
            if (u == null || u.name.trim().isEmpty)
              SliverToBoxAdapter(
                child: _CompleteProfileBanner(
                    onTap: () => Get.to(() => const ProfileDetailsPage())),
              ),

            // ── Content (animated slide + fade) ───────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4 booking stat cards
                      _buildStatsCards(),

                      // Menu
                      const _SectionLabel('Account'),
                      _buildAccountMenu(u),

                      const _SectionLabel('More'),
                      _buildMoreMenu(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserDetail? u) {
    final name = u?.name ?? '';
    final phone = u?.phoneNumber ?? '';
    final email = u?.email ?? '';
    final imageUrl = u?.profileImage ?? '';
    final address = _buildAddressLine(u);
    final initial = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : (phone.length >= 4 ? phone.substring(phone.length - 4) : '?');

    return Stack(
      children: [
        // Gradient background with curved bottom
        ClipPath(
          clipper: _CurveClipper(),
          child: Container(
            height: 260,
            decoration: const BoxDecoration(gradient: kPrimaryGradient),
          ),
        ),

        // Decorative circles
        Positioned(
          right: -40, top: -30,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryLight.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          left: -20, top: 120,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kAccent.withValues(alpha: 0.08),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
            child: Column(
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Profile',
                        style: TextStyle(
                            color: kSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    _EditButton(),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar + info
                Row(
                  children: [
                    // Animated avatar
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: _Avatar(imageUrl: imageUrl, initial: initial),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'Set up your profile',
                            style: TextStyle(
                                color: kSurface,
                                fontSize: name.isNotEmpty ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          if (phone.isNotEmpty)
                            _HeaderDetail(Icons.phone_rounded, phone),
                          if (email.isNotEmpty)
                            _HeaderDetail(Icons.email_outlined, email),
                          if (address.isNotEmpty)
                            _HeaderDetail(Icons.location_on_outlined, address),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── STATS CARDS ────────────────────────────────────────────────────────────

  Widget _buildStatsCards() {
    final bCtrl = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : null;

    return Obx(() {
      final total     = bCtrl?.bookings.length           ?? 0;
      final active    = bCtrl?.activeBookings.length     ?? 0;
      final completed = bCtrl?.completedBookings.length  ?? 0;
      final cancelled = bCtrl?.cancelledBookings.length  ?? 0;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            _StatCard('Total', '$total',
                Icons.receipt_long_rounded, kPrimary),
            _StatCard('Active', '$active',
                Icons.pending_actions_rounded, kWarning),
            _StatCard('Done', '$completed',
                Icons.check_circle_rounded, kSuccess),
            _StatCard('Cancelled', '$cancelled',
                Icons.cancel_rounded, kError),
          ],
        ),
      );
    });
  }

  // ── ACCOUNT MENU ───────────────────────────────────────────────────────────

  Widget _buildAccountMenu(UserDetail? u) {
    final nCtrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : null;

    return _MenuCard(items: [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        label: 'Edit Profile',
        color: kPrimary,
        onTap: () => Get.to(() => const ProfileDetailsPage()),
      ),
      _MenuItem(
        icon: Icons.calendar_today_rounded,
        label: 'My Appointments',
        color: kTeal,
        onTap: () => Get.to(() => const AppointmentsPage()),
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Chat History',
        color: kSuccess,
        onTap: () => Get.to(() => const ChatListPage()),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        color: kWarning,
        badge: nCtrl != null
            ? Obx(() {
                final c = nCtrl.unreadCount;
                return c > 0 ? _Badge('$c') : const SizedBox.shrink();
              })
            : null,
        onTap: () => Get.to(() => const NotificationsPage()),
      ),
      _MenuItem(
        icon: Icons.folder_outlined,
        label: 'Medical Records',
        color: kOrange,
        onTap: () => Get.to(() => const RecordsPage()),
      ),
      _MenuItem(
        icon: Icons.family_restroom_rounded,
        label: 'Family Report',
        color: kPink,
        onTap: () => Get.to(() => FamilyReportsPage()),
      ),
      _MenuItem(
        icon: Icons.credit_card_outlined,
        label: 'Payments',
        color: kPrimary,
        onTap: () => Get.to(() => const PaymentsPage()),
      ),
      _MenuItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Wallet',
        color: kAmber,
        onTap: () => Get.to(() => const WalletPage()),
      ),
    ]);
  }

  Widget _buildMoreMenu() {
    return _MenuCard(items: [
      _MenuItem(
        icon: Icons.lock_outline_rounded,
        label: 'Privacy & Security',
        color: kSuccess,
        onTap: () => Get.to(() => const PrivacySecurityPage()),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Help & Support',
        color: kTeal,
        onTap: () => Get.to(() => const HelpSupportPage()),
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        label: 'Log Out',
        color: kError,
        onTap: _logout,
        isDanger: true,
      ),
    ]);
  }

  // ── SKELETON LOADER ────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Stack(
            children: [
              ClipPath(
                clipper: _CurveClipper(),
                child: Container(
                    height: 260,
                    decoration:
                        const BoxDecoration(gradient: kPrimaryGradientV)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(width: 100, height: 20,
                          radius: 6, baseColor: kPrimaryMid,
                          highlightColor: kPrimary),
                      const SizedBox(height: 24),
                      Row(children: [
                        _Shimmer(width: 80, height: 80,
                            radius: 40, baseColor: kPrimaryMid,
                            highlightColor: kPrimary),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Shimmer(width: 140, height: 18,
                                radius: 6, baseColor: kPrimaryMid,
                                highlightColor: kPrimary),
                            const SizedBox(height: 8),
                            _Shimmer(width: 110, height: 12,
                                radius: 4, baseColor: kPrimaryMid,
                                highlightColor: kPrimary),
                            const SizedBox(height: 6),
                            _Shimmer(width: 130, height: 12,
                                radius: 4, baseColor: kPrimaryMid,
                                highlightColor: kPrimary),
                          ],
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Stat card skeletons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: List.generate(
                  4, (_) => Expanded(child: _Shimmer(
                      height: 80, radius: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 4)))),
            ),
          ),
          // Menu skeletons
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            decoration: BoxDecoration(
                color: kSurface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: List.generate(
                5,
                (i) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(children: [
                        _Shimmer(width: 38, height: 38, radius: 10),
                        const SizedBox(width: 12),
                        _Shimmer(width: 140, height: 14, radius: 6),
                      ]),
                    ),
                    if (i < 4)
                      Divider(height: 1, indent: 66, color: kDivider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  String _buildAddressLine(UserDetail? u) {
    if (u?.address1 == null) return '';
    final a = u!.address1!;
    return [a.street, a.landmark, a.pinCode]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  Future<void> _logout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kError,
                foregroundColor: kSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Get.back(result: true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthRepository().logout();
      Get.offAllNamed('/enterPhoneNumberPage');
    }
  }
}

// ── Curve clipper ─────────────────────────────────────────────────────────────

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String initial;
  const _Avatar({required this.imageUrl, required this.initial});

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    if (imageUrl.isNotEmpty) {
      final full = imageUrl.startsWith('http')
          ? imageUrl
          : '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
      img = NetworkImage(full);
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kSurface, width: 3),
        gradient: img == null ? kPrimaryGradient : null,
        image: img != null
            ? DecorationImage(image: img, fit: BoxFit.cover)
            : null,
        boxShadow: [
          BoxShadow(
              color: kPrimaryDark.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: img == null
          ? Center(
              child: Text(initial,
                  style: const TextStyle(
                      color: kSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)))
          : null,
    );
  }
}

// ── Header detail row ─────────────────────────────────────────────────────────

class _HeaderDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderDetail(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, color: kSurface.withValues(alpha: 0.75), size: 13),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: kSurface.withValues(alpha: 0.85), fontSize: 12)),
        ),
      ]),
    );
  }
}

// ── Edit button ───────────────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ProfileDetailsPage()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: kSurface.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kSurface.withValues(alpha: 0.4)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_outlined, color: kSurface, size: 14),
          SizedBox(width: 5),
          Text('Edit',
              style: TextStyle(
                  color: kSurface, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: kTextLight)),
        ]),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kTextLight,
              letterSpacing: 0.8)),
    );
  }
}

// ── Menu card (wraps multiple items) ──────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kTextDark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                Divider(height: 1, indent: 60, color: kDivider),
            ],
          );
        }),
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDanger;
  final Widget? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDanger = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            // Icon container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: isDanger
                      ? kError.withValues(alpha: 0.08)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon,
                  color: isDanger ? kError : color, size: 19),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDanger ? kError : kTextDark)),
            ),
            // Badge (e.g. notification count)
            if (badge != null) ...[badge!, const SizedBox(width: 6)],
            // Arrow
            if (!isDanger)
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: kTextLight),
          ]),
        ),
      ),
    );
  }
}

// ── Notification badge ────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: kError, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: const TextStyle(
              color: kSurface, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Complete profile banner ────────────────────────────────────────────────────

class _CompleteProfileBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteProfileBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kAmber.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded,
              color: kAmber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Complete your profile',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                      fontSize: 13)),
              const Text('Add your name, photo and address',
                  style: TextStyle(color: kTextMedium, fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: kAmber),
        ]),
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const _Shimmer({
    this.width,
    required this.height,
    this.radius = 8,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
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
      begin: widget.baseColor ?? kBorder,
      end: widget.highlightColor ?? kDivider,
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
        margin: widget.margin,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
