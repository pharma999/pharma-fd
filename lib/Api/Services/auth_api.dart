import '../core/api_client.dart';
import '../config/api_endpoints.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    return await _client.post(ApiEndpoints.login, body);
  }

  /// ✅ VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> body) async {
    return await _client.post(ApiEndpoints.verify, body);
  }
}
