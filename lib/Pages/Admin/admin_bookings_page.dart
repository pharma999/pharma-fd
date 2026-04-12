import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/booking_model.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final ctrl = Get.find<AdminController>();
  String _statusFilter = '';

  final _statuses = [
    '',
    'PENDING',
    'ACCEPTED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    ctrl.fetchAllBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('All Bookings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s.isEmpty ? 'All' : s),
                            selected: _statusFilter == s,
                            onSelected: (_) {
                              setState(() => _statusFilter = s);
                              ctrl.fetchAllBookings(
                                  status: s.isEmpty ? null : s);
                            },
                            selectedColor: const Color(0xFF1A237E)
                                .withValues(alpha: 0.15),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingBookings.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.bookings.isEmpty) {
                return const Center(child: Text('No bookings found'));
              }
              return RefreshIndicator(
                onRefresh: ctrl.fetchAllBookings,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.bookings.length,
                  itemBuilder: (_, i) =>
                      _BookingAdminTile(booking: ctrl.bookings[i], ctrl: ctrl),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BookingAdminTile extends StatelessWidget {
  final BookingModel booking;
  final AdminController ctrl;
  const _BookingAdminTile({required this.booking, required this.ctrl});

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.serviceName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                        fontSize: 11,
                        color: _statusColor(booking.status),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('₹${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
            Text(
                'Scheduled: ${booking.scheduledAt.length > 10 ? booking.scheduledAt.substring(0, 10) : booking.scheduledAt}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            if (booking.isActive) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _ActionBtn(
                    label: 'Accept',
                    color: Colors.green,
                    onTap: () =>
                        ctrl.updateBookingStatus(booking.id, 'ACCEPTED'),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: 'Cancel',
                    color: Colors.red,
                    onTap: () =>
                        ctrl.updateBookingStatus(booking.id, 'CANCELLED'),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: 'Complete',
                    color: Colors.blue,
                    onTap: () =>
                        ctrl.updateBookingStatus(booking.id, 'COMPLETED'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
