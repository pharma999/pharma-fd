import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/appointment_model.dart';
import 'package:home_care/Model/doctor_model.dart';

class AppointmentRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<List<DoctorModel>>> searchDoctors({
    String? specialty,
    String? consultationType,
    double? maxFee,
    String? language,
    double? rating,
  }) async {
    try {
      final params = <String, String>{};
      if (specialty != null) params['specialty'] = specialty;
      if (consultationType != null) {
        params['consultation_type'] = consultationType;
      }
      if (maxFee != null) params['max_fee'] = maxFee.toString();
      if (language != null) params['language'] = language;
      if (rating != null) params['rating'] = rating.toString();

      final response = await _client.get(
        ApiEndpoints.searchDoctors,
        requiresAuth: false,
        queryParams: params.isEmpty ? null : params,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => DoctorModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<DoctorModel>> getDoctorProfile(String doctorId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.doctorProfile(doctorId),
        requiresAuth: false,
      );
      return Success(DoctorModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<AppointmentModel>> createAppointment({
    required String doctorId,
    required String type,
    required String scheduledAt,
    String? familyMemberId,
    String? address,
    String? notes,
  }) async {
    try {
      LoggerService.info('Creating appointment with doctor: $doctorId');
      final body = <String, dynamic>{
        'doctor_id': doctorId,
        'type': type,
        'scheduled_at': scheduledAt,
      };
      if (familyMemberId != null) body['family_member_id'] = familyMemberId;
      if (address != null) body['address'] = address;
      if (notes != null) body['notes'] = notes;

      final response = await _client.post(
        ApiEndpoints.createAppointment,
        body,
        requiresAuth: true,
      );
      return Success(AppointmentModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<AppointmentModel>>> getMyAppointments({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) params['status'] = status;

      final response = await _client.get(
        ApiEndpoints.myAppointments,
        requiresAuth: true,
        queryParams: params,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => AppointmentModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<AppointmentModel>> getAppointmentDetail(
      String appointmentId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.appointmentDetail(appointmentId),
        requiresAuth: true,
      );
      return Success(AppointmentModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<AppointmentModel>> cancelAppointment(
      String appointmentId) async {
    try {
      LoggerService.info('Cancelling appointment: $appointmentId');
      final response = await _client.post(
        ApiEndpoints.cancelAppointment(appointmentId),
        {},
        requiresAuth: true,
      );
      return Success(AppointmentModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<PrescriptionModel>>> getMyPrescriptions() async {
    try {
      final response = await _client.get(
        ApiEndpoints.prescriptions,
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(
          data.map((e) => PrescriptionModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<AppointmentModel>>> getFamilyAppointments(
      String patientId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.familyAppointments(patientId),
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => AppointmentModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
