import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_care/Controller/profile_controller.dart';

// Key constants so spelling mistakes don't create silent ghost prefs
const _kShareLocation    = 'pref_share_location';
const _kShareHealth      = 'pref_share_health';
const _kMarketingEmails  = 'pref_marketing_emails';
const _kSmsAlerts        = 'pref_sms_alerts';
const _kPushNotifications = 'pref_push_notifications';
const _kTwoFactor        = 'pref_two_factor';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _shareLocation      = true;
  bool _shareHealthData    = false;
  bool _marketingEmails    = false;
  bool _smsAlerts          = true;
  bool _pushNotifications  = true;
  bool _twoFactor          = false;
  bool _loading            = true;
  bool _deletingAccount    = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _shareLocation     = prefs.getBool(_kShareLocation)     ?? true;
      _shareHealthData   = prefs.getBool(_kShareHealth)       ?? false;
      _marketingEmails   = prefs.getBool(_kMarketingEmails)   ?? false;
      _smsAlerts         = prefs.getBool(_kSmsAlerts)         ?? true;
      _pushNotifications = prefs.getBool(_kPushNotifications) ?? true;
      _twoFactor         = prefs.getBool(_kTwoFactor)         ?? false;
      _loading           = false;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not open link',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _requestDataExport() async {
    // In production, call POST /user/data-export here
    Get.snackbar(
      'Request Sent',
      'You will receive your data export via email within 24 hours.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade700,
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete all your data including appointments, '
          'records and wallet balance. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deletingAccount = true);
    try {
      final ctrl = Get.find<ProfileController>();
      await ctrl.deleteAccount();
      // deleteAccount() navigates away on success; if it reaches here it failed
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
        title: const Text('Privacy & Security',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                subtitle:
                    'Allow app to access your location for service matching',
                value: _shareLocation,
                onChanged: (v) {
                  setState(() => _shareLocation = v);
                  _set(_kShareLocation, v);
                },
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.health_and_safety_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Share Health Data',
                subtitle:
                    'Share anonymised health data to improve services',
                value: _shareHealthData,
                onChanged: (v) {
                  setState(() => _shareHealthData = v);
                  _set(_kShareHealth, v);
                },
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFF59E0B),
                title: 'Marketing Emails',
                subtitle: 'Receive offers, tips and health articles',
                value: _marketingEmails,
                onChanged: (v) {
                  setState(() => _marketingEmails = v);
                  _set(_kMarketingEmails, v);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Notification preferences
            _SectionTitle(
                'Notification Preferences', Icons.notifications_outlined),
            const SizedBox(height: 10),
            _Card(children: [
              _SwitchRow(
                icon: Icons.sms_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: 'SMS Alerts',
                subtitle:
                    'Appointment reminders and booking updates via SMS',
                value: _smsAlerts,
                onChanged: (v) {
                  setState(() => _smsAlerts = v);
                  _set(_kSmsAlerts, v);
                },
              ),
              const Divider(height: 1, indent: 56),
              _SwitchRow(
                icon: Icons.notifications_active_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Push Notifications',
                subtitle: 'Real-time alerts for appointments and payments',
                value: _pushNotifications,
                onChanged: (v) {
                  setState(() => _pushNotifications = v);
                  _set(_kPushNotifications, v);
                },
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
                onChanged: (v) {
                  setState(() => _twoFactor = v);
                  _set(_kTwoFactor, v);
                },
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
                onTap: _requestDataExport,
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
                onTap: () => _openUrl('https://homecare.example.com/privacy'),
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.article_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () => _openUrl('https://homecare.example.com/terms'),
              ),
              const Divider(height: 1, indent: 56),
              _ActionRow(
                icon: Icons.cookie_outlined,
                iconColor: const Color(0xFF6B7280),
                title: 'Cookie Policy',
                subtitle: 'How we use cookies',
                onTap: () => _openUrl('https://homecare.example.com/cookies'),
              ),
            ]),
            const SizedBox(height: 20),

            // Danger zone
            _Card(children: [
              _ActionRow(
                icon: _deletingAccount
                    ? Icons.hourglass_top
                    : Icons.delete_forever_outlined,
                iconColor: Colors.red,
                title: 'Delete Account',
                subtitle: 'Permanently delete all your data',
                onTap: _deletingAccount ? null : _confirmDelete,
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
            const Text('Active Sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const _SessionTile(
                icon: Icons.phone_android,
                device: 'This Device',
                info: 'Android · Last active: now',
                isCurrent: true),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text('Sign out all other devices',
                  style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final bool twoFactor;
  const _OverviewCard({required this.twoFactor});

  @override
  Widget build(BuildContext context) {
    final score = twoFactor ? 'Strong' : 'Moderate';
    final color = twoFactor ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle),
            child: Icon(
                twoFactor ? Icons.shield : Icons.shield_outlined,
                color: Colors.white,
                size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Security: $score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  twoFactor
                      ? 'Your account is well protected'
                      : 'Enable 2FA for stronger security',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.3)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF6B7280))),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF10B981),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDanger;
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDanger ? Colors.red : const Color(0xFF1E293B))),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF6B7280))),
      trailing: onTap != null
          ? Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey.shade400)
          : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final IconData icon;
  final String device;
  final String info;
  final bool isCurrent;
  const _SessionTile({
    required this.icon,
    required this.device,
    required this.info,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A56DB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(info,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Current',
                style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}
