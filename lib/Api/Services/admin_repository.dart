import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Model/admin_model.dart';
import 'package:home_care/Model/booking_model.dart';
import 'package:home_care/Model/doctor_model.dart';
import 'package:home_care/Model/emergency_model.dart';
import 'package:home_care/Model/user_detail_model.dart';

class AdminRepository {
  final ApiClient _client = ApiClient();

  // ── Analytics ──────────────────────────────────────────────────────────

  Future<ApiResult<AdminAnalytics>> getAnalytics() async {
    try {
      final res = await _client.get(ApiEndpoints.adminAnalytics,
          requiresAuth: true);
      return Success(AdminAnalytics.fromJson(res['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Users ──────────────────────────────────────────────────────────────

  Future<ApiResult<List<UserDetail>>> listUsers({
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (role != null && role.isNotEmpty) params['role'] = role;
      if (status != null && status.isNotEmpty) params['status'] = status;

      final res = await _client.get(ApiEndpoints.adminUsers,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => UserDetail.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> blockUser(String userId, bool block) async {
    try {
      await _client.patch(
        ApiEndpoints.adminBlockUser(userId),
        {'block': block},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Doctor Approvals ───────────────────────────────────────────────────

  Future<ApiResult<List<DoctorModel>>> listDoctors({
    String? approvalStatus,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString(), 'limit': '20'};
      if (approvalStatus != null && approvalStatus.isNotEmpty) {
        params['approval_status'] = approvalStatus;
      }
      final res = await _client.get(ApiEndpoints.adminDoctors,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => DoctorModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> approveDoctor(String doctorId, String status) async {
    try {
      await _client.patch(
        ApiEndpoints.adminApproveDoctor(doctorId),
        {'status': status},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Nurse Approvals ────────────────────────────────────────────────────

  Future<ApiResult<List<NurseModel>>> listNurses({
    String? approvalStatus,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString(), 'limit': '20'};
      if (approvalStatus != null && approvalStatus.isNotEmpty) {
        params['approval_status'] = approvalStatus;
      }
      final res = await _client.get(ApiEndpoints.adminNurses,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => NurseModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> approveNurse(String nurseId, String status) async {
    try {
      await _client.patch(
        ApiEndpoints.adminApproveNurse(nurseId),
        {'status': status},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Hospital Approvals ─────────────────────────────────────────────────

  Future<ApiResult<List<Map<String, dynamic>>>> listHospitals({
    String? approvalStatus,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString(), 'limit': '20'};
      if (approvalStatus != null && approvalStatus.isNotEmpty) {
        params['approval_status'] = approvalStatus;
      }
      final res = await _client.get(ApiEndpoints.adminHospitals,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.cast<Map<String, dynamic>>());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> approveHospital(
      String hospitalId, String status) async {
    try {
      await _client.patch(
        ApiEndpoints.adminApproveHospital(hospitalId),
        {'status': status},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Bookings ───────────────────────────────────────────────────────────

  Future<ApiResult<List<BookingModel>>> listBookings({
    String? status,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString(), 'limit': '20'};
      if (status != null && status.isNotEmpty) params['status'] = status;
      final res = await _client.get(ApiEndpoints.adminBookings,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => BookingModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateBookingStatus(
      String bookingId, String status) async {
    try {
      await _client.patch(
        ApiEndpoints.adminUpdateBooking(bookingId),
        {'status': status},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Emergencies ────────────────────────────────────────────────────────

  Future<ApiResult<List<EmergencyModel>>> listActiveEmergencies() async {
    try {
      final res = await _client.get(ApiEndpoints.adminActiveEmergencies,
          requiresAuth: true);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => EmergencyModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateEmergencyStatus(
      String emergencyId, String status) async {
    try {
      await _client.patch(
        ApiEndpoints.adminUpdateEmergency(emergencyId),
        {'status': status},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Support Tickets ────────────────────────────────────────────────────

  Future<ApiResult<List<SupportTicket>>> listTickets({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString(), 'limit': '20'};
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (priority != null && priority.isNotEmpty) {
        params['priority'] = priority;
      }
      final res = await _client.get(ApiEndpoints.adminSupportTickets,
          requiresAuth: true, queryParams: params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => SupportTicket.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateTicket(
    String ticketId, {
    String? status,
    String? priority,
    String? assignedTo,
    String? resolution,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (priority != null) body['priority'] = priority;
      if (assignedTo != null) body['assigned_to'] = assignedTo;
      if (resolution != null) body['resolution'] = resolution;
      await _client.patch(
        ApiEndpoints.adminSupportTicket(ticketId),
        body,
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Subscription Plans ─────────────────────────────────────────────────

  Future<ApiResult<List<SubscriptionPlan>>> listPlans() async {
    try {
      final res =
          await _client.get(ApiEndpoints.adminPlans, requiresAuth: true);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => SubscriptionPlan.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<SubscriptionPlan>> createPlan(
      Map<String, dynamic> body) async {
    try {
      final res = await _client.post(ApiEndpoints.adminPlans, body,
          requiresAuth: true);
      return Success(SubscriptionPlan.fromJson(res['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updatePlan(
      String planId, Map<String, dynamic> body) async {
    try {
      await _client.put(ApiEndpoints.adminPlan(planId), body,
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> deletePlan(String planId) async {
    try {
      await _client.delete(ApiEndpoints.adminPlan(planId), requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Service Zones ──────────────────────────────────────────────────────

  Future<ApiResult<List<ServiceZone>>> listZones({String? status}) async {
    try {
      final params = <String, String>{};
      if (status != null && status.isNotEmpty) params['status'] = status;
      final res = await _client.get(ApiEndpoints.adminZones,
          requiresAuth: true, queryParams: params.isEmpty ? null : params);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => ServiceZone.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> createZone(Map<String, dynamic> body) async {
    try {
      await _client.post(ApiEndpoints.adminZones, body, requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateZone(
      String zoneId, Map<String, dynamic> body) async {
    try {
      await _client.put(ApiEndpoints.adminZone(zoneId), body,
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  // ── Super Admin ────────────────────────────────────────────────────────

  Future<ApiResult<RevenueReport>> getRevenueReport() async {
    try {
      final res = await _client.get(ApiEndpoints.superAdminRevenue,
          requiresAuth: true);
      return Success(RevenueReport.fromJson(res['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<UserDetail>>> listAdmins({int page = 1}) async {
    try {
      final res = await _client.get(ApiEndpoints.superAdminAdmins,
          requiresAuth: true,
          queryParams: {'page': page.toString(), 'limit': '20'});
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => UserDetail.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> createAdmin(Map<String, dynamic> body) async {
    try {
      await _client.post(ApiEndpoints.superAdminAdmins, body,
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> deleteAdmin(String adminId) async {
    try {
      await _client.delete(ApiEndpoints.superAdminDeleteAdmin(adminId),
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<PlatformSettings>> getSettings() async {
    try {
      final res = await _client.get(ApiEndpoints.superAdminSettings,
          requiresAuth: true);
      return Success(PlatformSettings.fromJson(res['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateSettings(Map<String, dynamic> body) async {
    try {
      await _client.put(ApiEndpoints.superAdminSettings, body,
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
