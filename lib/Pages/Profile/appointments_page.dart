import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
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

class _AppointmentsViewState extends State<_AppointmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kPrimary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kSurface, size: 20),
        ),
        title: const Text('My Appointments',
            style: TextStyle(
                color: kSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kSurface),
            onPressed: widget.ctrl.fetchMyAppointments,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: kSurface,
          unselectedLabelColor: kSurface.withValues(alpha: 0.6),
          indicatorColor: kAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Obx(() {
        if (widget.ctrl.isLoadingAppointments.value) {
          return _buildSkeleton();
        }
        if (widget.ctrl.errorMessage.value.isNotEmpty &&
            widget.ctrl.appointments.isEmpty) {
          return _ErrorState(
            message: widget.ctrl.errorMessage.value,
            onRetry: widget.ctrl.fetchMyAppointments,
          );
        }
        return TabBarView(
          controller: _tab,
          children: [
            _AppointmentList(
              list: widget.ctrl.upcomingAppointments,
              emptyMsg: 'No upcoming appointments',
              ctrl: widget.ctrl,
            ),
            _AppointmentList(
              list: widget.ctrl.pastAppointments,
              emptyMsg: 'No past appointments',
              ctrl: widget.ctrl,
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
        margin: const EdgeInsets.only(bottom: 14),
        height: 130,
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const _Shimmer(
              width: 52,
              height: 52,
              radius: 26,
              margin: EdgeInsets.all(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Shimmer(width: 140, height: 14, radius: 6),
                const SizedBox(height: 8),
                _Shimmer(width: 100, height: 11, radius: 4),
                const SizedBox(height: 12),
                _Shimmer(width: 180, height: 34, radius: 10),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ]),
      ),
    );
  }
}

// ── Tab list ──────────────────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> list;
  final String emptyMsg;
  final AppointmentController ctrl;
  const _AppointmentList(
      {required this.list,
      required this.emptyMsg,
      required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return _EmptyState(message: emptyMsg);
    return RefreshIndicator(
      color: kPrimary,
      onRefresh: ctrl.fetchMyAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: list.length,
        itemBuilder: (_, i) => _AppointmentCard(
          appointment: list[i],
          ctrl: ctrl,
        ),
      ),
    );
  }
}

// ── Appointment card ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentController ctrl;
  const _AppointmentCard(
      {required this.appointment, required this.ctrl});

  // All colors from colors_coning.dart
  static const _statusColors = <String, Color>{
    'PENDING':     kWarning,
    'CONFIRMED':   kPrimary,
    'IN_PROGRESS': kTeal,
    'COMPLETED':   kSuccess,
    'CANCELLED':   kError,
    'NO_SHOW':     kTextMedium,
  };

  static const _typeIcons = <String, IconData>{
    'HOME_VISIT': Icons.home_outlined,
    'ONLINE':     Icons.video_call_outlined,
    'QUICK':      Icons.bolt_outlined,
    'SCHEDULED':  Icons.schedule,
    'EMERGENCY':  Icons.emergency_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _statusColors[appointment.status] ?? kTextMedium;
    final typeIcon =
        _typeIcons[appointment.type] ?? Icons.medical_services_outlined;
    final isUpcoming = appointment.isUpcoming;

    DateTime? dt;
    try {
      dt = DateTime.parse(appointment.scheduledAt).toLocal();
    } catch (_) {}
    final dateStr = dt != null
        ? '${dt.day} ${_month(dt.month)} ${dt.year}'
        : appointment.scheduledAt.length > 10
            ? appointment.scheduledAt.substring(0, 10)
            : appointment.scheduledAt;
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0, 16 * (1 - v)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
                color: kTextDark.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: kPrimaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withValues(alpha: 0.25),
                        blurRadius: 6)
                  ],
                ),
                child: appointment.doctorImage?.isNotEmpty == true
                    ? ClipOval(
                        child: Image.network(
                          appointment.doctorImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person_rounded,
                                  color: kSurface, size: 26),
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: kSurface, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName ?? 'Doctor',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kTextDark)),
                    if ((appointment.doctorSpecialty ?? '').isNotEmpty)
                      Text(appointment.doctorSpecialty!,
                          style: const TextStyle(
                              fontSize: 12, color: kTextMedium)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  appointment.status.replaceAll('_', ' '),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ),
            ]),
          ),

          // Info strip
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: kTextLight),
              const SizedBox(width: 5),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 12, color: kTextMedium)),
              if (timeStr.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.access_time_rounded,
                    size: 13, color: kTextLight),
                const SizedBox(width: 5),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 12, color: kTextMedium)),
              ],
              const Spacer(),
              Icon(typeIcon, size: 13, color: kTextLight),
              const SizedBox(width: 4),
              Text(appointment.type.replaceAll('_', ' '),
                  style: const TextStyle(
                      fontSize: 10, color: kTextLight)),
            ]),
          ),

          if (appointment.fee > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(children: [
                const Icon(Icons.currency_rupee_rounded,
                    size: 14, color: kSuccess),
                Text(appointment.fee.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 13,
                        color: kSuccess,
                        fontWeight: FontWeight.w700)),
              ]),
            ),

          // Action buttons
          if (isUpcoming)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kError,
                      side: BorderSide(
                          color: kError.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmCancel(context),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kSurface,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showDetails(context),
                    child: const Text('Details',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment',
            style: TextStyle(color: kTextDark)),
        content: const Text(
            'Are you sure you want to cancel this appointment?',
            style: TextStyle(color: kTextMedium)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No',
                  style: TextStyle(color: kTextMedium))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kError,
                foregroundColor: kSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
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
      builder: (_) =>
          _AppointmentDetailSheet(appointment: appointment),
    );
  }

  String _month(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ── Detail sheet ──────────────────────────────────────────────────────────────

class _AppointmentDetailSheet extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentDetailSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 18),
        const Text('Appointment Details',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kTextDark)),
        const SizedBox(height: 14),
        const Divider(color: kDivider),
        const SizedBox(height: 10),
        _DetailRow(Icons.person_outline_rounded, 'Doctor',
            appointment.doctorName ?? '—'),
        if ((appointment.doctorSpecialty ?? '').isNotEmpty)
          _DetailRow(Icons.medical_services_outlined, 'Specialty',
              appointment.doctorSpecialty!),
        _DetailRow(
            Icons.calendar_today_rounded,
            'Scheduled',
            appointment.scheduledAt.length > 10
                ? appointment.scheduledAt
                    .substring(0, 16)
                    .replaceAll('T', ' ')
                : appointment.scheduledAt),
        _DetailRow(Icons.category_outlined, 'Type',
            appointment.type.replaceAll('_', ' ')),
        _DetailRow(Icons.info_outline_rounded, 'Status',
            appointment.status.replaceAll('_', ' ')),
        if (appointment.fee > 0)
          _DetailRow(Icons.currency_rupee_rounded, 'Fee',
              '₹${appointment.fee.toStringAsFixed(0)}'),
        if ((appointment.address ?? '').isNotEmpty)
          _DetailRow(Icons.location_on_outlined, 'Address',
              appointment.address!),
        if ((appointment.notes ?? '').isNotEmpty)
          _DetailRow(Icons.notes_rounded, 'Notes', appointment.notes!),
        if ((appointment.meetingLink ?? '').isNotEmpty)
          _DetailRow(Icons.video_call_outlined, 'Meeting',
              appointment.meetingLink!),
        const SizedBox(height: 16),
      ]),
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: kPrimary),
        const SizedBox(width: 10),
        SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: kTextMedium))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextDark))),
      ]),
    );
  }
}

// ── Empty / Error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

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
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_outlined,
                size: 44, color: kPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text('Your appointments will appear here.',
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

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  const _Shimmer(
      {this.width,
      required this.height,
      this.radius = 8,
      this.margin});

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
        margin: widget.margin,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
