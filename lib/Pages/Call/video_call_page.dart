import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Services/call_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// ── VideoCallPage ─────────────────────────────────────────────────────────────
// In-call screen: local PiP + full-screen remote video, controls overlay.

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String remoteUserId;
  final String remoteName;
  final String bookingId;
  final bool isCaller;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.remoteUserId,
    required this.remoteName,
    required this.bookingId,
    required this.isCaller,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late CallService _call;
  final _duration = ValueNotifier<int>(0); // seconds elapsed
  Timer? _timer;
  bool _controlsVisible = true;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _call = CallService(
      callId: widget.callId,
      remoteUserId: widget.remoteUserId,
      isCaller: widget.isCaller,
    );
    _call.onRemoteEnd = _onRemoteHangUp;
    _call.init().then((_) {
      _startTimer();
      if (mounted) setState(() {});
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => _duration.value++);
  }

  void _onRemoteHangUp() {
    if (mounted && !_ending) _hangUp(remoteEnded: true);
  }

  Future<void> _hangUp({bool remoteEnded = false}) async {
    if (_ending) return;
    _ending = true;
    _timer?.cancel();
    WakelockPlus.disable();
    if (!remoteEnded) {
      try {
        await ApiClient()
            .post('calls/${widget.callId}/end', {}, requiresAuth: true);
      } catch (_) {}
    }
    await _call.dispose();
    if (mounted) Get.back();
  }

  String _formatDuration(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _duration.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(
            () => _controlsVisible = !_controlsVisible),
        child: Stack(fit: StackFit.expand, children: [
          // ── Remote video (full screen) ────────────────────────────────────
          RTCVideoView(
            _call.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),

          // ── Connection waiting overlay ────────────────────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: _call.connected,
            builder: (_, connected, __) => connected
                ? const SizedBox.shrink()
                : Container(
                    color: const Color(0xCC0A1628),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 20),
                        Text('Connecting to ${widget.remoteName}…',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
          ),

          // ── Local PiP (picture-in-picture, top-right) ─────────────────────
          Positioned(
            top: 52,
            right: 16,
            child: Container(
              width: 100, height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: RTCVideoView(
                  _call.localRenderer,
                  mirror: true,
                  objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // ── Top bar: name + timer ─────────────────────────────────────────
          AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20, right: 20, bottom: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.remoteName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        ValueListenableBuilder<int>(
                          valueListenable: _duration,
                          builder: (_, secs, __) => Text(
                            _formatDuration(secs),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // ── Bottom controls ───────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mic toggle
                    ValueListenableBuilder<bool>(
                      valueListenable: _call.micEnabled,
                      builder: (_, on, __) => _ControlBtn(
                        icon: on
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        label: on ? 'Mute' : 'Unmute',
                        active: on,
                        onTap: _call.toggleMic,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // End call
                    _ControlBtn(
                      icon: Icons.call_end_rounded,
                      label: 'End',
                      active: true,
                      activeColor: Colors.red,
                      size: 62,
                      onTap: () => _hangUp(),
                    ),
                    const SizedBox(width: 16),

                    // Camera toggle
                    ValueListenableBuilder<bool>(
                      valueListenable: _call.cameraEnabled,
                      builder: (_, on, __) => _ControlBtn(
                        icon: on
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        label: on ? 'Cam off' : 'Cam on',
                        active: on,
                        onTap: _call.toggleCamera,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Flip camera
                    _ControlBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      label: 'Flip',
                      active: true,
                      onTap: _call.switchCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Control button ────────────────────────────────────────────────────────────

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? activeColor;
  final double size;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bg = activeColor ??
        (active ? kPrimary.withValues(alpha: 0.85) : Colors.white24);
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: size * 0.45),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ]),
    );
  }
}
