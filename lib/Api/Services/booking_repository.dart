import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/booking_model.dart';

class BookingRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<BookingModel>> createBooking({
    required String serviceId,
    String? professionalId,
    required String bookingType,
    String? scheduledAt,
    required String patientAddress,
    double? patientLatitude,
    double? patientLongitude,
    String? notes,
  }) async {
    try {
      LoggerService.info('Creating booking for service: $serviceId');
      final body = <String, dynamic>{
        'service_id': serviceId,
        'booking_type': bookingType,
        'patient_address': patientAddress,
      };
      if (professionalId != null) body['professional_id'] = professionalId;
      if (scheduledAt != null) body['scheduled_at'] = scheduledAt;
      if (patientLatitude != null) body['patient_latitude'] = patientLatitude.toString();
      if (patientLongitude != null) body['patient_longitude'] = patientLongitude.toString();
      if (notes != null) body['notes'] = notes;

      final response = await _client.post(
        ApiEndpoints.createBooking,
        body,
        requiresAuth: true,
      );
      return Success(BookingModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<BookingModel>>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) params['status'] = status;

      final response = await _client.get(
        ApiEndpoints.myBookings,
        requiresAuth: true,
        queryParams: params,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => BookingModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<BookingModel>> getBookingDetail(String bookingId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.bookingDetail(bookingId),
        requiresAuth: true,
      );
      return Success(BookingModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> cancelBooking(String bookingId, {String? reason}) async {
    try {
      LoggerService.info('Cancelling booking: $bookingId');
      await _client.post(
        ApiEndpoints.cancelBooking(bookingId),
        {'reason': reason ?? ''},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.initiatePayment,
        {
          'booking_id': bookingId,
          'amount': amount,
          'payment_method': paymentMethod,
        },
        requiresAuth: true,
      );
      return Success(response['data'] as Map<String, dynamic>);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<PaymentModel>> confirmPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.confirmPayment(paymentId),
        {'transaction_id': transactionId},
        requiresAuth: true,
      );
      return Success(PaymentModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<PaymentModel>>> getPaymentHistory() async {
    try {
      final response = await _client.get(
        ApiEndpoints.paymentHistory,
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => PaymentModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
