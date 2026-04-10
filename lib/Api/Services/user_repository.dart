import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Model/user_detail_model.dart';

/// User Repository - Handles all user-related API calls
class UserRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch user profile from server
  Future<ApiResult<UserDetail>> getUserProfile({required String userId}) async {
    try {
      LoggerService.info('Fetching user profile for: $userId');

      final response = await _apiClient.get('user/$userId', requiresAuth: true);

      final userDetail = UserDetail.fromJson(response as Map<String, dynamic>);
      LoggerService.success('User profile fetched successfully');
      return Success(userDetail);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Failed to fetch user profile', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Update user profile
  Future<ApiResult<UserDetail>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      LoggerService.info('Updating user profile for: $userId');

      final response = await _apiClient.post(
        'user/$userId/update',
        data,
        requiresAuth: true,
      );

      final userDetail = UserDetail.fromJson(response as Map<String, dynamic>);
      LoggerService.success('User profile updated successfully');
      return Success(userDetail);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Failed to update user profile', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Update user address
  Future<ApiResult<UserDetail>> updateUserAddress({
    required String userId,
    required String addressType, // 'address1' or 'address2'
    required Map<String, dynamic> addressData,
  }) async {
    try {
      LoggerService.info('Updating $addressType for: $userId');

      final response = await _apiClient.post('user/$userId/address/update', {
        'addressType': addressType,
        ...addressData,
      }, requiresAuth: true);

      final userDetail = UserDetail.fromJson(response as Map<String, dynamic>);
      LoggerService.success('User address updated successfully');
      return Success(userDetail);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Failed to update user address', errorMessage);
      return Error(errorMessage);
    }
  }

  /// Delete user account
  Future<ApiResult<void>> deleteAccount({required String userId}) async {
    try {
      LoggerService.info('Deleting account for: $userId');

      await _apiClient.post('user/$userId/delete', {
        'userId': userId,
      }, requiresAuth: true);

      LoggerService.success('Account deleted successfully');
      return Success(null);
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Failed to delete account', errorMessage);
      return Error(errorMessage);
    }
  }
}
