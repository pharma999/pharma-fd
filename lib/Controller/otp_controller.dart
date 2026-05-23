// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:home_care/Api/Services/auth_repository.dart';
// import 'package:home_care/Controller/profile_controller.dart';
// import 'package:home_care/Controller/service_controller.dart';
// import 'package:home_care/Controller/service_professionals_controller.dart';
// import 'package:home_care/Helper/logger_service.dart';

// /// OTP Controller - Handles OTP verification with proper validation and error handling
// class OtpController extends GetxController {
//   final AuthRepository _authRepository = AuthRepository();

//   // Observable state
//   RxBool isLoading = false.obs;
//   RxBool isOtpSent = false.obs;
//   RxString errorMessage = ''.obs;
//   RxInt secondsRemaining = 60.obs;
//   RxBool canResend = false.obs;

//   // OTP input tracking
//   final RxList<TextEditingController> otpControllers = List.generate(
//     4,
//     (_) => TextEditingController(),
//   ).obs;
//   final RxString phoneNumber = ''.obs;
//   final RxString verificationId = ''.obs;

//   // Constants
//   static const int otpLength = 4;
//   static const int resendTimeoutSeconds = 60;
//   // Test OTP for demo
//   static const String testOtp = '5555';

//   @override
//   void onInit() {
//     super.onInit();
//     LoggerService.info('OtpController initialized');
//   }

//   @override
//   void onClose() {
//     // Clean up controllers
//     for (var controller in otpControllers) {
//       controller.dispose();
//     }
//     super.onClose();
//   }

//   /// Set phone number for OTP verification
//   void setPhoneNumber(String number) {
//     phoneNumber.value = number;
//     LoggerService.debug('Phone number set for OTP: $number');
//   }

//   /// Set the verificationId returned by the send-OTP step
//   void setVerificationId(String id) {
//     verificationId.value = id;
//     LoggerService.debug('VerificationId set: $id');
//   }

//   /// Submit OTP - gather from local page controllers and verify
//   Future<bool> submitOtpWithControllers(
//     List<TextEditingController> pageControllers,
//   ) async {
//     try {
//       // Gather OTP from page controllers instead of internal controllers
//       final otp = pageControllers.map((c) => c.text).join();

//       if (!_validateOtp(otp)) {
//         return false;
//       }

//       if (phoneNumber.value.isEmpty) {
//         errorMessage.value = 'Phone number not set';
//         LoggerService.error('Cannot verify OTP - phone number not set');
//         return false;
//       }

//       isLoading.value = true;
//       errorMessage.value = '';

//       LoggerService.info('Verifying OTP: $otp for phone: ${phoneNumber.value}');

//       // Real OTP verification
//       final result = await _authRepository.verifyOtp(
//         phoneNumber: phoneNumber.value,
//         otp: otp,
//         verificationId: verificationId.value.isNotEmpty ? verificationId.value : null,
//       );

//       bool success = false;
//       result.when(
//         onSuccess: (response) {
//           success = true;
//           LoggerService.success('OTP verified successfully');
//           _clearOtpInputs();
//           _loadHomeData();
//           Get.offAllNamed('/bottomAppBar');
//         },
//         onError: (error) {
//           errorMessage.value = error;
//           LoggerService.error('OTP verification failed', error);
//           _clearOtpInputs();
//         },
//       );

//       return success;
//     } catch (e) {
//       errorMessage.value = 'An error occurred during OTP verification';
//       LoggerService.error('OTP verification exception', e.toString());
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Submit OTP - gather from controllers and verify
//   Future<bool> submitOtp() async {
//     try {
//       // Validate OTP input
//       final otp = _gatherOtp();
//       if (!_validateOtp(otp)) {
//         return false;
//       }

//       if (phoneNumber.value.isEmpty) {
//         errorMessage.value = 'Phone number not set';
//         LoggerService.error('Cannot verify OTP - phone number not set');
//         return false;
//       }

//       isLoading.value = true;
//       errorMessage.value = '';

//       LoggerService.info('Verifying OTP: $otp for phone: ${phoneNumber.value}');

//       // Real OTP verification
//       final result = await _authRepository.verifyOtp(
//         phoneNumber: phoneNumber.value,
//         otp: otp,
//         verificationId: verificationId.value.isNotEmpty ? verificationId.value : null,
//       );

//       bool success = false;
//       result.when(
//         onSuccess: (response) {
//           success = true;
//           LoggerService.success('OTP verified successfully');
//           _clearOtpInputs();
//           _loadHomeData();
//           Get.offAllNamed('/bottomAppBar');
//         },
//         onError: (error) {
//           errorMessage.value = error;
//           LoggerService.error('OTP verification failed', error);
//           _clearOtpInputs();
//         },
//       );

//       return success;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Request OTP to be sent to phone number
//   Future<bool> requestOtp(String phone) async {
//     try {
//       if (!_validatePhoneNumber(phone)) {
//         return false;
//       }

//       setPhoneNumber(phone);
//       isLoading.value = true;
//       errorMessage.value = '';

//       LoggerService.info('Requesting OTP for: $phone');

//       final result = await _authRepository.login(phoneNumber: phone);

//       bool success = false;
//       result.when(
//         onSuccess: (response) {
//           success = true;
//           isOtpSent.value = true;
//           LoggerService.success('OTP sent successfully');
//           _startResendTimer();
//         },
//         onError: (error) {
//           errorMessage.value = error;
//           LoggerService.error('Failed to send OTP', error);
//         },
//       );

//       return success;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Resend OTP
//   Future<bool> resendOtp() async {
//     if (!canResend.value) {
//       errorMessage.value = 'Please wait before requesting OTP again';
//       return false;
//     }

//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       LoggerService.info('Resending OTP for: ${phoneNumber.value}');

//       final result = await _authRepository.login(
//         phoneNumber: phoneNumber.value,
//       );

//       bool success = false;
//       result.when(
//         onSuccess: (response) {
//           success = true;
//           LoggerService.success('OTP resent successfully');
//           _clearOtpInputs();
//           _startResendTimer();
//         },
//         onError: (error) {
//           errorMessage.value = error;
//           LoggerService.error('Failed to resend OTP', error);
//         },
//       );

//       return success;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Triggers home data load after successful login (token is already saved at this point).
//   void _loadHomeData() {
//     if (Get.isRegistered<ServiceController>()) {
//       Get.find<ServiceController>().loadAll();
//     }
//     if (Get.isRegistered<ServiceProfessionalsController>()) {
//       Get.find<ServiceProfessionalsController>().fetchAll();
//     }
//     if (Get.isRegistered<ProfileController>()) {
//       Get.find<ProfileController>().loadAfterLogin();
//     }
//   }

//   /// Gather OTP from all controllers
//   String _gatherOtp() {
//     return otpControllers.map((controller) => controller.text).join();
//   }

//   /// Clear OTP inputs
//   void _clearOtpInputs() {
//     for (var controller in otpControllers) {
//       controller.clear();
//     }
//   }

//   /// Validate OTP format
//   bool _validateOtp(String otp) {
//     if (otp.length != otpLength) {
//       errorMessage.value = 'Please enter a complete 4-digit OTP';
//       LoggerService.warning('Invalid OTP length: ${otp.length}');
//       return false;
//     }

//     if (!RegExp(r'^[0-9]*$').hasMatch(otp)) {
//       errorMessage.value = 'OTP must contain only digits';
//       LoggerService.warning('OTP contains non-digit characters');
//       return false;
//     }

//     return true;
//   }

//   /// Validate phone number format
//   bool _validatePhoneNumber(String phone) {
//     if (phone.isEmpty) {
//       errorMessage.value = 'Phone number cannot be empty';
//       return false;
//     }

//     // Remove non-digit characters for validation
//     final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

//     if (digitsOnly.length < 10) {
//       errorMessage.value = 'Phone number must be at least 10 digits';
//       LoggerService.warning('Invalid phone number: $phone');
//       return false;
//     }

//     return true;
//   }

//   /// Start resend countdown timer
//   void _startResendTimer() {
//     canResend.value = false;
//     secondsRemaining.value = resendTimeoutSeconds;

//     Future.delayed(const Duration(seconds: 1), () {
//       _updateTimer();
//     });
//   }

//   /// Update timer recursively
//   void _updateTimer() {
//     if (secondsRemaining.value > 0) {
//       secondsRemaining.value--;
//       Future.delayed(const Duration(seconds: 1), () {
//         _updateTimer();
//       });
//     } else {
//       canResend.value = true;
//       LoggerService.info('Resend OTP is now available');
//     }
//   }

//   /// Get current OTP as string
//   String get currentOtp => _gatherOtp();

//   /// Check if OTP is complete
//   bool get isOtpComplete => _gatherOtp().length == otpLength;

//   /// Get resend timer text
//   String get resendTimerText =>
//       canResend.value ? 'Resend OTP' : 'Resend in ${secondsRemaining.value}s';
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Services/auth_repository.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Helper/logger_service.dart';

/// OTP Controller - Handles OTP verification with proper validation and error handling
class OtpController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observable state
  RxBool isLoading = false.obs;
  RxBool isOtpSent = false.obs;
  RxString errorMessage = ''.obs;
  RxInt secondsRemaining = 60.obs;
  RxBool canResend = false.obs;

  // OTP input tracking
  final RxList<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  ).obs;

  final RxString phoneNumber = ''.obs;
  final RxString verificationId = ''.obs;

  // Constants
  static const int otpLength = 6;
  static const int resendTimeoutSeconds = 60;

  // Test OTP for demo
  static const String testOtp = '555555';

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('OtpController initialized');
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  /// Set phone number for OTP verification
  void setPhoneNumber(String number) {
    phoneNumber.value = number;
    LoggerService.debug('Phone number set for OTP: $number');
  }

  /// Set the verificationId returned by the send-OTP step
  void setVerificationId(String id) {
    verificationId.value = id;
    LoggerService.debug('VerificationId set: $id');
  }

  /// Submit OTP - gather from local page controllers and verify
  Future<bool> submitOtpWithControllers(
    List<TextEditingController> pageControllers,
  ) async {
    try {
      final otp = pageControllers.map((c) => c.text).join();

      if (!_validateOtp(otp)) {
        return false;
      }

      if (phoneNumber.value.isEmpty) {
        errorMessage.value = 'Phone number not set';
        LoggerService.error('Cannot verify OTP - phone number not set');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      LoggerService.info('Verifying OTP: $otp for phone: ${phoneNumber.value}');

      final result = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber.value,
        otp: otp,
        verificationId: verificationId.value.isNotEmpty
            ? verificationId.value
            : null,
      );

      bool success = false;

      result.when(
        onSuccess: (response) {
          success = true;
          LoggerService.success('OTP verified successfully');
          _clearOtpInputs();
          _loadHomeData();
          Get.offAllNamed('/bottomAppBar');
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('OTP verification failed', error);
          _clearOtpInputs();
        },
      );

      return success;
    } catch (e) {
      errorMessage.value = 'An error occurred during OTP verification';
      LoggerService.error('OTP verification exception', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit OTP - gather from internal controllers and verify
  Future<bool> submitOtp() async {
    try {
      final otp = _gatherOtp();

      if (!_validateOtp(otp)) {
        return false;
      }

      if (phoneNumber.value.isEmpty) {
        errorMessage.value = 'Phone number not set';
        LoggerService.error('Cannot verify OTP - phone number not set');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      LoggerService.info('Verifying OTP: $otp for phone: ${phoneNumber.value}');

      final result = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber.value,
        otp: otp,
        verificationId: verificationId.value.isNotEmpty
            ? verificationId.value
            : null,
      );

      bool success = false;

      result.when(
        onSuccess: (response) {
          success = true;
          LoggerService.success('OTP verified successfully');
          _clearOtpInputs();
          _loadHomeData();
          Get.offAllNamed('/bottomAppBar');
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('OTP verification failed', error);
          _clearOtpInputs();
        },
      );

      return success;
    } catch (e) {
      errorMessage.value = 'An error occurred during OTP verification';
      LoggerService.error('OTP verification exception', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Request OTP to be sent to phone number
  Future<bool> requestOtp(String phone) async {
    try {
      if (!_validatePhoneNumber(phone)) {
        return false;
      }

      setPhoneNumber(phone);
      isLoading.value = true;
      errorMessage.value = '';

      LoggerService.info('Requesting OTP for: $phone');

      final result = await _authRepository.login(phoneNumber: phone);

      bool success = false;

      result.when(
        onSuccess: (response) {
          success = true;
          isOtpSent.value = true;
          LoggerService.success('OTP sent successfully');
          _startResendTimer();
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to send OTP', error);
        },
      );

      return success;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (!canResend.value) {
      errorMessage.value = 'Please wait before requesting OTP again';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      LoggerService.info('Resending OTP for: ${phoneNumber.value}');

      final result = await _authRepository.login(
        phoneNumber: phoneNumber.value,
      );

      bool success = false;

      result.when(
        onSuccess: (response) {
          success = true;
          LoggerService.success('OTP resent successfully');
          _clearOtpInputs();
          _startResendTimer();
        },
        onError: (error) {
          errorMessage.value = error;
          LoggerService.error('Failed to resend OTP', error);
        },
      );

      return success;
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers home data load after successful login
  void _loadHomeData() {
    if (Get.isRegistered<ServiceController>()) {
      Get.find<ServiceController>().loadAll();
    }
    if (Get.isRegistered<ServiceProfessionalsController>()) {
      Get.find<ServiceProfessionalsController>().fetchAll();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadAfterLogin();
    }
  }

  /// Gather OTP from all controllers
  String _gatherOtp() {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// Clear OTP inputs
  void _clearOtpInputs() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  /// Validate OTP format
  bool _validateOtp(String otp) {
    if (otp.trim().isEmpty) {
      errorMessage.value = 'OTP cannot be empty';
      LoggerService.warning('OTP is empty');
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(otp)) {
      errorMessage.value = 'OTP must contain only digits';
      LoggerService.warning('OTP contains non-digit characters');
      return false;
    }

    if (otp.length != otpLength) {
      errorMessage.value = 'Please enter a complete $otpLength-digit OTP';
      LoggerService.warning('Invalid OTP length: ${otp.length}');
      return false;
    }

    return true;
  }

  /// Validate phone number format
  bool _validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      errorMessage.value = 'Phone number cannot be empty';
      return false;
    }

    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      errorMessage.value = 'Phone number must be at least 10 digits';
      LoggerService.warning('Invalid phone number: $phone');
      return false;
    }

    return true;
  }

  /// Start resend countdown timer
  void _startResendTimer() {
    canResend.value = false;
    secondsRemaining.value = resendTimeoutSeconds;

    Future.delayed(const Duration(seconds: 1), () {
      _updateTimer();
    });
  }

  /// Update timer recursively
  void _updateTimer() {
    if (secondsRemaining.value > 0) {
      secondsRemaining.value--;
      Future.delayed(const Duration(seconds: 1), () {
        _updateTimer();
      });
    } else {
      canResend.value = true;
      LoggerService.info('Resend OTP is now available');
    }
  }

  /// Get current OTP as string
  String get currentOtp => _gatherOtp();

  /// Check if OTP is complete
  bool get isOtpComplete => _gatherOtp().length == otpLength;

  /// Get resend timer text
  String get resendTimerText =>
      canResend.value ? 'Resend OTP' : 'Resend in ${secondsRemaining.value}s';
}
