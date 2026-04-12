import 'package:get/get.dart';
import 'package:home_care/Api/Services/emergency_repository.dart';
import 'package:home_care/Api/Services/websocket_service.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/emergency_model.dart';

/// Manages SOS, medical records, notifications and real-time ambulance tracking.
class EmergencyController extends GetxController {
  final EmergencyRepository _repo = EmergencyRepository();

  RxList<EmergencyModel> emergencies = <EmergencyModel>[].obs;
  RxList<MedicalRecord> medicalRecords = <MedicalRecord>[].obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  Rx<EmergencyModel?> activeEmergency = Rx<EmergencyModel?>(null);

  // Real-time ambulance location
  RxDouble ambulanceLat = 0.0.obs;
  RxDouble ambulanceLng = 0.0.obs;
  RxBool hasAmbulanceLocation = false.obs;

  RxBool isTriggeringSOS = false.obs;
  RxBool isLoadingRecords = false.obs;
  RxBool isLoadingNotifications = false.obs;
  RxString errorMessage = ''.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _listenWebSocket();
  }

  /// Subscribe to WebSocket messages relevant to emergencies.
  void _listenWebSocket() {
    WebSocketService.instance.messages.listen((msg) {
      switch (msg.type) {
        case WsMessageType.emergencyStatus:
          _handleStatusUpdate(msg.payload);
        case WsMessageType.ambulanceLocation:
          _handleAmbulanceLocation(msg.payload);
        default:
          break;
      }
    });
  }

  void _handleStatusUpdate(Map<String, dynamic> payload) {
    final id = payload['emergency_id'] as String?;
    if (id == null) return;
    final idx = emergencies.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      // Refresh from server to get full updated state
      _repo.getEmergencyDetail(id).then((result) {
        result.when(
          onSuccess: (updated) {
            emergencies[idx] = updated;
            if (activeEmergency.value?.id == id) {
              activeEmergency.value = updated;
            }
          },
          onError: (_) {},
        );
      });
    }
  }

  void _handleAmbulanceLocation(Map<String, dynamic> payload) {
    final lat = double.tryParse(payload['latitude']?.toString() ?? '');
    final lng = double.tryParse(payload['longitude']?.toString() ?? '');
    if (lat != null && lng != null) {
      ambulanceLat.value = lat;
      ambulanceLng.value = lng;
      hasAmbulanceLocation.value = true;
      LoggerService.info('Ambulance at $lat, $lng');
    }
  }

  /// Connect to WebSocket and subscribe to active emergency room.
  Future<void> connectToEmergencyRoom(String emergencyId) async {
    final ws = WebSocketService.instance;
    await ws.connect(rooms: ['emergency:$emergencyId']);
    ws.subscribe('emergency:$emergencyId');
    LoggerService.info('Subscribed to emergency:$emergencyId');
  }

  Future<bool> triggerSOS({
    required String symptomDescription,
    required String patientAddress,
    double? latitude,
    double? longitude,
    String? emergencyType,
    String? familyMemberId,
  }) async {
    try {
      isTriggeringSOS.value = true;
      LoggerService.info('Triggering SOS...');

      final result = await _repo.triggerSOS(
        symptomDescription: symptomDescription,
        patientAddress: patientAddress,
        latitude: latitude,
        longitude: longitude,
        emergencyType: emergencyType,
        familyMemberId: familyMemberId,
      );

      bool success = false;
      result.when(
        onSuccess: (emergency) {
          success = true;
          activeEmergency.value = emergency;
          emergencies.insert(0, emergency);
          // Subscribe to this emergency's WebSocket room for live updates
          connectToEmergencyRoom(emergency.id);
          LoggerService.success('SOS triggered: ${emergency.id}');
        },
        onError: (err) {
          errorMessage.value = err;
          Get.snackbar('SOS Failed', err);
          LoggerService.error('SOS trigger failed', err);
        },
      );
      return success;
    } finally {
      isTriggeringSOS.value = false;
    }
  }

  Future<void> fetchMyEmergencies() async {
    final result = await _repo.getMyEmergencies();
    result.when(
      onSuccess: (data) {
        emergencies.value = data;
        activeEmergency.value = data.where((e) => e.isActive).firstOrNull;
        // Subscribe to active emergency if any
        if (activeEmergency.value != null) {
          connectToEmergencyRoom(activeEmergency.value!.id);
        }
      },
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<void> fetchMedicalRecords({String? familyMemberId}) async {
    try {
      isLoadingRecords.value = true;
      final result =
          await _repo.getMedicalRecords(familyMemberId: familyMemberId);
      result.when(
        onSuccess: (data) => medicalRecords.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingRecords.value = false;
    }
  }

  Future<bool> uploadMedicalRecord({
    required String recordType,
    required String title,
    required String recordDate,
    String? description,
    String? fileUrl,
    String? doctorName,
    String? hospitalName,
  }) async {
    final result = await _repo.uploadMedicalRecord(
      recordType: recordType,
      title: title,
      recordDate: recordDate,
      description: description,
      fileUrl: fileUrl,
      doctorName: doctorName,
      hospitalName: hospitalName,
    );
    bool success = false;
    result.when(
      onSuccess: (record) {
        success = true;
        medicalRecords.insert(0, record);
        Get.snackbar('Uploaded', 'Medical record saved');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<bool> deleteMedicalRecord(String recordId) async {
    final result = await _repo.deleteMedicalRecord(recordId);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        medicalRecords.removeWhere((r) => r.id == recordId);
        Get.snackbar('Deleted', 'Medical record removed');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<void> fetchNotifications() async {
    try {
      isLoadingNotifications.value = true;
      final result = await _repo.getNotifications();
      result.when(
        onSuccess: (data) => notifications.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> markRead(String notificationId) async {
    final result = await _repo.markNotificationRead(notificationId);
    result.when(
      onSuccess: (_) {
        final idx = notifications.indexWhere((n) => n.id == notificationId);
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

  @override
  void onClose() {
    WebSocketService.instance.disconnect();
    super.onClose();
  }
}
