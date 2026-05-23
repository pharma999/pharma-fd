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
        requiresAuth: true,
      );
      LoggerService.debug('getCategories raw: $response');
      final data = _extractList(response, fallbackKeys: ['categories']);
      final categories = data.map((e) => ServiceCategory.fromJson(e)).toList();
      LoggerService.info('Parsed ${categories.length} categories');
      return Success(categories);
    } catch (e) {
      LoggerService.error('getCategories failed', e);
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ServiceModel>>> getAllServices() async {
    try {
      final response = await _client.get(
        ApiEndpoints.allServices,
        requiresAuth: true,
      );
      LoggerService.debug('getAllServices raw: $response');
      final data = _extractList(response, fallbackKeys: ['services']);
      final list = data.map((e) => ServiceModel.fromJson(e)).toList();
      LoggerService.info('Parsed ${list.length} services');
      return Success(list);
    } catch (e) {
      LoggerService.error('getAllServices failed', e);
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ServiceModel>>> getCategoryServices(
      String categoryId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.categoryServices(categoryId),
        requiresAuth: true,
      );
      LoggerService.debug('getCategoryServices raw: $response');
      final data = _extractList(response, fallbackKeys: ['services']);
      return Success(data.map((e) => ServiceModel.fromJson(e)).toList());
    } catch (e) {
      LoggerService.error('getCategoryServices failed', e);
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Extracts a list from the API response, handling multiple shapes:
  /// - `{data: [...]}` — standard wrapper
  /// - `{categories: [...]}` or other named keys
  /// - `[...]` — bare array response
  List<dynamic> _extractList(dynamic response,
      {List<String> fallbackKeys = const []}) {
    if (response is List) return response;
    if (response is Map) {
      if (response['data'] is List) return response['data'] as List;
      for (final key in fallbackKeys) {
        if (response[key] is List) return response[key] as List;
      }
    }
    return [];
  }

  Future<ApiResult<ServiceModel>> getServiceDetail(String serviceId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.serviceDetail(serviceId),
        requiresAuth: true,
      );
      return Success(ServiceModel.fromJson(response['data']));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<List<ProfessionalModel>>> getProfessionals(
      String serviceId, {String? zoneId, bool advertised = false}) async {
    try {
      // Build query: service_name filter + optional zone_id + advertised flag
      final params = <String, String>{};
      if (serviceId.isNotEmpty) params['service_name'] = serviceId;
      if (zoneId != null && zoneId.isNotEmpty) params['zone_id'] = zoneId;
      if (advertised) params['advertised'] = 'true';

      final endpoint = params.isEmpty
          ? 'professionals'
          : 'professionals?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

      final response = await _client.get(endpoint, requiresAuth: true);
      final raw = response is List
          ? response
          : (response['data'] ?? response['professionals'] ?? response['items'] ?? []);
      final data = raw is List ? raw : <dynamic>[];
      return Success(data.map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>)).toList());
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
