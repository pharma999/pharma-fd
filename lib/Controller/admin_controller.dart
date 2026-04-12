import 'package:get/get.dart';
import 'package:home_care/Api/Services/admin_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/admin_model.dart';
import 'package:home_care/Model/booking_model.dart';
import 'package:home_care/Model/doctor_model.dart';
import 'package:home_care/Model/emergency_model.dart';
import 'package:home_care/Model/user_detail_model.dart';
import 'package:home_care/utils/token_storage.dart';

class AdminController extends GetxController {
  final AdminRepository _repo = AdminRepository();

  // ── State ────────────────────────────────────────────────────────────────
  Rx<AdminAnalytics?> analytics = Rx<AdminAnalytics?>(null);
  Rx<RevenueReport?> revenueReport = Rx<RevenueReport?>(null);
  Rx<PlatformSettings?> settings = Rx<PlatformSettings?>(null);

  RxList<UserDetail> users = <UserDetail>[].obs;
  RxList<UserDetail> adminUsers = <UserDetail>[].obs;
  RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  RxList<NurseModel> nurses = <NurseModel>[].obs;
  RxList<Map<String, dynamic>> hospitals = <Map<String, dynamic>>[].obs;
  RxList<BookingModel> bookings = <BookingModel>[].obs;
  RxList<EmergencyModel> activeEmergencies = <EmergencyModel>[].obs;
  RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  RxList<ServiceZone> zones = <ServiceZone>[].obs;

  RxBool isLoadingAnalytics = false.obs;
  RxBool isLoadingUsers = false.obs;
  RxBool isLoadingApprovals = false.obs;
  RxBool isLoadingBookings = false.obs;
  RxBool isLoadingEmergencies = false.obs;
  RxBool isLoadingTickets = false.obs;
  RxBool isLoadingPlans = false.obs;
  RxBool isLoadingRevenue = false.obs;
  RxBool isActionPending = false.obs;
  RxString errorMessage = ''.obs;

  RxString userRoleFilter = ''.obs;
  RxString approvalFilter = 'PENDING'.obs;
  RxString ticketStatusFilter = ''.obs;

  RxString userRole = ''.obs;
  bool get isSuperAdmin => userRole.value == 'SUPER_ADMIN';

  @override
  void onInit() {
    super.onInit();
    _loadRole();
    fetchAnalytics();
  }

  Future<void> _loadRole() async {
    userRole.value = await TokenStorage.getUserRole() ?? '';
  }

  // ── Analytics ────────────────────────────────────────────────────────────

  Future<void> fetchAnalytics() async {
    try {
      isLoadingAnalytics.value = true;
      final result = await _repo.getAnalytics();
      result.when(
        onSuccess: (data) {
          analytics.value = data;
          LoggerService.success('Analytics loaded');
        },
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  // ── Users ────────────────────────────────────────────────────────────────

  Future<void> fetchUsers({String? role, String? status}) async {
    try {
      isLoadingUsers.value = true;
      final result = await _repo.listUsers(
        role: role ?? (userRoleFilter.value.isEmpty ? null : userRoleFilter.value),
        status: status,
      );
      result.when(
        onSuccess: (data) => users.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<bool> blockUser(String userId, bool block) async {
    try {
      isActionPending.value = true;
      final result = await _repo.blockUser(userId, block);
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          fetchUsers();
          Get.snackbar('Done', block ? 'User blocked' : 'User unblocked');
        },
        onError: (err) => Get.snackbar('Error', err),
      );
      return success;
    } finally {
      isActionPending.value = false;
    }
  }

  // ── Doctor Approvals ─────────────────────────────────────────────────────

  Future<void> fetchDoctors({String? approvalStatus}) async {
    try {
      isLoadingApprovals.value = true;
      final result = await _repo.listDoctors(
          approvalStatus:
              approvalStatus ?? approvalFilter.value);
      result.when(
        onSuccess: (data) => doctors.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  Future<bool> approveDoctor(String doctorId, String status) async {
    try {
      isActionPending.value = true;
      final result = await _repo.approveDoctor(doctorId, status);
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          fetchDoctors();
          Get.snackbar('Done', 'Doctor $status');
        },
        onError: (err) => Get.snackbar('Error', err),
      );
      return success;
    } finally {
      isActionPending.value = false;
    }
  }

  // ── Nurse Approvals ──────────────────────────────────────────────────────

  Future<void> fetchNurses({String? approvalStatus}) async {
    try {
      isLoadingApprovals.value = true;
      final result = await _repo.listNurses(
          approvalStatus: approvalStatus ?? approvalFilter.value);
      result.when(
        onSuccess: (data) => nurses.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  Future<bool> approveNurse(String nurseId, String status) async {
    try {
      isActionPending.value = true;
      final result = await _repo.approveNurse(nurseId, status);
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          fetchNurses();
          Get.snackbar('Done', 'Nurse $status');
        },
        onError: (err) => Get.snackbar('Error', err),
      );
      return success;
    } finally {
      isActionPending.value = false;
    }
  }

  // ── Hospital Approvals ───────────────────────────────────────────────────

  Future<void> fetchHospitals({String? approvalStatus}) async {
    try {
      isLoadingApprovals.value = true;
      final result = await _repo.listHospitals(
          approvalStatus: approvalStatus ?? approvalFilter.value);
      result.when(
        onSuccess: (data) => hospitals.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  Future<bool> approveHospital(String hospitalId, String status) async {
    try {
      isActionPending.value = true;
      final result = await _repo.approveHospital(hospitalId, status);
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          fetchHospitals();
          Get.snackbar('Done', 'Hospital $status');
        },
        onError: (err) => Get.snackbar('Error', err),
      );
      return success;
    } finally {
      isActionPending.value = false;
    }
  }

  // ── Bookings ─────────────────────────────────────────────────────────────

  Future<void> fetchAllBookings({String? status}) async {
    try {
      isLoadingBookings.value = true;
      final result = await _repo.listBookings(status: status);
      result.when(
        onSuccess: (data) => bookings.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingBookings.value = false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final result = await _repo.updateBookingStatus(bookingId, status);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchAllBookings();
        Get.snackbar('Updated', 'Booking status: $status');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  // ── Emergencies ──────────────────────────────────────────────────────────

  Future<void> fetchActiveEmergencies() async {
    try {
      isLoadingEmergencies.value = true;
      final result = await _repo.listActiveEmergencies();
      result.when(
        onSuccess: (data) => activeEmergencies.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingEmergencies.value = false;
    }
  }

  Future<bool> updateEmergencyStatus(
      String emergencyId, String status) async {
    final result = await _repo.updateEmergencyStatus(emergencyId, status);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchActiveEmergencies();
        Get.snackbar('Updated', 'Emergency: $status');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  // ── Support Tickets ──────────────────────────────────────────────────────

  Future<void> fetchTickets({String? status}) async {
    try {
      isLoadingTickets.value = true;
      final result = await _repo.listTickets(
          status: status ??
              (ticketStatusFilter.value.isEmpty
                  ? null
                  : ticketStatusFilter.value));
      result.when(
        onSuccess: (data) => tickets.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingTickets.value = false;
    }
  }

  Future<bool> resolveTicket(String ticketId,
      {String? resolution, String? assignedTo}) async {
    final result = await _repo.updateTicket(
      ticketId,
      status: 'RESOLVED',
      resolution: resolution,
      assignedTo: assignedTo,
    );
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchTickets();
        Get.snackbar('Resolved', 'Support ticket closed');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  // ── Subscription Plans ───────────────────────────────────────────────────

  Future<void> fetchPlans() async {
    try {
      isLoadingPlans.value = true;
      final result = await _repo.listPlans();
      result.when(
        onSuccess: (data) => plans.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingPlans.value = false;
    }
  }

  Future<bool> createPlan(Map<String, dynamic> body) async {
    final result = await _repo.createPlan(body);
    bool success = false;
    result.when(
      onSuccess: (plan) {
        success = true;
        plans.add(plan);
        Get.snackbar('Created', 'Subscription plan added');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<bool> togglePlanActive(String planId, bool isActive) async {
    final result = await _repo.updatePlan(planId, {'is_active': isActive});
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchPlans();
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<bool> deletePlan(String planId) async {
    final result = await _repo.deletePlan(planId);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        plans.removeWhere((p) => p.id == planId);
        Get.snackbar('Deleted', 'Plan removed');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  // ── Service Zones ────────────────────────────────────────────────────────

  Future<void> fetchZones() async {
    final result = await _repo.listZones();
    result.when(
      onSuccess: (data) => zones.value = data,
      onError: (err) => errorMessage.value = err,
    );
  }

  // ── Super Admin ──────────────────────────────────────────────────────────

  Future<void> fetchRevenueReport() async {
    try {
      isLoadingRevenue.value = true;
      final result = await _repo.getRevenueReport();
      result.when(
        onSuccess: (data) => revenueReport.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingRevenue.value = false;
    }
  }

  Future<void> fetchAdminUsers() async {
    final result = await _repo.listAdmins();
    result.when(
      onSuccess: (data) => adminUsers.value = data,
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<bool> createAdmin(
      String name, String phone, String role, String email) async {
    final result = await _repo.createAdmin({
      'name': name,
      'phone_number': phone,
      'email': email,
      'role': role,
    });
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchAdminUsers();
        Get.snackbar('Created', '$role created successfully');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<bool> removeAdmin(String adminId) async {
    final result = await _repo.deleteAdmin(adminId);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        adminUsers.removeWhere((u) => u.userId == adminId);
        Get.snackbar('Removed', 'Admin removed');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<void> fetchSettings() async {
    final result = await _repo.getSettings();
    result.when(
      onSuccess: (data) => settings.value = data,
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<bool> saveSettings(Map<String, dynamic> body) async {
    final result = await _repo.updateSettings(body);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        fetchSettings();
        Get.snackbar('Saved', 'Platform settings updated');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }
}
