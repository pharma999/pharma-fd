import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';

class WalletRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<Map<String, dynamic>>> getBalance() async {
    try {
      final res = await _client.get(ApiEndpoints.walletBalance, requiresAuth: true);
      return Success(Map<String, dynamic>.from(res['data'] ?? res));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> topUp({
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
      };
      final res = await _client.post(ApiEndpoints.walletTopUp, body, requiresAuth: true);
      return Success(Map<String, dynamic>.from(res['data'] ?? res));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> pay({
    required double amount,
    String? bookingId,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        if (bookingId != null) 'booking_id': bookingId,
        if (description != null) 'description': description,
      };
      final res = await _client.post(ApiEndpoints.walletPay, body, requiresAuth: true);
      return Success(Map<String, dynamic>.from(res['data'] ?? res));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getTransactions() async {
    try {
      final res = await _client.get(ApiEndpoints.walletTransactions, requiresAuth: true);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.cast<Map<String, dynamic>>());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> validatePromo({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final res = await _client.post(ApiEndpoints.validatePromo,
          {'code': code, 'order_amount': orderAmount},
          requiresAuth: true);
      return Success(Map<String, dynamic>.from(res['data'] ?? res));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getBookingTracking(String bookingId) async {
    try {
      final res = await _client.get(
          ApiEndpoints.bookingTracking(bookingId), requiresAuth: true);
      return Success(Map<String, dynamic>.from(res['data'] ?? res));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> raiseDispute({
    required String bookingId,
    required String description,
  }) async {
    try {
      await _client.post(ApiEndpoints.raiseDispute,
          {'booking_id': bookingId, 'description': description},
          requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
