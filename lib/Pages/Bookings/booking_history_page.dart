import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static const _blue = Color(0xFF1A56DB);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    widget.ctrl.fetchMyBookings();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Booking History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: widget.ctrl.fetchMyBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Obx(() {
        if (widget.ctrl.isLoadingBookings.value) {
          return const Center(child: CircularProgressIndicator(color: _blue));
        }
        return TabBarView(
          controller: _tab,
          children: [
            _BookingList(
              bookings: widget.ctrl.activeBookings,
              emptyMessage: 'No active bookings',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
            _BookingList(
              bookings: widget.ctrl.pastBookings,
              emptyMessage: 'No past bookings',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
            _BookingList(
              bookings: widget.ctrl.bookings.toList(),
              emptyMessage: 'No bookings yet',
              onRefresh: widget.ctrl.fetchMyBookings,
            ),
          ],
        );
      }),
    );
  }
}

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1A56DB),
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'ACCEPTED':
        return const Color(0xFF1A56DB);
      case 'IN_PROGRESS':
        return const Color(0xFF06B6D4);
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Not scheduled';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '${d.day} ${months[d.month]} ${d.year} • $h:${d.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName.isNotEmpty
                        ? booking.serviceName
                        : 'Booking #${booking.id.length > 6 ? booking.id.substring(0, 6).toUpperCase() : booking.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1E293B)),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.replaceAll('_', ' '),
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if ((booking.professionalName ?? '').isNotEmpty)
                  _row(Icons.person_outline, booking.professionalName!),
                if (booking.scheduledAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(Icons.schedule_outlined, _formatDate(booking.scheduledAt)),
                ],
                if ((booking.address ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(Icons.location_on_outlined, booking.address!),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A56DB)),
                    ),
                    if (booking.isActive)
                      TextButton.icon(
                        onPressed: () => Get.to(() => BookingTrackingPage(
                              bookingId: booking.id,
                              serviceName: booking.serviceName.isNotEmpty
                                  ? booking.serviceName
                                  : 'Booking',
                              status: booking.status,
                            )),
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text('Track'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1A56DB),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      )
                    else
                      Text(
                        'Booking',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}
