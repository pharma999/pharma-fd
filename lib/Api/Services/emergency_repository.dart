import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/emergency_model.dart';

class EmergencyRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<EmergencyModel>> triggerSOS({
    required String symptomDescription,
    required String patientAddress,
    double? latitude,
    double? longitude,
    String? emergencyType,
    String? familyMemberId,
    String priority = 'HIGH',
  }) async {
    try {
      LoggerService.info('Triggering SOS emergency');
      final body = <String, dynamic>{
        'symptom_description': symptomDescription,
        'patient_address': patientAddress,
        'emergency_type': emergencyType ?? 'GENERAL',
      };
      if (latitude != null) body['patient_latitude'] = latitude.toString();
      if (longitude != null) body['patient_longitude'] = longitude.toString();
      if (familyMemberId != null) body['family_member_id'] = familyMemberId;

      final response = await _client.post(
        ApiEndpoints.triggerSOS,
        body,
        requiresAuth: true,
      );
      return Success(EmergencyModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<EmergencyModel>>> getMyEmergencies() async {
    try {
      final response = await _client.get(
        ApiEndpoints.myEmergencies,
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => EmergencyModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<EmergencyModel>> getEmergencyDetail(
      String emergencyId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.emergencyDetail(emergencyId),
        requiresAuth: true,
      );
      return Success(EmergencyModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<MedicalRecord>>> getMedicalRecords({
    String? familyMemberId,
  }) async {
    try {
      final endpoint = familyMemberId != null
          ? ApiEndpoints.familyMedicalRecords(familyMemberId)
          : ApiEndpoints.medicalRecords;

      final response = await _client.get(endpoint, requiresAuth: true);
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => MedicalRecord.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<MedicalRecord>> uploadMedicalRecord({
    required String recordType,
    required String title,
    required String recordDate,
    String? description,
    String? fileUrl,
    String? doctorName,
    String? hospitalName,
  }) async {
    try {
      final body = <String, dynamic>{
        'record_type': recordType,
        'title': title,
        'record_date': recordDate,
      };
      if (description != null) body['description'] = description;
      if (fileUrl != null) body['file_url'] = fileUrl;
      if (doctorName != null) body['doctor_name'] = doctorName;
      if (hospitalName != null) body['hospital_name'] = hospitalName;

      final response = await _client.post(
        ApiEndpoints.uploadMedicalRecord,
        body,
        requiresAuth: true,
      );
      return Success(MedicalRecord.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> deleteMedicalRecord(String recordId) async {
    try {
      LoggerService.info('Deleting medical record: $recordId');
      await _client.delete(
        ApiEndpoints.deleteMedicalRecord(recordId),
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _client.get(
        ApiEndpoints.notifications,
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(
          data.map((e) => NotificationModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> markNotificationRead(String notificationId) async {
    try {
      // Backend: PATCH /notifications/:notifId/read
      await _client.patch(
        ApiEndpoints.markNotificationRead(notificationId),
        {},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> markAllNotificationsRead() async {
    try {
      // Backend: PATCH /notifications/read-all
      await _client.patch(
        ApiEndpoints.markAllNotificationsRead,
        {},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
