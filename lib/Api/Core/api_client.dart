import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../core/api_exception.dart';
import '../../Helper/logger_service.dart';
import '../../Helper/exception_handler.dart';
import '../../utils/token_storage.dart';

/// Enhanced API Client with better error handling and token management
class ApiClient {
  // Private constructor for singleton pattern
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  /// Make POST request with token-aware headers
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

      LoggerService.info('POST $endpoint');
      LoggerService.debug('Request body: ${jsonEncode(data)}');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(data))
          .timeout(
            const Duration(seconds: ApiConfig.timeout),
            onTimeout: () => throw TimeoutException(
              'Request timeout after ${ApiConfig.timeout}s',
            ),
          );

      LoggerService.debug('Status code: ${response.statusCode}');
      LoggerService.debug('Response body: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException catch (e) {
      LoggerService.error('Timeout error', e);
      throw ApiException(ExceptionHandler.getErrorMessage(e));
    } catch (e) {
      LoggerService.error('POST request failed', e);
      throw ApiException(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Make GET request with token-aware headers
  Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      Uri uri = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      LoggerService.info('GET $endpoint');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: ApiConfig.timeout),
            onTimeout: () => throw TimeoutException(
              'Request timeout after ${ApiConfig.timeout}s',
            ),
          );

      LoggerService.debug('Status code: ${response.statusCode}');
      return _handleResponse(response);
    } on TimeoutException catch (e) {
      LoggerService.error('Timeout error', e);
      throw ApiException(ExceptionHandler.getErrorMessage(e));
    } catch (e) {
      LoggerService.error('GET request failed', e);
      throw ApiException(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Handle API response and check for errors
  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw ApiException('Empty response from server');
    }

    try {
      final jsonResponse = jsonDecode(response.body);

      // Check for 401 Unauthorized - token expired
      if (response.statusCode == 401) {
        LoggerService.warning('Unauthorized - token expired');
        TokenStorage.clearToken();
        throw ApiException('Session expired. Please login again.');
      }

      // Check for non-2xx status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage =
            jsonResponse['message'] ??
            jsonResponse['error'] ??
            'Error ${response.statusCode}';
        throw ApiException(errorMessage);
      }

      LoggerService.success('Request successful');
      return jsonResponse;
    } on FormatException catch (e) {
      LoggerService.error('Invalid JSON response', e);
      throw ApiException('Invalid response format. Please try again.');
    }
  }

  /// Get headers with auth token if required
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        LoggerService.debug('Added authorization header');
      } else {
        LoggerService.warning('Auth required but no token found');
        throw ApiException(
          'No authentication token found. Please login again.',
        );
      }
    }

    return headers;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
