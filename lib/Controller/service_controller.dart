import 'package:get/get.dart';
import 'package:home_care/Api/Services/service_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/utils/token_storage.dart';

/// Manages service categories, service list and professional discovery
class ServiceController extends GetxController {
  final ServiceRepository _repo = ServiceRepository();

  RxList<ServiceCategory> categories = <ServiceCategory>[].obs;
  RxList<ServiceModel> services = <ServiceModel>[].obs;
  RxList<ServiceModel> quickServices = <ServiceModel>[].obs; // is_quick=true, managed by super admin
  RxList<ProfessionalModel> professionals = <ProfessionalModel>[].obs;
  Rx<ServiceModel?> selectedService = Rx<ServiceModel?>(null);

  RxBool isLoadingCategories = false.obs;
  RxBool isLoadingServices = false.obs;
  RxBool isLoadingQuickServices = false.obs;
  RxBool isLoadingProfessionals = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initIfLoggedIn();
  }

  /// Only fetch if user has a token — avoids 401 on app cold start before login.
  Future<void> _initIfLoggedIn() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (loggedIn) {
      fetchCategories();
      fetchAllServices();
    }
  }

  /// Call this from the home page immediately after login / on home page init.
  Future<void> loadAll() async {
    await fetchCategories();
    await fetchAllServices();
    fetchQuickServices(); // fire-and-forget — populates Quick Book section
  }

  /// Fetches services flagged as "Quick" by the Super Admin.
  /// Calls GET /services?is_quick=true
  Future<void> fetchQuickServices() async {
    try {
      isLoadingQuickServices.value = true;
      final result = await _repo.getAllServices(isQuick: true);
      result.when(
        onSuccess: (data) {
          quickServices.value = data;
          LoggerService.success('Loaded ${data.length} quick services');
        },
        onError: (err) => LoggerService.warning('Quick services load: $err'),
      );
    } finally {
      isLoadingQuickServices.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      errorMessage.value = '';
      final result = await _repo.getCategories();
      result.when(
        onSuccess: (data) {
          categories.value = data;
          LoggerService.success('Loaded ${data.length} categories');
        },
        onError: (err) {
          errorMessage.value = err;
          LoggerService.error('Failed to load categories', err);
        },
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchAllServices() async {
    try {
      isLoadingServices.value = true;
      errorMessage.value = '';
      final result = await _repo.getAllServices();
      result.when(
        onSuccess: (data) => services.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchCategoryServices(String categoryId) async {
    try {
      isLoadingServices.value = true;
      errorMessage.value = '';
      final result = await _repo.getCategoryServices(categoryId);
      result.when(
        onSuccess: (data) => services.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchProfessionals(String serviceId) async {
    try {
      isLoadingProfessionals.value = true;
      errorMessage.value = '';
      final result = await _repo.getProfessionals(serviceId);
      result.when(
        onSuccess: (data) => professionals.value = data,
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingProfessionals.value = false;
    }
  }

  Future<void> selectService(String serviceId) async {
    final result = await _repo.getServiceDetail(serviceId);
    result.when(
      onSuccess: (s) => selectedService.value = s,
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<bool> submitReview({
    required String professionalId,
    required double rating,
    required String comment,
  }) async {
    final result = await _repo.submitReview(
      professionalId: professionalId,
      rating: rating,
      comment: comment,
    );
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        Get.snackbar('Thank you', 'Review submitted successfully');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }
}
