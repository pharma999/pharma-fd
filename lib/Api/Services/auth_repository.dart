import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/utils/token_storage.dart';
import '../config/api_endpoints.dart';

/// Authentication Repository - Handles all auth API calls
class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Login with phone number
  Future<ApiResult<Map<String, dynamic>>> login({
    required String phoneNumber,
  }) async {
    try {
      LoggerService.info('Attempting login with phone: $phoneNumber');

      final response = await _apiClient.post(ApiEndpoints.login, {
        'phone_number': phoneNumber,
      }, requiresAuth: false);

      LoggerService.success('Login successful');
      return Success(response as Map<String, dynamic>);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Login failed', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Verify OTP
  Future<ApiResult<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      LoggerService.info('Attempting OTP verification for: $phoneNumber');

      final response = await _apiClient.post(ApiEndpoints.verify, {
        'phone_number': phoneNumber,
        'otp': otp,
      }, requiresAuth: false);

      // Save token from response
      final token = response['token'] ?? response['access_token'];
      if (token != null) {
        await TokenStorage.saveToken(token);
        LoggerService.success('Token saved successfully');
      }

      LoggerService.success('OTP verification successful');
      return Success(response as Map<String, dynamic>);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('OTP verification failed', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Logout - clear stored token
  Future<ApiResult<void>> logout() async {
    try {
      LoggerService.info('Logging out');
      await TokenStorage.clearToken();
      LoggerService.success('Logout successful');
      return Success(null);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Logout failed', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current token
  Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }
}
