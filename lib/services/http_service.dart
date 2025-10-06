import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      debugPrint('HTTP GET: $url');

      final response = await http.get(url, headers: _headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('HTTP GET Error: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      debugPrint('HTTP POST: $url');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('HTTP POST Error: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      debugPrint('HTTP PUT: $url');

      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('HTTP PUT Error: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      debugPrint('HTTP DELETE: $url');

      final response = await http.delete(url, headers: _headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('HTTP DELETE Error: $e');
      rethrow;
    }
  }
}
