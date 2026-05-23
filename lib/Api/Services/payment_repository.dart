import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Model/payment_model.dart';

class PaymentRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<List<PaymentModel>>> getHistory() async {
    try {
      final res = await _client.get(ApiEndpoints.paymentHistory, requiresAuth: true);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<PaymentModel>> initiate({
    required double amount,
    required String paymentMethod,
    String? bookingId,
    String? appointmentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'payment_method': paymentMethod,
        if (bookingId != null) 'booking_id': bookingId,
        if (appointmentId != null) 'appointment_id': appointmentId,
      };
      final res = await _client.post(ApiEndpoints.initiatePayment, body, requiresAuth: true);
      final data = res['data'] as Map<String, dynamic>? ?? res as Map<String, dynamic>;
      return Success(PaymentModel.fromJson(data));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<PaymentModel>> confirm({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.confirmPayment(paymentId),
        {'transaction_id': transactionId},
        requiresAuth: true,
      );
      final data = res['data'] as Map<String, dynamic>? ?? res as Map<String, dynamic>;
      return Success(PaymentModel.fromJson(data));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
