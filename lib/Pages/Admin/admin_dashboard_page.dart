import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Obx(() => Text(
              ctrl.isSuperAdmin ? 'Super Admin Panel' : 'Admin Dashboard',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: ctrl.fetchAnalytics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.fetchAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Platform Overview'),
              const SizedBox(height: 12),
              Obx(() {
                if (ctrl.isLoadingAnalytics.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final a = ctrl.analytics.value;
                if (a == null) {
                  return const Center(child: Text('No analytics data'));
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        _StatCard(
                          label: 'Total Users',
                          value: a.totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Revenue',
                          value: '₹${(a.totalRevenue / 1000).toStringAsFixed(1)}K',
                          icon: Icons.currency_rupee,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Doctors',
                          value: a.totalDoctors.toString(),
                          icon: Icons.medical_services,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Nurses',
                          value: a.totalNurses.toString(),
                          icon: Icons.local_hospital,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Hospitals',
                          value: a.totalHospitals.toString(),
                          icon: Icons.business,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Bookings',
                          value: a.totalBookings.toString(),
                          icon: Icons.bookmark,
                          color: Colors.indigo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Appointments',
                          value: a.totalAppointments.toString(),
                          icon: Icons.calendar_today,
                          color: Colors.cyan,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Active SOS',
                          value: a.activeEmergencies.toString(),
                          icon: Icons.emergency,
                          color: Colors.red,
                          highlight: a.activeEmergencies > 0,
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              _QuickActionsGrid(),
              const SizedBox(height: 24),
              Obx(() {
                if (!ctrl.isSuperAdmin) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Super Admin'),
                    const SizedBox(height: 12),
                    _SuperAdminGrid(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: highlight
              ? Border.all(color: Colors.red.shade300, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (highlight)
                  const Icon(Icons.warning_amber,
                      color: Colors.red, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_ActionItem> _actions = const [
    _ActionItem('Pending Approvals', Icons.pending_actions, Color(0xFF5C6BC0),
        '/admin/approvals'),
    _ActionItem(
        'User Management', Icons.manage_accounts, Color(0xFF26A69A), '/admin/users'),
    _ActionItem(
        'All Bookings', Icons.bookmark_added, Color(0xFFEF6C00), '/admin/bookings'),
    _ActionItem('Active Emergencies', Icons.emergency, Color(0xFFE53935),
        '/admin/emergencies'),
    _ActionItem('Support Tickets', Icons.support_agent, Color(0xFF7B1FA2),
        '/admin/tickets'),
    _ActionItem('Subscription Plans', Icons.card_membership,
        Color(0xFF00897B), '/admin/plans'),
    _ActionItem('Service Zones', Icons.map, Color(0xFF1565C0), '/admin/zones'),
    _ActionItem('Services & Categories', Icons.category, Color(0xFF558B2F),
        '/admin/services'),
  ];

  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _actions.length,
      itemBuilder: (_, i) => _ActionTile(item: _actions[i]),
    );
  }
}

class _SuperAdminGrid extends StatelessWidget {
  final List<_ActionItem> _items = const [
    _ActionItem('Revenue Report', Icons.bar_chart, Color(0xFF1B5E20),
        '/super-admin/revenue'),
    _ActionItem(
        'Manage Admins', Icons.admin_panel_settings, Color(0xFF4A148C), '/super-admin/admins'),
    _ActionItem('Platform Settings', Icons.settings, Color(0xFF37474F),
        '/super-admin/settings'),
  ];

  const _SuperAdminGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) => _ActionTile(item: _items[i]),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _ActionItem(this.label, this.icon, this.color, this.route);
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
