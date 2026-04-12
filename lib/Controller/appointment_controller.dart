import 'package:get/get.dart';
import 'package:home_care/Api/Services/appointment_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/appointment_model.dart';
import 'package:home_care/Model/doctor_model.dart';

/// Manages appointments and doctor search
class AppointmentController extends GetxController {
  final AppointmentRepository _repo = AppointmentRepository();

  RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  RxList<PrescriptionModel> prescriptions = <PrescriptionModel>[].obs;
  Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);

  RxBool isLoadingAppointments = false.obs;
  RxBool isLoadingDoctors = false.obs;
  RxBool isCreating = false.obs;
  RxString errorMessage = ''.obs;
  RxString statusFilter = ''.obs;

  // Search filters
  RxString searchSpecialty = ''.obs;
  RxString searchConsultationType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyAppointments();
  }

  List<AppointmentModel> get upcomingAppointments =>
      appointments.where((a) => a.isUpcoming).toList();

  List<AppointmentModel> get pastAppointments =>
      appointments.where((a) => a.isCompleted || a.isCancelled).toList();

  Future<void> fetchMyAppointments({String? status}) async {
    try {
      isLoadingAppointments.value = true;
      errorMessage.value = '';
      final result = await _repo.getMyAppointments(
        status: status?.isEmpty == true ? null : status,
      );
      result.when(
        onSuccess: (data) {
          appointments.value = data;
          LoggerService.success('Loaded ${data.length} appointments');
        },
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> searchDoctors({
    String? specialty,
    String? consultationType,
    double? maxFee,
  }) async {
    try {
      isLoadingDoctors.value = true;
      errorMessage.value = '';
      final result = await _repo.searchDoctors(
        specialty: specialty?.isEmpty == true ? null : specialty,
        consultationType:
            consultationType?.isEmpty == true ? null : consultationType,
        maxFee: maxFee,
      );
      result.when(
        onSuccess: (data) {
          doctors.value = data;
          LoggerService.success('Found ${data.length} doctors');
        },
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingDoctors.value = false;
    }
  }

  Future<void> selectDoctor(String doctorId) async {
    final result = await _repo.getDoctorProfile(doctorId);
    result.when(
      onSuccess: (d) => selectedDoctor.value = d,
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<bool> createAppointment({
    required String doctorId,
    required String type,
    required String scheduledAt,
    String? familyMemberId,
    String? address,
    String? notes,
  }) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';
      final result = await _repo.createAppointment(
        doctorId: doctorId,
        type: type,
        scheduledAt: scheduledAt,
        familyMemberId: familyMemberId,
        address: address,
        notes: notes,
      );
      bool success = false;
      result.when(
        onSuccess: (appointment) {
          success = true;
          appointments.add(appointment);
          LoggerService.success('Appointment created: ${appointment.id}');
          Get.snackbar('Success', 'Appointment booked successfully!');
        },
        onError: (err) {
          errorMessage.value = err;
          Get.snackbar('Error', err);
        },
      );
      return success;
    } finally {
      isCreating.value = false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    final result = await _repo.cancelAppointment(appointmentId);
    bool success = false;
    result.when(
      onSuccess: (updated) {
        success = true;
        final idx = appointments.indexWhere((a) => a.id == appointmentId);
        if (idx >= 0) appointments[idx] = updated;
        Get.snackbar('Cancelled', 'Appointment cancelled');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<void> fetchPrescriptions() async {
    final result = await _repo.getMyPrescriptions();
    result.when(
      onSuccess: (data) => prescriptions.value = data,
      onError: (err) => errorMessage.value = err,
    );
  }
}
