import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Pages/Call/video_call_page.dart';

// ── IncomingCallPage ──────────────────────────────────────────────────────────
// Full-screen alert shown when a call_invite WS event arrives.
// Opened via Get.to() from BookingController._onWsMessage().

class IncomingCallPage extends StatefulWidget {
  final String callId;
  final String callerId;
  final String callerName;
  final String bookingId;
  final String remoteUserId; // same as callerId for callee

  const IncomingCallPage({
    super.key,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.bookingId,
    required this.remoteUserId,
  });

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  Timer? _autoRejectTimer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Auto-reject after 45 s (missed call)
    _autoRejectTimer = Timer(const Duration(seconds: 45), () {
      if (mounted) _reject();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _autoRejectTimer?.cancel();
    super.dispose();
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    _autoRejectTimer?.cancel();

    try {
      await ApiClient().post(
        'calls/${widget.callId}/accept',
        {},
        requiresAuth: true,
      );
      if (!mounted) return;
      Get.off(() => VideoCallPage(
            callId:       widget.callId,
            remoteUserId: widget.remoteUserId,
            remoteName:   widget.callerName,
            bookingId:    widget.bookingId,
            isCaller:     false,
          ));
    } catch (e) {
      setState(() => _busy = false);
      Get.snackbar('Error', 'Could not accept call');
    }
  }

  Future<void> _reject() async {
    if (_busy) return;
    setState(() => _busy = true);
    _autoRejectTimer?.cancel();

    try {
      await ApiClient().post(
        'calls/${widget.callId}/reject',
        {},
        requiresAuth: true,
      );
    } catch (_) {}
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── Caller avatar ──────────────────────────────────────────────
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kPrimary, kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5)
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.callerName.isNotEmpty
                        ? widget.callerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Caller name ────────────────────────────────────────────────
            Text(widget.callerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Incoming Video Call',
                style: TextStyle(color: Colors.white60, fontSize: 14)),

            const Spacer(flex: 3),

            // ── Action buttons ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reject
                  _CallButton(
                    icon: Icons.call_end_rounded,
                    color: Colors.red,
                    label: 'Decline',
                    onTap: _busy ? null : _reject,
                  ),
                  // Accept
                  _CallButton(
                    icon: Icons.videocam_rounded,
                    color: Colors.green,
                    label: 'Accept',
                    onTap: _busy ? null : _accept,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 16, spreadRadius: 2)
              ]),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ]),
    );
  }
}
