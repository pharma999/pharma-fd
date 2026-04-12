import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Model/emergency_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6BC4FF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Obx(() {
            if (ctrl.unreadCount == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: ctrl.markAllRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: ctrl.fetchNotifications,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.error.value.isNotEmpty && ctrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 12),
                Text(ctrl.error.value,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: ctrl.fetchNotifications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (ctrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none,
                    size: 72, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('No notifications yet',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600])),
              ],
            ),
          );
        }

        final unread =
            ctrl.notifications.where((n) => !n.isRead).toList();
        final read = ctrl.notifications.where((n) => n.isRead).toList();

        return RefreshIndicator(
          onRefresh: ctrl.fetchNotifications,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(
                  label: 'New',
                  count: unread.length,
                  color: const Color(0xFF6BC4FF),
                ),
                ...unread.map((n) => _NotifTile(notif: n, ctrl: ctrl)),
              ],
              if (read.isNotEmpty) ...[
                _SectionHeader(label: 'Earlier', color: Colors.grey),
                ...read.map((n) => _NotifTile(notif: n, ctrl: ctrl)),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;
  final Color color;
  const _SectionHeader(
      {required this.label, this.count, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.6)),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      );
}

// ── Notification tile ──────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final NotificationController ctrl;
  const _NotifTile({required this.notif, required this.ctrl});

  static const _typeData = {
    'EMERGENCY': (Icons.emergency, Color(0xFFE53935)),
    'BOOKING': (Icons.calendar_today, Color(0xFF1E88E5)),
    'APPOINTMENT': (Icons.medical_services, Color(0xFF00897B)),
    'PAYMENT': (Icons.payment, Color(0xFF43A047)),
    'SUPPORT': (Icons.support_agent, Color(0xFF8E24AA)),
  };

  (IconData, Color) _meta() =>
      _typeData[notif.type.toUpperCase()] ??
      (Icons.notifications, const Color(0xFFFB8C00));

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
        color: Colors.green.shade400,
        child: const Icon(Icons.done_all, color: Colors.white),
      ),
      onDismissed: (_) => ctrl.markRead(notif.id),
      child: GestureDetector(
        onTap: () {
          if (isUnread) ctrl.markRead(notif.id);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isUnread
                ? color.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? color.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 42,
                  height: 42,
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
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                        notif.message,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(notif.createdAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
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
