import 'package:get/get.dart';
import 'package:home_care/Model/user_detail_model.dart';
import 'package:home_care/Model/address_model.dart';
import 'package:home_care/Api/Services/user_repository.dart';
import 'package:home_care/Helper/logger_service.dart';

/// Profile Controller - Manages user profile state with repository pattern
class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  // Observable state
  Rx<UserDetail?> user = Rx<UserDetail?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isProfileLoaded = false.obs;

  // Mock user ID - In real app, this would come from auth
  static const String _mockUserId = '1';

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('ProfileController initialized');
    _initializeMockUser();
  }

  /// Initialize with mock user data for demo purposes
  /// In production, fetch from API
  void _initializeMockUser() {
    try {
      user.value = UserDetail(
        userId: _mockUserId,
        name: 'Alex Morgan',
        email: 'alex@example.com',
        phoneNumber: '+91 9876543210',
        gender: 'MALE',
        status: 'ACTIVE',
        blockStatus: 'UNBLOCKED',
        userService: 'UNSUBSCRIBED',
        serviceStatus: 'NEW',
        address1: Address(
          houseNumber: '12A',
          street: 'Jankipuram Sector-H',
          landmark: 'Near City Mall',
          pinCode: '226021',
          latitude: '26.8467',
          longitude: '80.9462',
          isPrimary: true,
        ),
        address2: null,
      );
      isProfileLoaded.value = true;
      LoggerService.success('Mock user initialized');
    } catch (e) {
      LoggerService.error('Error initializing mock user', e);
    }
  }

  /// Fetch user profile from server
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _userRepository.getUserProfile(userId: _mockUserId);

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
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _userRepository.updateUserProfile(
        userId: _mockUserId,
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
    required String addressType, // 'address1' or 'address2'
    required String houseNumber,
    required String street,
    required String landmark,
    required String pinCode,
    required String latitude,
    required String longitude,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _userRepository.updateUserAddress(
        userId: _mockUserId,
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

  /// Navigate to profile page
  void viewProfile() {
    LoggerService.info('Navigating to profile page');
    Get.offAllNamed('/profile');
  }

  /// Get current user name
  String get userName => user.value?.name ?? 'User';

  /// Get current user email
  String get userEmail => user.value?.email ?? '';

  /// Check if user has primary address
  bool get hasPrimaryAddress => user.value?.address1 != null;

  /// Refresh user profile
  void refresh() {
    fetchUserProfile();
  }
}
