import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/utils/token_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real-time message types from the backend WebSocket hub.
enum WsMessageType {
  emergencyTriggered,
  emergencyStatus,
  ambulanceLocation,
  newNotification,
  ping,
  unknown,
}

class WsMessage {
  final WsMessageType type;
  final String room;
  final Map<String, dynamic> payload;

  const WsMessage({
    required this.type,
    required this.room,
    required this.payload,
  });

  factory WsMessage.fromJson(Map<String, dynamic> j) {
    final typeStr = j['type'] as String? ?? '';
    final type = switch (typeStr) {
      'emergency_triggered' => WsMessageType.emergencyTriggered,
      'emergency_status' => WsMessageType.emergencyStatus,
      'ambulance_location' => WsMessageType.ambulanceLocation,
      'notification' => WsMessageType.newNotification,
      'ping' => WsMessageType.ping,
      _ => WsMessageType.unknown,
    };
    return WsMessage(
      type: type,
      room: j['room'] as String? ?? '',
      payload: (j['payload'] is Map)
          ? Map<String, dynamic>.from(j['payload'] as Map)
          : {},
    );
  }
}

/// WebSocketService manages a single persistent connection to the backend.
///
/// Usage:
///   final svc = WebSocketService.instance;
///   await svc.connect(rooms: ['emergency:abc123']);
///   svc.messages.listen((msg) { ... });
///   svc.subscribe('emergency:xyz');
class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  final _controller = StreamController<WsMessage>.broadcast();
  bool _connected = false;

  Stream<WsMessage> get messages => _controller.stream;
  bool get isConnected => _connected;

  /// Connect to the backend WebSocket endpoint.
  Future<void> connect({List<String> rooms = const []}) async {
    if (_connected) return;

    final token = await TokenStorage.getToken();
    if (token == null) {
      debugPrint('[WS] no token — cannot connect');
      return;
    }

    // Convert http:// → ws:// or https:// → wss://
    final wsBase = ApiConfig.baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');

    final roomsParam = rooms.isNotEmpty ? '&rooms=${rooms.join(',')}' : '';
    final uri = Uri.parse('$wsBase/ws?token=$token$roomsParam');

    try {
      _channel = WebSocketChannel.connect(uri);
      _connected = true;
      debugPrint('[WS] connected to $uri');

      _channel!.stream.listen(
        (raw) {
          try {
            final json = jsonDecode(raw as String) as Map<String, dynamic>;
            _controller.add(WsMessage.fromJson(json));
          } catch (e) {
            debugPrint('[WS] parse error: $e');
          }
        },
        onDone: () {
          _connected = false;
          debugPrint('[WS] disconnected');
        },
        onError: (e) {
          _connected = false;
          debugPrint('[WS] error: $e');
        },
      );
    } catch (e) {
      _connected = false;
      debugPrint('[WS] connect failed: $e');
    }
  }

  /// Subscribe to a room after connection.
  void subscribe(String room) {
    if (!_connected) return;
    _channel?.sink.add(jsonEncode({'type': 'subscribe', 'room': room}));
  }

  /// Disconnect the WebSocket.
  void disconnect() {
    _channel?.sink.close();
    _connected = false;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
