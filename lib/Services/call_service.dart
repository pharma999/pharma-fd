import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/utils/token_storage.dart';

// ── CallService ───────────────────────────────────────────────────────────────
// Manages the WebRTC peer connection and WS signaling channel for a single call.
// One instance lives for the duration of one call; dispose() on hang-up.

class CallService {
  // STUN servers — free public servers, no API key needed.
  // For production behind symmetric NAT, add a TURN server here.
  static const _iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun.cloudflare.com:3478'},
  ];

  final String callId;
  final String remoteUserId;  // the user we're calling / who called us
  final bool isCaller;        // true = we initiated the call

  RTCPeerConnection? _pc;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final remoteRenderer = RTCVideoRenderer();
  final localRenderer  = RTCVideoRenderer();

  WebSocket? _ws;
  bool _disposed = false;

  // Notifiers consumed by VideoCallPage
  final ValueNotifier<bool> micEnabled    = ValueNotifier(true);
  final ValueNotifier<bool> cameraEnabled = ValueNotifier(true);
  final ValueNotifier<bool> connected     = ValueNotifier(false);

  // Fired when remote hang-up arrives via WS
  VoidCallback? onRemoteEnd;

  CallService({
    required this.callId,
    required this.remoteUserId,
    required this.isCaller,
  });

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    await remoteRenderer.initialize();
    await localRenderer.initialize();
    await _openSignalingWS();
    await _openCamera();
    await _createPeerConnection();
    if (isCaller) {
      await _sendOffer();
    }
  }

  // ── WebSocket signaling channel ─────────────────────────────────────────────

  Future<void> _openSignalingWS() async {
    final token = await TokenStorage.getToken() ?? '';
    final wsBase = ApiConfig.baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://')
        .replaceAll('/api', '');
    final uri = '$wsBase/api/ws?token=${Uri.encodeComponent(token)}';

    try {
      _ws = await WebSocket.connect(uri).timeout(const Duration(seconds: 10));
      _ws!.listen(_onWsMessage, onError: (_) {}, onDone: () {});
    } catch (e) {
      debugPrint('[CallService] WS connect failed: $e');
    }
  }

  void _sendSignal(String signalType, Map<String, dynamic> data) {
    if (_ws == null || _disposed) return;
    _ws!.add(jsonEncode({
      'type': 'call_signal',
      'to': remoteUserId,
      'call_id': callId,
      'signal_type': signalType,
      'data': data,
    }));
  }

  void _onWsMessage(dynamic raw) {
    if (_disposed) return;
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String? ?? '';
      if (type != 'call_signal') return;

      final p = msg['payload'] is String
          ? jsonDecode(msg['payload'] as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(msg['payload'] as Map);

      final signalType = p['signal_type'] as String? ?? '';
      final data       = p['data'] as Map<String, dynamic>? ?? {};

      switch (signalType) {
        case 'offer':
          _handleRemoteOffer(data);
        case 'answer':
          _handleRemoteAnswer(data);
        case 'ice_candidate':
          _handleRemoteIce(data);
      }

      // Remote hung up via WS
      if (type == 'call_ended') {
        onRemoteEnd?.call();
      }
    } catch (_) {}
  }

  // ── Media ──────────────────────────────────────────────────────────────────

  Future<void> _openCamera() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
      },
    });
    localRenderer.srcObject = localStream;
  }

  // ── Peer connection ────────────────────────────────────────────────────────

  Future<void> _createPeerConnection() async {
    _pc = await createPeerConnection({
      'iceServers': _iceServers,
      'sdpSemantics': 'unified-plan',
    });

    // Add local tracks to peer connection
    localStream?.getTracks().forEach((track) {
      _pc!.addTrack(track, localStream!);
    });

    // Receive remote stream
    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        remoteRenderer.srcObject = remoteStream;
        connected.value = true;
      }
    };

    // Send ICE candidates to remote peer
    _pc!.onIceCandidate = (candidate) {
      _sendSignal('ice_candidate', candidate.toMap());
    };

    _pc!.onConnectionState = (state) {
      debugPrint('[CallService] PC state: $state');
    };
  }

  Future<void> _sendOffer() async {
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    _sendSignal('offer', {'sdp': offer.sdp, 'type': offer.type});
  }

  Future<void> _handleRemoteOffer(Map<String, dynamic> data) async {
    await _pc?.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type']),
    );
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    _sendSignal('answer', {'sdp': answer.sdp, 'type': answer.type});
    connected.value = true;
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> data) async {
    await _pc?.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type']),
    );
    connected.value = true;
  }

  Future<void> _handleRemoteIce(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );
    await _pc?.addCandidate(candidate);
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  void toggleMic() {
    final enabled = !micEnabled.value;
    localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
    micEnabled.value = enabled;
  }

  void toggleCamera() {
    final enabled = !cameraEnabled.value;
    localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);
    cameraEnabled.value = enabled;
  }

  Future<void> switchCamera() async {
    final videoTracks = localStream?.getVideoTracks();
    if (videoTracks != null && videoTracks.isNotEmpty) {
      await Helper.switchCamera(videoTracks.first);
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    _disposed = true;
    await localStream?.dispose();
    await remoteStream?.dispose();
    await _pc?.close();
    await _ws?.close();
    localRenderer.dispose();
    remoteRenderer.dispose();
    micEnabled.dispose();
    cameraEnabled.dispose();
    connected.dispose();
  }
}
