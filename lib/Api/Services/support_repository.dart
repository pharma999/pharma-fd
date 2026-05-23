import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Model/support_model.dart';

class SupportRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResult<List<SupportTicket>>> getMyTickets() async {
    try {
      final res = await _client.get(ApiEndpoints.myTickets, requiresAuth: true);
      final data = res['data'] as List<dynamic>? ?? [];
      return Success(data.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<ApiResult<SupportTicket>> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'MEDIUM',
    String? referenceId,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
        if (referenceId != null && referenceId.isNotEmpty) 'reference_id': referenceId,
      };
      final res = await _client.post(ApiEndpoints.createTicket, body, requiresAuth: true);
      final data = res['data'] as Map<String, dynamic>? ?? res as Map<String, dynamic>;
      return Success(SupportTicket.fromJson(data));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }
}
