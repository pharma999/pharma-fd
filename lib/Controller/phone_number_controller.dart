import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Services/auth_repository.dart';
import 'package:home_care/Helper/phone_number_helper.dart';
import 'package:home_care/Helper/logger_service.dart';

/// Phone Number Controller - Handles phone input validation and submission
class PhoneNumberController extends GetxController
    with GetTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();

  // Form and input controls
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Observable state
  RxString completePhoneNumber = ''.obs;
  RxString countryCode = 'IN'.obs;
  RxBool isLoading = false.obs;
  RxBool isPhoneValid = false.obs;
  RxString errorMessage = ''.obs;

  // Animation controllers
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('PhoneNumberController initialized');
    _setupAnimation();
    _detectCountryFromLocation();
  }

  /// Setup fade and slide animations
  void _setupAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    animationController.forward();
    LoggerService.debug('Animation setup completed');
  }

  /// Detect user's country using geolocation
  Future<void> _detectCountryFromLocation() async {
    try {
      LoggerService.info('Detecting country from location');
      final detectedCode = await PhoneNumberHelper.detectCountryCode();

      if (detectedCode != null) {
        countryCode.value = detectedCode;
        LoggerService.success('Country detected: $detectedCode');
      }
    } catch (e) {
      LoggerService.warning('Error detecting country: $e');
      // Default to IN if detection fails
      countryCode.value = 'IN';
    }
  }

  /// Validate phone number format
  bool _validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      errorMessage.value = 'Phone number cannot be empty';
      return false;
    }

    // Remove non-numeric characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Check if phone number is valid (at least 10 digits)
    if (digitsOnly.length < 10) {
      errorMessage.value =
          'Please enter a valid phone number (at least 10 digits)';
      LoggerService.warning('Invalid phone number length: $digitsOnly');
      return false;
    }

    if (digitsOnly.length > 15) {
      errorMessage.value = 'Phone number is too long';
      return false;
    }

    return true;
  }

  /// Update phone number and validate
  void updatePhoneNumber(String phone) {
    completePhoneNumber.value = phone.trim();

    if (_validatePhoneNumber(phone)) {
      isPhoneValid.value = true;
      errorMessage.value = '';
      LoggerService.debug('Phone number validated: $phone');
    } else {
      isPhoneValid.value = false;
    }
  }

  /// Submit phone number and request OTP
  Future<void> submitPhoneNumber(BuildContext context) async {
    FocusScope.of(context).unfocus();

    // Validate phone number
    if (!formKey.currentState!.validate()) {
      LoggerService.warning('Form validation failed');
      return;
    }

    final phone = phoneController.text.trim();
    if (!_validatePhoneNumber(phone)) {
      LoggerService.warning('Phone number validation failed: $phone');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      LoggerService.info('Submitting phone number: $phone');

      // 🧪 DEMO MODE: Bypass API for testing phone numbers
      const String demoPhone = '6386098744';
      if (phone == demoPhone) {
        LoggerService.success('✅ DEMO MODE: Using bypass phone number');
        completePhoneNumber.value = phone;
        await Future.delayed(const Duration(milliseconds: 800));
        Get.toNamed('/otpPage', arguments: {'phoneNumber': phone});
        return;
      }

      final result = await _authRepository.login(phoneNumber: phone);

      result.when(
        onSuccess: (response) {
          LoggerService.success('OTP sent successfully');
          completePhoneNumber.value = phone;

          // Navigate to OTP page with phone number
          Get.toNamed('/otpPage', arguments: {'phoneNumber': phone});
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to send OTP', error);
          Get.snackbar('Error', error, snackPosition: SnackPosition.BOTTOM);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Form validator function
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Clear form
  void clearForm() {
    phoneController.clear();
    completePhoneNumber.value = '';
    isPhoneValid.value = false;
    errorMessage.value = '';
    LoggerService.info('Form cleared');
  }

  @override
  void onClose() {
    focusNode.dispose();
    phoneController.dispose();
    animationController.dispose();
    super.onClose();
    LoggerService.info('PhoneNumberController disposed');
  }
}
