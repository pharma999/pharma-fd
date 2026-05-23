import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _shareLocation = true;
  bool _shareHealthData = false;
  bool _marketingEmails = false;
  bool _smsAlerts = true;
  bool _pushNotifications = true;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Privacy & Security',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security overview card
            _OverviewCard(twoFactor: _twoFactor),
            const SizedBox(height: 20),

            // Privacy settings
            _SectionTitle('Privacy Settings', Icons.visibility_outlined),
            const SizedBox(height: 10),
            _Card(children: [
              _SwitchRow(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF1A56DB),
                title: 'Share Location',
                subtitle: 'Allow app to access your location for service matching',
                value: _shareLocation,
                onChanged: (v) => setState(() => _shareLocation = v),
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.health_and_safety_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Share Health Data',
                subtitle: 'Share anonymised health data to improve services',
                value: _shareHealthData,
                onChanged: (v) => setState(() => _shareHealthData = v),
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFF59E0B),
                title: 'Marketing Emails',
                subtitle: 'Receive offers, tips and health articles',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),
            ]),
            const SizedBox(height: 20),

            // Notification preferences
            _SectionTitle('Notification Preferences', Icons.notifications_outlined),
            const SizedBox(height: 10),
            _Card(children: [
              _SwitchRow(
                icon: Icons.sms_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: 'SMS Alerts',
                subtitle: 'Appointment reminders and booking updates via SMS',
                value: _smsAlerts,
                onChanged: (v) => setState(() => _smsAlerts = v),
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.notifications_active_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Push Notifications',
                subtitle: 'Real-time alerts for appointments and payments',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
            ]),
            const SizedBox(height: 20),

            // Security settings
            _SectionTitle('Security', Icons.lock_outlined),
            const SizedBox(height: 10),
            _Card(children: [
              _SwitchRow(
                icon: Icons.security_outlined,
                iconColor: const Color(0xFF10B981),
                title: 'Two-Factor Auth',
                subtitle: 'Extra OTP verification on login',
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.devices_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Active Sessions',
                subtitle: 'Manage devices where you are logged in',
                onTap: () => _showSessions(context),
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF1A56DB),
                title: 'Download My Data',
                subtitle: 'Request a copy of all your data',
                onTap: () => _requestData(context),
              ),
            ]),
            const SizedBox(height: 20),

            // Legal
            _SectionTitle('Legal', Icons.gavel_outlined),
            const SizedBox(height: 10),
            _Card(children: [
              _ActionRow(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.article_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.cookie_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Cookie Policy',
                subtitle: 'How we use cookies',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),

            // Danger zone
            _Card(children: [
              _ActionRow(
                icon: Icons.delete_forever_outlined,
                iconColor: Colors.red,
                title: 'Delete Account',
                subtitle: 'Permanently delete all your data',
                onTap: () => _confirmDelete(context),
                isDanger: true,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSessions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _SessionTile(icon: Icons.phone_android, device: 'This Device', info: 'Android · Last active: now', isCurrent: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _requestData(BuildContext context) {
    Get.snackbar('Request Sent', 'You will receive your data via email within 24 hours.',
        backgroundColor: Colors.blue.shade50, colorText: Colors.blue.shade700,
        snackPosition: SnackPosition.BOTTOM);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This will permanently delete all your data including appointments, records and wallet balance. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Account Deletion', 'Request submitted. Account will be deleted within 7 days.',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Overview card ──────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final bool twoFactor;
  const _OverviewCard({required this.twoFactor});

  @override
  Widget build(BuildContext context) {
    final score = twoFactor ? 'Strong' : 'Moderate';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Account Security', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(score, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            twoFactor ? '2FA enabled · Your account is well protected' : 'Enable 2FA to strengthen your security',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ])),
      ]),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF6B7280)),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280), letterSpacing: 0.5)),
    ]);
  }
}

// ── Card wrapper ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

// ── Switch row ─────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 2),
        ])),
        Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF10B981), activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.4)),
      ]),
    );
  }
}

// ── Action row ─────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;
  const _ActionRow({required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.onTap, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDanger ? Colors.red : const Color(0xFF1A1F36),
            )),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ]),
      ),
    );
  }
}

// ── Session tile ───────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final IconData icon;
  final String device;
  final String info;
  final bool isCurrent;
  const _SessionTile({required this.icon, required this.device, required this.info, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Colors.grey.shade500),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(device, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text('Current', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        Text(info, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ])),
    ]);
  }
}
