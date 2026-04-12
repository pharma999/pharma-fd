import 'package:get/get.dart';
import 'package:home_care/Model/user_detail_model.dart';
import 'package:home_care/Api/Services/user_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/utils/token_storage.dart';

/// Profile Controller - Manages user profile state with real API calls
class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  // Observable state
  Rx<UserDetail?> user = Rx<UserDetail?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isProfileLoaded = false.obs;
  RxString userId = ''.obs;
  RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('ProfileController initialized');
    _loadIdentityThenProfile();
  }

  /// Load user ID from secure storage, then fetch live profile
  Future<void> _loadIdentityThenProfile() async {
    final id = await TokenStorage.getUserId();
    final role = await TokenStorage.getUserRole();
    if (id != null && id.isNotEmpty) {
      userId.value = id;
      userRole.value = role ?? 'PATIENT';
      await fetchUserProfile();
    } else {
      LoggerService.warning('No user ID in storage – user not logged in');
    }
  }

  /// Fetch user profile from server
  Future<void> fetchUserProfile() async {
    if (userId.value.isEmpty) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result =
          await _userRepository.getUserProfile(userId: userId.value);

      result.when(
        onSuccess: (userDetail) {
          user.value = userDetail;
          isProfileLoaded.value = true;
          LoggerService.success('User profile loaded: ${userDetail.name}');
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to fetch profile', error);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String gender,
  }) async {
    if (userId.value.isEmpty) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _userRepository.updateUserProfile(
        userId: userId.value,
        data: {'name': name, 'email': email, 'gender': gender},
      );

      bool success = false;
      result.when(
        onSuccess: (userDetail) {
          user.value = userDetail;
          success = true;
          LoggerService.success('Profile updated successfully');
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to update profile', error);
        },
      );
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user address
  Future<bool> updateAddress({
    required String addressType,
    required String houseNumber,
    required String street,
    required String landmark,
    required String pinCode,
    required String latitude,
    required String longitude,
  }) async {
    if (userId.value.isEmpty) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _userRepository.updateUserAddress(
        userId: userId.value,
        addressType: addressType,
        addressData: {
          'houseNumber': houseNumber,
          'street': street,
          'landmark': landmark,
          'pinCode': pinCode,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      bool success = false;
      result.when(
        onSuccess: (userDetail) {
          user.value = userDetail;
          success = true;
          LoggerService.success('Address updated successfully');
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to update address', error);
        },
      );
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete account and clear storage
  Future<bool> deleteAccount() async {
    if (userId.value.isEmpty) return false;
    try {
      isLoading.value = true;
      final result =
          await _userRepository.deleteAccount(userId: userId.value);
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          TokenStorage.clearAll();
          Get.offAllNamed('/login');
        },
        onError: (error) {
          errorMessage.value = error;
        },
      );
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  /// Getters
  String get userName => user.value?.name ?? 'User';
  String get userEmail => user.value?.email ?? '';
  bool get hasPrimaryAddress => user.value?.address1 != null;
  bool get isAdmin =>
      userRole.value == 'ADMIN' || userRole.value == 'SUPER_ADMIN';

  /// Refresh user profile
  void refresh() => fetchUserProfile();
}
