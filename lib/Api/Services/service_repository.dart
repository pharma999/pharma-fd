import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/service_model.dart';

class ServiceRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<List<ServiceCategory>>> getCategories() async {
    try {
      final response = await _client.get(
        ApiEndpoints.serviceCategories,
        requiresAuth: false,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      final categories =
          data.map((e) => ServiceCategory.fromJson(e)).toList();
      return Success(categories);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ServiceModel>>> getAllServices() async {
    try {
      final response = await _client.get(
        ApiEndpoints.allServices,
        requiresAuth: false,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => ServiceModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ServiceModel>>> getCategoryServices(
      String categoryId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.categoryServices(categoryId),
        requiresAuth: false,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => ServiceModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<ServiceModel>> getServiceDetail(String serviceId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.serviceDetail(serviceId),
        requiresAuth: false,
      );
      return Success(ServiceModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ProfessionalModel>>> getProfessionals(
      String serviceId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.serviceProfessionals(serviceId),
        requiresAuth: false,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => ProfessionalModel.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<CartItem>>> getCart() async {
    try {
      final response = await _client.get(
        ApiEndpoints.cart,
        requiresAuth: true,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => CartItem.fromJson(e)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<CartItem>> addToCart({
    required String serviceId,
    required int quantity,
    String? professionalId,
    String? scheduledAt,
  }) async {
    try {
      final body = <String, dynamic>{
        'service_id': serviceId,
        'quantity': quantity,
      };
      if (professionalId != null) body['professional_id'] = professionalId;
      if (scheduledAt != null) body['scheduled_at'] = scheduledAt;

      final response = await _client.post(
        ApiEndpoints.addToCart,
        body,
        requiresAuth: true,
      );
      return Success(CartItem.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> updateCartQuantity(
      String itemId, int quantity) async {
    try {
      await _client.post(
        ApiEndpoints.updateCartQuantity,
        {'item_id': itemId, 'quantity': quantity},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> removeFromCart(String serviceId) async {
    try {
      await _client.delete(
        ApiEndpoints.removeCartItem(serviceId),
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> clearCart() async {
    try {
      // Backend: DELETE /cart
      await _client.delete(ApiEndpoints.cart, requiresAuth: true);
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> checkoutCart({
    required String address,
    required String scheduledAt,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'address': address,
        'scheduled_at': scheduledAt,
      };
      if (notes != null) body['notes'] = notes;

      final response = await _client.post(
        ApiEndpoints.checkoutCart,
        body,
        requiresAuth: true,
      );
      return Success(response['data']);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<void>> submitReview({
    required String professionalId,
    required double rating,
    required String comment,
  }) async {
    try {
      LoggerService.info('Submitting review for professional: $professionalId');
      // Backend: POST /reviews  (professional_id in body)
      await _client.post(
        ApiEndpoints.submitReview,
        {'professional_id': professionalId, 'rating': rating, 'comment': comment},
        requiresAuth: true,
      );
      return const Success(null);
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
