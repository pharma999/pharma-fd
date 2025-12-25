import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../core/api_exception.dart';

// class ApiClient {
//   Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
//     final uri = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

//     final response = await http.post(
//       uri,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(data),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw ApiException("Error ${response.statusCode}: ${response.body}");
//     }
//   }
// }

class ApiClient {
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RAW BODY: '${response.body}'");

    if (response.body.isEmpty) {
      throw ApiException("Empty response from server");
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException("Error ${response.statusCode}: ${response.body}");
    }
  }
}
