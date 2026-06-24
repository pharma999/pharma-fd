import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/booking_controller.dart';
import 'package:home_care/Model/booking_model.dart';
import 'package:home_care/Pages/Bookings/booking_tracking_page.dart';
import 'package:home_care/Pages/Chat/booking_chat_utils.dart';
import 'package:home_care/Pages/Quick/quick_page.dart';

// ── BookingsTabPage ───────────────────────────────────────────────────────────
// Central booking management hub — lives inside the BottomAppBar.
// Shows live booking card (if any), then tabbed sections for
// Active | Completed | Cancelled bookings.
// Real-time updates come via BookingController's WebSocket.

class BookingsTabPage extends StatefulWidget {
  const BookingsTabPage({super.key});

  @override
  State<BookingsTabPage> createState() => _BookingsTabPageState();
}

class _BookingsTabPageState extends State<BookingsTabPage>
    with SingleTickerProviderStateMixin {
  late final BookingController _ctrl;
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<BookingController>();
    _tab = TabController(length: 3, vsync: this);
    // Refresh on open so data is always fresh
    _ctrl.fetchMyBookings();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Live booking card — shown above tabs when IN_PROGRESS
          Obx(() {
            final live = _ctrl.liveBooking;
            if (live == null) return const SizedBox.shrink();
            return _LiveBookingBanner(booking: live);
          }),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: kPrimary,
              unselectedLabelColor: kTextLight,
              indicatorColor: kPrimary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              tabs: [
                Obx(() {
                  final count = _ctrl.activeBookings.length;
                  return _TabLabel('Active', count > 0 ? count : null);
                }),
                const Tab(text: 'Completed'),
                const Tab(text: 'Cancelled'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingBookings.value) {
                return const Center(
                    child: CircularProgressIndicator(color: kPrimary));
              }
              return TabBarView(
                controller: _tab,
                children: [
                  _BookingListView(
                    bookings: _ctrl.activeBookings,
                    emptyIcon: Icons.pending_actions_rounded,
                    emptyTitle: 'No active bookings',
                    emptySubtitle:
                        'Your upcoming and in-progress services\nwill appear here.',
                    onRefresh: _ctrl.fetchMyBookings,
                    showTrack: true,
                  ),
                  _BookingListView(
                    bookings: _ctrl.completedBookings,
                    emptyIcon: Icons.check_circle_outline_rounded,
                    emptyTitle: 'No completed bookings',
                    emptySubtitle:
                        'Successfully completed services\nwill appear here.',
                    onRefresh: _ctrl.fetchMyBookings,
                  ),
                  _BookingListView(
                    bookings: _ctrl.cancelledBookings,
                    emptyIcon: Icons.cancel_outlined,
                    emptyTitle: 'No cancelled bookings',
                    emptySubtitle: 'Cancelled or expired bookings\nappear here.',
                    onRefresh: _ctrl.fetchMyBookings,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      // FAB → quick book
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const QuickServicesPage()),
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Book Service',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false, // root tab — no back button
      backgroundColor: kPrimary,
      title: const Text('My Bookings',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
      actions: [
        Obx(() => _ctrl.isLoadingBookings.value
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)))
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _ctrl.fetchMyBookings,
              )),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
    );
  }
}

// ── Live Booking Banner ───────────────────────────────────────────────────────

class _LiveBookingBanner extends StatelessWidget {
  final BookingModel booking;
  const _LiveBookingBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.to(() => BookingTrackingPage(
                bookingId: booking.id,
                serviceName: booking.serviceName.isNotEmpty
                    ? booking.serviceName
                    : 'Healthcare Service',
                status: booking.status,
              )),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live pill
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: kAccent),
                      ),
                      const SizedBox(width: 5),
                      const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.serviceName.isNotEmpty
                          ? booking.serviceName
                          : 'Healthcare Service',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 16),
                ]),
                const SizedBox(height: 10),
                // Status row
                Row(children: [
                  const Icon(Icons.engineering_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    booking.statusLabel,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  if ((booking.professionalName ?? '').isNotEmpty)
                    Text(
                      booking.professionalName!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                ]),
                const SizedBox(height: 12),
                // Action row
                Row(children: [
                  _LiveAction(
                    icon: Icons.location_on_rounded,
                    label: 'Track',
                    onTap: () => Get.to(() => BookingTrackingPage(
                          bookingId: booking.id,
                          serviceName: booking.serviceName.isNotEmpty
                              ? booking.serviceName
                              : 'Service',
                          status: booking.status,
                        )),
                  ),
                  const SizedBox(width: 8),
                  _LiveAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    onTap: () => openBookingChat(booking.id),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LiveAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Tab label with badge ──────────────────────────────────────────────────────

class _TabLabel extends StatelessWidget {
  final String label;
  final int? count;
  const _TabLabel(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Booking List View ─────────────────────────────────────────────────────────

class _BookingListView extends StatelessWidget {
  final List<BookingModel> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final bool showTrack;

  const _BookingListView({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    this.showTrack = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: bookings[i],
          showTrack: showTrack,
        ),
      ),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool showTrack;
  const _BookingCard({required this.booking, this.showTrack = false});

  Color get _statusColor {
    switch (booking.status) {
      case 'PENDING':      return kWarning;
      case 'ASSIGNED':     return const Color(0xFFF97316);
      case 'ACCEPTED':     return kPrimary;
      case 'IN_PROGRESS':  return kPurple;
      case 'COMPLETED':    return kSuccess;
      case 'CANCELLED':    return kError;
      case 'EXPIRED':      return kTextLight;
      case 'REJECTED':     return kError;
      default:             return kTextMedium;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case 'PENDING':      return Icons.hourglass_top_rounded;
      case 'ASSIGNED':     return Icons.person_search_rounded;
      case 'ACCEPTED':     return Icons.directions_run_rounded;
      case 'IN_PROGRESS':  return Icons.engineering_rounded;
      case 'COMPLETED':    return Icons.verified_rounded;
      case 'CANCELLED':    return Icons.cancel_rounded;
      case 'EXPIRED':      return Icons.timer_off_rounded;
      case 'REJECTED':     return Icons.thumb_down_outlined;
      default:             return Icons.info_outlined;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = d.hour > 12
          ? d.hour - 12
          : (d.hour == 0 ? 12 : d.hour);
      final ap = d.hour >= 12 ? 'PM' : 'AM';
      return '${d.day} ${months[d.month]} • $h:${d.minute.toString().padLeft(2, '0')} $ap';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: booking.isInProgress
              ? kPrimary.withValues(alpha: 0.3)
              : kBorder,
          width: booking.isInProgress ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(children: [
              Icon(_statusIcon, size: 16, color: _statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.serviceName.isNotEmpty
                      ? booking.serviceName
                      : 'Booking #${booking.id.length > 6 ? booking.id.substring(0, 6).toUpperCase() : booking.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: kTextDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.statusLabel,
                  style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((booking.professionalName ?? '').isNotEmpty)
                  _InfoRow(
                      icon: Icons.person_outline_rounded,
                      text: booking.professionalName!),
                if (_formatDate(booking.scheduledAt).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.schedule_outlined,
                      text: _formatDate(booking.scheduledAt)),
                ],
                if ((booking.address ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: booking.address!),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Amount
                    Row(children: [
                      const Icon(Icons.currency_rupee_rounded,
                          color: kPrimary, size: 18),
                      Text(
                        booking.totalAmount.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: kPrimary),
                      ),
                    ]),
                    // Actions
                    Row(children: [
                      if (showTrack && booking.isActive) ...[
                        _ActionChip(
                          icon: Icons.location_on_rounded,
                          label: 'Track',
                          color: kPrimary,
                          onTap: () =>
                              Get.to(() => BookingTrackingPage(
                                    bookingId: booking.id,
                                    serviceName: booking.serviceName
                                            .isNotEmpty
                                        ? booking.serviceName
                                        : 'Service',
                                    status: booking.status,
                                  )),
                        ),
                        const SizedBox(width: 6),
                        _ActionChip(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Chat',
                          color: kTeal,
                          onTap: () => openBookingChat(booking.id),
                        ),
                      ] else
                        Text(
                          _formatDate(booking.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: kTextLight),
                        ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: kTextLight),
      const SizedBox(width: 6),
      Expanded(
        child: Text(text,
            style: const TextStyle(fontSize: 12, color: kTextMedium),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 52, color: kPrimary.withValues(alpha: 0.35)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: kTextMedium, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const QuickServicesPage()),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Book a Service',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
