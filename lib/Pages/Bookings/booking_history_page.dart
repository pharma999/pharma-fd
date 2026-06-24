import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/booking_controller.dart';
import 'package:home_care/Model/booking_model.dart';
import 'package:home_care/Pages/Bookings/booking_tracking_page.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    return _BookingHistoryView(ctrl: ctrl);
  }
}

class _BookingHistoryView extends StatefulWidget {
  final BookingController ctrl;
  const _BookingHistoryView({required this.ctrl});

  @override
  State<_BookingHistoryView> createState() => _BookingHistoryViewState();
}

class _BookingHistoryViewState extends State<_BookingHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    widget.ctrl.fetchMyBookings();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BookingModel> _filter(List<BookingModel> src) {
    if (_query.isEmpty) return src;
    return src.where((b) {
      return b.serviceName.toLowerCase().contains(_query) ||
          (b.professionalName ?? '').toLowerCase().contains(_query) ||
          b.id.toLowerCase().contains(_query) ||
          b.status.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kSurface, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Booking History',
            style: TextStyle(
                color: kSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kSurface),
            onPressed: widget.ctrl.fetchMyBookings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: kSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: kSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by service, provider, ID…',
                    hintStyle: TextStyle(
                        color: kSurface.withValues(alpha: 0.6),
                        fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: kSurface.withValues(alpha: 0.7), size: 18),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: kSurface.withValues(alpha: 0.7),
                                size: 16),
                            onPressed: () => _searchCtrl.clear())
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            // Tabs
            TabBar(
              controller: _tab,
              labelColor: kSurface,
              unselectedLabelColor: kSurface.withValues(alpha: 0.55),
              indicatorColor: kAccent,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
                Tab(text: 'All'),
              ],
            ),
          ]),
        ),
      ),
      body: Obx(() {
        if (widget.ctrl.isLoadingBookings.value) {
          return _buildSkeleton();
        }
        return TabBarView(
          controller: _tab,
          children: [
            _BookingList(
              bookings: _filter(widget.ctrl.activeBookings),
              emptyMessage: 'No active bookings',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
            _BookingList(
              bookings: _filter(widget.ctrl.completedBookings),
              emptyMessage: 'No completed bookings',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
            _BookingList(
              bookings: _filter(widget.ctrl.cancelledBookings),
              emptyMessage: 'No cancelled bookings',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
            _BookingList(
              bookings: _filter(widget.ctrl.bookings.toList()),
              emptyMessage: 'No bookings yet',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(children: [
              _Shimmer(height: 12, radius: 4),
              const SizedBox(height: 8),
              _Shimmer(height: 10, radius: 4),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Booking list ──────────────────────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle),
              child: Icon(Icons.history_rounded,
                  size: 44,
                  color: kPrimary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextDark)),
            const SizedBox(height: 6),
            const Text('Pull to refresh',
                style: TextStyle(color: kTextLight, fontSize: 12)),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: bookings.length,
        itemBuilder: (_, i) {
          return TweenAnimationBuilder<double>(
            key: ValueKey(bookings[i].id),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + i * 50),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                    offset: Offset(0, 12 * (1 - v)),
                    child: child)),
            child: _BookingCard(booking: bookings[i]),
          );
        },
      ),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'PENDING':     return kWarning;
      case 'ASSIGNED':    return kOrange;
      case 'ACCEPTED':    return kPrimary;
      case 'IN_PROGRESS': return kTeal;
      case 'COMPLETED':   return kSuccess;
      case 'CANCELLED':   return kError;
      default:            return kTextMedium;
    }
  }

  String get _statusLabel =>
      booking.statusLabel.isNotEmpty ? booking.statusLabel : booking.status;

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Not scheduled';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final ap = d.hour >= 12 ? 'PM' : 'AM';
      return '${d.day} ${months[d.month]} ${d.year} • $h:${d.minute.toString().padLeft(2, '0')} $ap';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: sc.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        // Header strip
        Container(
          decoration: BoxDecoration(
            color: sc.withValues(alpha: 0.06),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(children: [
            Expanded(
              child: Text(
                booking.serviceName.isNotEmpty
                    ? booking.serviceName
                    : 'Booking #${booking.id.length > 6 ? booking.id.substring(0, 6).toUpperCase() : booking.id}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kTextDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sc.withValues(alpha: 0.25)),
              ),
              child: Text(_statusLabel,
                  style: TextStyle(
                      color: sc,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(children: [
            if ((booking.professionalName ?? '').isNotEmpty)
              _Row(Icons.person_outline_rounded,
                  booking.professionalName!),
            if (booking.scheduledAt.isNotEmpty) ...[
              const SizedBox(height: 5),
              _Row(Icons.schedule_rounded,
                  _formatDate(booking.scheduledAt)),
            ],
            if ((booking.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 5),
              _Row(Icons.location_on_outlined, booking.address!),
            ],
            const SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Row(children: [
                const Icon(Icons.currency_rupee_rounded,
                    size: 16, color: kPrimary),
                Text(booking.totalAmount.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kPrimary)),
              ]),
              if (booking.isActive)
                GestureDetector(
                  onTap: () => Get.to(() => BookingTrackingPage(
                        bookingId: booking.id,
                        serviceName: booking.serviceName.isNotEmpty
                            ? booking.serviceName
                            : 'Booking',
                        status: booking.status,
                      )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on_rounded,
                          size: 13, color: kSurface),
                      SizedBox(width: 4),
                      Text('Track',
                          style: TextStyle(
                              color: kSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: kTextLight),
      const SizedBox(width: 6),
      Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: kTextMedium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double height;
  final double radius;
  const _Shimmer({required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: kBorder, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
