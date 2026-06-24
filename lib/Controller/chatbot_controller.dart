import 'package:get/get.dart';
import 'package:home_care/Api/Services/chatbot_repository.dart';
import 'package:home_care/Helper/logger_service.dart';

/// Chat message as displayed in the UI.
class ChatMessageUI {
  final String id;
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final bool isError;

  ChatMessageUI({
    String? id,
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.isError = false,
  }) : id = id ?? '${DateTime.now().microsecondsSinceEpoch}';
}

/// Drives the chatbot screen — talks to [ChatbotRepository] for all API calls.
class ChatbotController extends GetxController {
  final ChatbotRepository _repo = ChatbotRepository();

  final messages   = <ChatMessageUI>[].obs;
  final isSending  = false.obs;
  final isLoadingHistory = true.obs;
  final sessionId  = ''.obs;

  // Quick-reply suggestions shown below the last bot message
  final suggestions = <String>[
    'What services do you offer?',
    'Book a nurse visit',
    'Check my appointments',
    'Cancel booking',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _addBotMessage(
      'Hello! 👋 I\'m your Healthcare Assistant. '
      'Ask me about services, bookings or appointments.',
    );
    _loadHistory();
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    isLoadingHistory.value = true;
    try {
      final result = await _repo.getHistory(
          sessionId: sessionId.value.isEmpty ? null : sessionId.value);
      result.when(
        onSuccess: (msgs) {
          if (msgs.isEmpty) return;
          // Replace the greeting with real history if available
          messages.clear();
          for (final m in msgs) {
            messages.add(ChatMessageUI(
              id: m.messageId,
              text: m.content,
              isBot: m.role == 'bot',
              timestamp: m.createdAt,
            ));
          }
        },
        onError: (e) => LoggerService.warning('Chat history load failed: $e'),
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSending.value) return;

    // Optimistic user bubble
    messages.add(ChatMessageUI(
      text: trimmed,
      isBot: false,
      timestamp: DateTime.now(),
    ));
    suggestions.clear(); // hide suggestions after user types

    isSending.value = true;
    try {
      final result = await _repo.sendMessage(
        message: trimmed,
        sessionId: sessionId.value.isEmpty ? null : sessionId.value,
      );
      result.when(
        onSuccess: (data) {
          // Persist the session ID returned by the backend
          final sid = data['session_id'] as String? ?? '';
          if (sid.isNotEmpty) sessionId.value = sid;

          final reply = data['reply'] as String? ?? '...';
          _addBotMessage(reply);
        },
        onError: (e) {
          _addBotMessage(
            '⚠️ Sorry, I couldn\'t process that. Please try again.',
            isError: true,
          );
          LoggerService.error('Chat send failed', e);
        },
      );
    } finally {
      isSending.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _addBotMessage(String text, {bool isError = false}) {
    messages.add(ChatMessageUI(
      text: text,
      isBot: true,
      timestamp: DateTime.now(),
      isError: isError,
    ));
  }

  void useSuggestion(String suggestion) => sendMessage(suggestion);
}
