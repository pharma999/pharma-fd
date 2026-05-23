import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/appointment_controller.dart';
import 'package:home_care/Model/appointment_model.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AppointmentController());
    return _AppointmentsView(ctrl: ctrl);
  }
}

class _AppointmentsView extends StatefulWidget {
  final AppointmentController ctrl;
  const _AppointmentsView({required this.ctrl});

  @override
  State<_AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<_AppointmentsView> {
  int _tab = 0;

  static const _blue = Color(0xFF1A56DB);

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
              colors: [_blue, Color(0xFF6BC4FF)],
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
        title: const Text('My Appointments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: widget.ctrl.fetchMyAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _TabBar(selected: _tab, onTap: (i) => setState(() => _tab = i)),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (widget.ctrl.isLoadingAppointments.value) {
                return const Center(child: CircularProgressIndicator(color: _blue));
              }
              if (widget.ctrl.errorMessage.value.isNotEmpty &&
                  widget.ctrl.appointments.isEmpty) {
                return _ErrorState(
                  message: widget.ctrl.errorMessage.value,
                  onRetry: widget.ctrl.fetchMyAppointments,
                );
              }
              final list = _tab == 0
                  ? widget.ctrl.upcomingAppointments
                  : widget.ctrl.pastAppointments;

              if (list.isEmpty) {
                return _EmptyState(
                  message: _tab == 0 ? 'No upcoming appointments' : 'No past appointments',
                );
              }
              return RefreshIndicator(
                color: _blue,
                onRefresh: widget.ctrl.fetchMyAppointments,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _AppointmentCard(
                    appointment: list[i],
                    ctrl: widget.ctrl,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Tab bar ────────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _TabBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Tab(label: 'Upcoming', index: 0, selected: selected, onTap: onTap),
        const SizedBox(width: 12),
        _Tab(label: 'History', index: 1, selected: selected, onTap: onTap),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  const _Tab({required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = selected == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF1A56DB) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSel ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSel
              ? [BoxShadow(color: const Color(0xFF1A56DB).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
              color: isSel ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
      ),
    );
  }
}

// ── Appointment card ───────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentController ctrl;
  const _AppointmentCard({required this.appointment, required this.ctrl});

  static const _statusColors = {
    'PENDING': Color(0xFFF59E0B),
    'CONFIRMED': Color(0xFF1A56DB),
    'IN_PROGRESS': Color(0xFF06B6D4),
    'COMPLETED': Color(0xFF10B981),
    'CANCELLED': Color(0xFFEF4444),
    'NO_SHOW': Color(0xFF6B7280),
  };

  static const _typeIcons = {
    'HOME_VISIT': Icons.home_outlined,
    'ONLINE': Icons.video_call_outlined,
    'QUICK': Icons.bolt_outlined,
    'SCHEDULED': Icons.schedule,
    'EMERGENCY': Icons.emergency_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[appointment.status] ?? const Color(0xFF6B7280);
    final typeIcon = _typeIcons[appointment.type] ?? Icons.medical_services_outlined;
    final isUpcoming = appointment.isUpcoming;

    DateTime? dt;
    try { dt = DateTime.parse(appointment.scheduledAt).toLocal(); } catch (_) {}
    final dateStr = dt != null
        ? '${dt.day} ${_month(dt.month)} ${dt.year}'
        : appointment.scheduledAt.length > 10
            ? appointment.scheduledAt.substring(0, 10)
            : appointment.scheduledAt;
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: appointment.doctorImage != null && appointment.doctorImage!.isNotEmpty
                      ? ClipOval(child: Image.network(appointment.doctorImage!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.person, color: const Color(0xFF1A56DB), size: 28)))
                      : Icon(Icons.person, color: const Color(0xFF1A56DB), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName ?? 'Doctor',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      if (appointment.doctorSpecialty != null && appointment.doctorSpecialty!.isNotEmpty)
                        Text(appointment.doctorSpecialty!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(appointment.status.replaceAll('_', ' '),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
          ),
          // Info strip
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                if (timeStr.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
                const Spacer(),
                Icon(typeIcon, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(appointment.type.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (appointment.fee > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade500),
                  Text(appointment.fee.toStringAsFixed(0),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          // Action buttons (only for upcoming)
          if (isUpcoming)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _confirmCancel(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showDetails(context),
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ),
          if (!isUpcoming && appointment.meetingLink != null && appointment.meetingLink!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 14, color: Color(0xFF06B6D4)),
                  const SizedBox(width: 6),
                  Text('Meeting link available', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ctrl.cancelAppointment(appointment.id);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentDetailSheet(appointment: appointment),
    );
  }

  String _month(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}

// ── Detail sheet ───────────────────────────────────────────────────────────────

class _AppointmentDetailSheet extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentDetailSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Appointment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _DetailRow(Icons.person_outline, 'Doctor', appointment.doctorName ?? '—'),
          if (appointment.doctorSpecialty != null)
            _DetailRow(Icons.medical_services_outlined, 'Specialty', appointment.doctorSpecialty!),
          _DetailRow(Icons.calendar_today, 'Scheduled', appointment.scheduledAt.length > 10 ? appointment.scheduledAt.substring(0, 16).replaceAll('T', ' ') : appointment.scheduledAt),
          _DetailRow(Icons.category_outlined, 'Type', appointment.type.replaceAll('_', ' ')),
          _DetailRow(Icons.info_outline, 'Status', appointment.status.replaceAll('_', ' ')),
          if (appointment.fee > 0) _DetailRow(Icons.currency_rupee, 'Fee', '₹${appointment.fee.toStringAsFixed(0)}'),
          if (appointment.address != null && appointment.address!.isNotEmpty)
            _DetailRow(Icons.location_on_outlined, 'Address', appointment.address!),
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _DetailRow(Icons.notes_outlined, 'Notes', appointment.notes!),
          if (appointment.meetingLink != null && appointment.meetingLink!.isNotEmpty)
            _DetailRow(Icons.video_call_outlined, 'Meeting', appointment.meetingLink!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1A56DB)),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

// ── Empty / Error states ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ]),
      );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ]),
      );
}
