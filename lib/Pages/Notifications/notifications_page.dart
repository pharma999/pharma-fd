import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Model/emergency_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kSurface,
                fontSize: 18)),
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kSurface, size: 20),
        ),
        actions: [
          Obx(() {
            if (ctrl.unreadCount == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: ctrl.markAllRead,
              icon: const Icon(Icons.done_all_rounded,
                  color: kSurface, size: 18),
              label: const Text('All read',
                  style: TextStyle(color: kSurface, fontSize: 12)),
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kSurface),
            onPressed: ctrl.fetchNotifications,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) return _buildSkeleton();

        if (ctrl.error.value.isNotEmpty && ctrl.notifications.isEmpty) {
          return _ErrorState(
            message: ctrl.error.value,
            onRetry: ctrl.fetchNotifications,
          );
        }

        if (ctrl.notifications.isEmpty) return _EmptyState();

        final unread = ctrl.notifications.where((n) => !n.isRead).toList();
        final read   = ctrl.notifications.where((n) =>  n.isRead).toList();

        return RefreshIndicator(
          color: kPrimary,
          onRefresh: ctrl.fetchNotifications,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(label: 'New', count: unread.length,
                    color: kPrimary),
                ...unread.map((n) => _NotifTile(notif: n, ctrl: ctrl)),
              ],
              if (read.isNotEmpty) ...[
                const _SectionHeader(label: 'Earlier', color: kTextLight),
                ...read.map((n) => _NotifTile(notif: n, ctrl: ctrl)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder)),
        child: Row(children: [
          _Shimmer(width: 42, height: 42, radius: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 160, height: 13, radius: 5),
                  const SizedBox(height: 8),
                  _Shimmer(width: 220, height: 11, radius: 4),
                  const SizedBox(height: 6),
                  _Shimmer(width: 80, height: 9, radius: 3),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;
  final Color color;
  const _SectionHeader(
      {required this.label, this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.8)),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Text('$count',
                style: const TextStyle(
                    color: kSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ]),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final NotificationController ctrl;
  const _NotifTile({required this.notif, required this.ctrl});

  // All colors from colors_coning.dart
  static const _typeData = <String, (IconData, Color)>{
    'EMERGENCY':   (Icons.emergency_rounded,       kError),
    'BOOKING':     (Icons.calendar_today_rounded,  kPrimary),
    'APPOINTMENT': (Icons.medical_services_rounded, kSuccess),
    'PAYMENT':     (Icons.payment_rounded,          kGreen),
    'SUPPORT':     (Icons.support_agent_rounded,    kPurple),
  };

  (IconData, Color) _meta() =>
      _typeData[notif.type.toUpperCase()] ??
      (Icons.notifications_rounded, kWarning);

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _meta();
    final isUnread = !notif.isRead;

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kSuccess.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.done_all_rounded, color: kSurface),
      ),
      onDismissed: (_) => ctrl.markRead(notif.id),
      child: GestureDetector(
        onTap: () { if (isUnread) ctrl.markRead(notif.id); },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isUnread
                ? color.withValues(alpha: 0.05)
                : kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? color.withValues(alpha: 0.2)
                  : kBorder,
            ),
            boxShadow: [
              BoxShadow(
                  color: kTextDark.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Icon badge
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                      child: Text(notif.title,
                          style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: kTextDark)),
                    ),
                    if (isUnread)
                      Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(left: 6, top: 4),
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Text(notif.message,
                      style: const TextStyle(
                          fontSize: 13, color: kTextMedium),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(_formatTime(notif.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: kTextLight)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt   = DateTime.parse(iso).toLocal();
      final now  = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }
}

// ── Empty / Error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(Icons.notifications_none_rounded,
                size: 44, color: kPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No Notifications Yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text(
              'Booking updates and messages\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMedium, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded,
            size: 52, color: kError.withValues(alpha: 0.6)),
        const SizedBox(height: 12),
        Text(message,
            style: const TextStyle(color: kTextMedium),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: kSurface),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      ]),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const _Shimmer({this.width, required this.height, this.radius = 8});

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
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
