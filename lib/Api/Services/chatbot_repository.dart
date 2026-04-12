import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';

class ChatMessage {
  final String messageId;
  final String sessionId;
  final String role; // "user" | "bot"
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.messageId,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        messageId: j['message_id'] ?? '',
        sessionId: j['session_id'] ?? '',
        role: j['role'] ?? 'bot',
        content: j['content'] ?? '',
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class ChatbotRepository {
  final ApiClient _client = ApiClient();

  /// Send a message and receive the bot's reply.
  Future<ApiResult<Map<String, dynamic>>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final body = <String, dynamic>{'message': message};
      if (sessionId != null) body['session_id'] = sessionId;

      final response = await _client.post(
        ApiEndpoints.chatbotMessage,
        body,
        requiresAuth: true,
      );
      return Success(response['data'] as Map<String, dynamic>);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Fetch conversation history for the current user.
  Future<ApiResult<List<ChatMessage>>> getHistory({String? sessionId}) async {
    try {
      final params = <String, String>{};
      if (sessionId != null) params['session_id'] = sessionId;

      final response = await _client.get(
        ApiEndpoints.chatbotHistory,
        requiresAuth: true,
        queryParams: params,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => ChatMessage.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
