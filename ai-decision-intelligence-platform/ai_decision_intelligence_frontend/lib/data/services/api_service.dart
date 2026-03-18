import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  dynamic jsonDecode(String body) {
    return json.decode(body);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<Map<String, String>> _getHeaders(String contentType) async {
    final token = await getToken();
    return {
      "Content-Type": contentType,
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _getHeaders("application/json"),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {String contentType = "application/json"}) async {
    Map<String, String> headers = await _getHeaders(contentType);
    dynamic body;

    if (contentType == "application/json") {
      body = jsonEncode(data);
    } else if (contentType == "application/x-www-form-urlencoded") {
      body = data.keys.map((key) => '$key=${Uri.encodeQueryComponent(data[key].toString())}').join('&');
    } else {
      body = data;
    }

    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _getHeaders("application/json"),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
