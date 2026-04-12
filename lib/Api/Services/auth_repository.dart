import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/utils/token_storage.dart';
import '../Config/api_endpoints.dart';

/// Authentication Repository — phone-number + OTP via MessageCentral
class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Holds the verificationId from step 1 for use in step 2
  String _pendingVerificationId = '';

  // ── Step 1: Send OTP ──────────────────────────────────────────────────────

  /// Sends OTP to [phoneNumber] via MessageCentral.
  /// Response contains `verification_id` that must be passed to [verifyOtp].
  Future<ApiResult<Map<String, dynamic>>> sendOtp({
    required String phoneNumber,
  }) async {
    try {
      LoggerService.info('Sending OTP to: $phoneNumber');

      // final response = await _apiClient.post(
      //   ApiEndpoints.sendOtp,
      //   {'phone_number': phoneNumber},
      //   requiresAuth: false,
      // );
      final response = await _apiClient.post(ApiEndpoints.sendOtp, {
        'phone_number': phoneNumber,
      }, requiresAuth: false);

      final map = response as Map<String, dynamic>;
      _pendingVerificationId = map['verification_id'] ?? '';
      LoggerService.success(
        'OTP sent. verificationId: $_pendingVerificationId',
      );
      return Success(map);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Send OTP failed', msg);
      return Error(msg);
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────

  /// Verifies [otp] with MessageCentral using the stored verificationId.
  /// On success the backend issues a JWT unique to this user and persists it.
  Future<ApiResult<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  }) async {
    try {
      final vid = verificationId ?? _pendingVerificationId;
      LoggerService.info('Verifying OTP for: $phoneNumber (vid: $vid)');

      final response = await _apiClient.post(ApiEndpoints.verifyOtp, {
        'phone_number': phoneNumber,
        'otp': otp,
        'verification_id': vid,
      }, requiresAuth: false);

      final map = response as Map<String, dynamic>;

      // JWT token — generated fresh per user by the backend
      final token = map['token'] ?? map['access_token'];
      if (token != null && token.toString().isNotEmpty) {
        await TokenStorage.saveToken(token.toString());
        LoggerService.success('JWT token saved');
      }

      // Persist user identity
      final userId = map['user_id'];
      final role = map['role'] ?? 'PATIENT';
      final phone = map['phone_number'] ?? phoneNumber;
      if (userId != null) {
        await TokenStorage.saveUserData(
          userId: userId.toString(),
          role: role.toString(),
          phoneNumber: phone.toString(),
        );
        LoggerService.success('User data saved: $userId role=$role');
      }

      _pendingVerificationId = '';
      LoggerService.success('OTP verification successful');
      return Success(map);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('OTP verification failed', msg);
      return Error(msg);
    }
  }

  // ── Legacy alias kept for existing call-sites ─────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> login({
    required String phoneNumber,
  }) => sendOtp(phoneNumber: phoneNumber);

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<ApiResult<void>> logout() async {
    try {
      LoggerService.info('Logging out');
      await TokenStorage.clearAll();
      _pendingVerificationId = '';
      LoggerService.success('Logout successful');
      return Success(null);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Logout failed', msg);
      return Error(msg);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async => TokenStorage.getToken();
}
