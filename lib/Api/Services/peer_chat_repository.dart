import 'dart:io';

import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A single message in a peer conversation.
class PeerMsg {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType; // "text" | "image" | "file" | "pdf"
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final bool isRead;
  final DateTime createdAt;

  PeerMsg({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl = '',
    this.fileName = '',
    this.fileSize = '',
    required this.isRead,
    required this.createdAt,
  });

  bool get isImage => messageType == 'image';
  bool get isFile  => messageType == 'file' || messageType == 'pdf';

  factory PeerMsg.fromJson(Map<String, dynamic> j) => PeerMsg(
        id: j['message_id'] ?? '',
        conversationId: j['conversation_id'] ?? '',
        senderId: j['sender_id'] ?? '',
        content: j['content'] ?? '',
        messageType: j['message_type'] ?? 'text',
        fileUrl: j['file_url'] ?? '',
        fileName: j['file_name'] ?? '',
        fileSize: j['file_size'] ?? '',
        isRead: j['is_read'] ?? false,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// A conversation thread between patient and provider.
class Conversation {
  final String id;
  final String bookingId;
  final String patientUserId;
  final String nurseUserId;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadPatient;
  final int unreadNurse;
  final String otherPartyName;
  final String otherPartyId;

  Conversation({
    required this.id,
    required this.bookingId,
    required this.patientUserId,
    required this.nurseUserId,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadPatient,
    required this.unreadNurse,
    required this.otherPartyName,
    required this.otherPartyId,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['conversation_id'] ?? '',
        bookingId: j['booking_id'] ?? '',
        patientUserId: j['patient_user_id'] ?? '',
        nurseUserId: j['nurse_user_id'] ?? '',
        lastMessage: j['last_message'] ?? '',
        lastMessageAt: j['last_message_at'] != null
            ? DateTime.tryParse(j['last_message_at'])
            : null,
        unreadPatient: (j['unread_patient'] ?? 0) as int,
        unreadNurse: (j['unread_nurse'] ?? 0) as int,
        otherPartyName: j['other_party_name'] ?? 'Provider',
        otherPartyId: j['other_party_id'] ?? '',
      );
}

class PeerChatRepository {
  final _client = ApiClient();

  /// Opens or retrieves the conversation for a booking.
  Future<ApiResult<Conversation>> getOrCreateConversation(
      String bookingId) async {
    try {
      final res = await _client.post(
          'chat/booking/$bookingId', {}, requiresAuth: true);
      final d = res['data'] as Map<String, dynamic>? ?? {};
      return Success(Conversation.fromJson(d));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Lists all conversations for the logged-in user.
  Future<ApiResult<List<Conversation>>> getMyConversations() async {
    try {
      final res =
          await _client.get('chat/conversations', requiresAuth: true);
      final list = res['data'] as List<dynamic>? ?? [];
      return Success(list
          .whereType<Map>()
          .map((m) => Conversation.fromJson(Map<String, dynamic>.from(m)))
          .toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Fetches message history for a conversation (last 100).
  Future<ApiResult<List<PeerMsg>>> getMessages(String convId) async {
    try {
      final res = await _client.get(
          'chat/conversations/$convId/messages',
          requiresAuth: true);
      final list = res['data'] as List<dynamic>? ?? [];
      return Success(list
          .whereType<Map>()
          .map((m) => PeerMsg.fromJson(Map<String, dynamic>.from(m)))
          .toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Sends a text message. Returns the saved message on success.
  Future<ApiResult<PeerMsg>> sendMessage({
    required String convId,
    required String content,
    String messageType = 'text',
    String fileUrl = '',
    String fileName = '',
    String fileSize = '',
  }) async {
    try {
      final body = <String, dynamic>{
        'content': content,
        'message_type': messageType,
        if (fileUrl.isNotEmpty) 'file_url': fileUrl,
        if (fileName.isNotEmpty) 'file_name': fileName,
        if (fileSize.isNotEmpty) 'file_size': fileSize,
      };
      final res = await _client.post(
        'chat/conversations/$convId/messages',
        body,
        requiresAuth: true,
      );
      final d = res['data'] as Map<String, dynamic>? ?? {};
      return Success(PeerMsg.fromJson(d));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Uploads a file (image, pdf, doc, txt) to the chat media storage.
  /// Returns metadata: file_url, file_name, file_size, message_type.
  Future<ApiResult<Map<String, dynamic>>> uploadFile(File file) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Error('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/chat/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send()
          .timeout(const Duration(seconds: 60));
      final body = await streamed.stream.bytesToString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final data = json['data'] as Map<String, dynamic>? ?? json;
        return Success(data);
      }
      final msg = json['message'] as String? ?? 'Upload failed';
      return Error(msg);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Marks all incoming messages in the conversation as read.
  Future<void> markRead(String convId) async {
    try {
      await _client.patch(
          'chat/conversations/$convId/read', {},);
    } catch (_) {}
  }
}
