import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Services/peer_chat_repository.dart';
import 'package:home_care/Pages/Chat/chat_list_page.dart';
import 'package:home_care/Pages/Chat/chat_room_page.dart';

/// Opens (or creates) the booking-specific chat conversation and navigates
/// directly into the chat room.
///
/// No dialog is shown — the ChatRoomPage itself shows a skeleton loader
/// while it fetches message history, so the UX is seamless.
///
/// Usage: `openBookingChat(booking.id);`
Future<void> openBookingChat(String bookingId) async {
  if (bookingId.isEmpty) {
    Get.to(() => const ChatListPage());
    return;
  }

  try {
    final result =
        await PeerChatRepository().getOrCreateConversation(bookingId);
    result.when(
      onSuccess: (conv) => Get.to(() => ChatRoomPage(conversation: conv)),
      onError: (err) {
        Get.snackbar(
          'Chat Unavailable',
          'Could not open chat. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        );
      },
    );
  } catch (e) {
    Get.snackbar(
      'Connection Error',
      'Could not connect to server. Please check your connection.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
