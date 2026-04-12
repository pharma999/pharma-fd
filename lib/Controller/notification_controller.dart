import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Services/emergency_repository.dart';
import 'package:home_care/Api/Services/websocket_service.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/emergency_model.dart';

class NotificationController extends GetxController {
  final EmergencyRepository _repo = EmergencyRepository();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _listenWebSocket();
  }

  void _listenWebSocket() {
    WebSocketService.instance.messages.listen((msg) {
      if (msg.type == WsMessageType.newNotification) {
        final notif = NotificationModel.fromJson(msg.payload);
        notifications.insert(0, notif);
        Get.snackbar(
          notif.title,
          notif.message,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: _typeIcon(notif.type),
        );
        LoggerService.info('New notification: ${notif.title}');
      }
    });
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _repo.getNotifications();
      result.when(
        onSuccess: (data) => notifications.value = data,
        onError: (err) => error.value = err,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(String id) async {
    final result = await _repo.markNotificationRead(id);
    result.when(
      onSuccess: (_) {
        final idx = notifications.indexWhere((n) => n.id == id);
        if (idx >= 0) {
          final old = notifications[idx];
          notifications[idx] = NotificationModel(
            id: old.id,
            userId: old.userId,
            title: old.title,
            message: old.message,
            type: old.type,
            isRead: true,
            referenceId: old.referenceId,
            createdAt: old.createdAt,
          );
        }
      },
      onError: (_) {},
    );
  }

  Future<void> markAllRead() async {
    final result = await _repo.markAllNotificationsRead();
    result.when(
      onSuccess: (_) => fetchNotifications(),
      onError: (_) {},
    );
  }

  Widget _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return const Icon(Icons.emergency, color: Colors.red);
      case 'BOOKING':
        return const Icon(Icons.calendar_today, color: Colors.blue);
      case 'APPOINTMENT':
        return const Icon(Icons.medical_services, color: Colors.teal);
      case 'PAYMENT':
        return const Icon(Icons.payment, color: Colors.green);
      default:
        return const Icon(Icons.notifications, color: Colors.orange);
    }
  }
}
