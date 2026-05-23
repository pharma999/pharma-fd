import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/auth_repository.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Model/user_detail_model.dart';
import 'package:home_care/Pages/Bookings/booking_history_page.dart';
import 'package:home_care/Pages/Notifications/notifications_page.dart';
import 'package:home_care/Pages/Profile/appointments_page.dart';
import 'package:home_care/Pages/Profile/FamilyReport/family_report.dart';
import 'package:home_care/Pages/Profile/help_support_page.dart';
import 'package:home_care/Pages/Profile/payments_page.dart';
import 'package:home_care/Pages/Profile/privacy_security_page.dart';
import 'package:home_care/Pages/Profile/profile_details_page.dart';
import 'package:home_care/Pages/Profile/records_page.dart';
import 'package:home_care/Pages/Profile/wallet_page.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final ProfileController _ctrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Obx(() {
        final u = _ctrl.user.value;
        final isLoading = _ctrl.isLoading.value;

        if (isLoading && u == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // ── Gradient header ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(u)),

            // ── Incomplete profile nudge ──────────────────────────────────
            if (u == null || u.name.trim().isEmpty)
              SliverToBoxAdapter(
                child: _CompleteProfileBanner(onTap: () =>
                    Get.to(() => const ProfileDetailsPage())),
              ),

            // ── Quick stats row ───────────────────────────────────────────
            if (u != null)
              SliverToBoxAdapter(child: _buildStatsRow(u)),

            // ── Dashboard grid ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Section(
                title: 'Dashboard',
                child: _buildDashboardGrid(),
              ),
            ),

            // ── Account info ──────────────────────────────────────────────
            if (u != null)
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Account',
                  child: _buildAccountInfo(u),
                ),
              ),

            // ── Settings ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Section(
                title: 'Settings',
                child: _buildSettings(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserDetail? u) {
    final name = u?.name ?? '';
    final phone = u?.phoneNumber ?? '';
    final imageUrl = u?.profileImage ?? '';
    final address = _buildAddressLine(u);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF6BC4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // Top row: title + edit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileDetailsPage()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit_outlined,
                              color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text('Edit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar + name
              Row(
                children: [
                  // Avatar
                  _Avatar(imageUrl: imageUrl, name: name),
                  const SizedBox(width: 18),
                  // Name & details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : 'Set up your profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: name.isNotEmpty ? 20 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (phone.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.phone,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(phone,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ]),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white60, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats row (blood group, role, status) ─────────────────────────────────

  Widget _buildStatsRow(UserDetail u) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Blood Group',
            value: u.bloodGroup.isNotEmpty ? u.bloodGroup : '—',
            icon: Icons.water_drop,
            color: Colors.red.shade400,
          ),
          _divider(),
          _StatCell(
            label: 'Gender',
            value: _shortGender(u.gender),
            icon: Icons.person,
            color: const Color(0xFF1A56DB),
          ),
          _divider(),
          _StatCell(
            label: 'Status',
            value: u.status,
            icon: Icons.circle,
            color: u.status == 'ACTIVE'
                ? Colors.green.shade500
                : Colors.orange.shade500,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: Colors.grey.shade200);

  String _shortGender(String g) {
    if (g == 'MALE') return 'Male';
    if (g == 'FEMALE') return 'Female';
    if (g == 'OTHER') return 'Other';
    return '—';
  }

  // ── Dashboard grid ────────────────────────────────────────────────────────

  Widget _buildDashboardGrid() {
    final items = [
      _GridItem('Appointments', Icons.calendar_today, const Color(0xFF1A56DB),
          () => Get.to(() => const AppointmentsPage())),
      _GridItem('Booking History', Icons.history_rounded, const Color(0xFF0EA5E9),
          () => Get.to(() => const BookingHistoryPage())),
      _GridItem('Records', Icons.folder_outlined, const Color(0xFF10B981),
          () => Get.to(() => const RecordsPage())),
      _GridItem('Family Report', Icons.family_restroom, const Color(0xFF8B5CF6),
          () => Get.to(() => FamilyReportsPage())),
      _GridItem('Payments', Icons.credit_card_outlined, const Color(0xFFEF4444),
          () => Get.to(() => const PaymentsPage())),
      _GridItem('Wallet', Icons.account_balance_wallet_outlined,
          const Color(0xFFF59E0B), () => Get.to(() => const WalletPage())),
      _GridItem('Help & Support', Icons.headset_mic_outlined,
          const Color(0xFF06B6D4), () => Get.to(() => const HelpSupportPage())),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Account info ──────────────────────────────────────────────────────────

  Widget _buildAccountInfo(UserDetail u) {
    return Column(
      children: [
        _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Role',
            value: u.role,
            color: const Color(0xFF1A56DB)),
        _InfoRow(
            icon: Icons.card_membership_outlined,
            label: 'Plan',
            value: u.userService,
            color: const Color(0xFF8B5CF6)),
        _InfoRow(
            icon: Icons.security_outlined,
            label: 'Account',
            value: u.blockStatus,
            color: u.blockStatus == 'UNBLOCKED'
                ? Colors.green
                : Colors.red),
      ],
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Widget _buildSettings() {
    return Column(
      children: [
        _SettingsRow(
          icon: Icons.person_outline,
          label: 'Edit Profile',
          color: const Color(0xFF1A56DB),
          onTap: () => Get.to(() => const ProfileDetailsPage()),
        ),
        _SettingsRow(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          color: const Color(0xFFF59E0B),
          onTap: () => Get.to(() => const NotificationsPage()),
        ),
        _SettingsRow(
          icon: Icons.lock_outline,
          label: 'Privacy & Security',
          color: const Color(0xFF10B981),
          onTap: () => Get.to(() => const PrivacySecurityPage()),
        ),
        _SettingsRow(
          icon: Icons.help_outline,
          label: 'Help & Support',
          color: const Color(0xFF06B6D4),
          onTap: () => Get.to(() => const HelpSupportPage()),
        ),
        _SettingsRow(
          icon: Icons.logout,
          label: 'Log Out',
          color: Colors.red,
          onTap: _logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content:
            const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Get.back(result: true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthRepository().logout();
      Get.offAllNamed('/enterPhoneNumberPage');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _buildAddressLine(UserDetail? u) {
    if (u?.address1 == null) return '';
    final a = u!.address1!;
    return [a.street, a.landmark, a.pinCode]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  const _Avatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    if (imageUrl.isNotEmpty) {
      final full = imageUrl.startsWith('http')
          ? imageUrl
          : '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
      img = NetworkImage(full);
    }

    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        color: Colors.white.withValues(alpha: 0.2),
        image: img != null
            ? DecorationImage(image: img, fit: BoxFit.cover)
            : null,
      ),
      child: img == null
          ? Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)))
          : null,
    );
  }
}

// ── Stat cell ─────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCell(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Grid item model ───────────────────────────────────────────────────────────

class _GridItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _GridItem(this.label, this.icon, this.color, this.onTap);
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36))),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Settings row ──────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SettingsRow(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap,
      this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDestructive ? Colors.red : const Color(0xFF1A1F36))),
        trailing: isDestructive
            ? null
            : Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
      ),
    );
  }
}

// ── Complete profile banner ───────────────────────────────────────────────────

class _CompleteProfileBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteProfileBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Colors.amber.shade700, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complete your profile',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                          fontSize: 13)),
                  Text('Add your name, blood group and address',
                      style: TextStyle(
                          color: Colors.amber.shade700, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.amber.shade700),
          ],
        ),
      ),
    );
  }
}
