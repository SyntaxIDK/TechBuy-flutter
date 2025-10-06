import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiService {
  // Using Azure production URL instead of localhost
  static String get baseUrl => ApiConfig.apiBaseUrl;

  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Generic GET request method for Map responses
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('API Request: GET $baseUrl$endpoint');
      debugPrint('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: Success - ${data.toString().substring(0, 100)}...');

        // Ensure we return a Map, even if the API returns an array
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          // If it's an array, wrap it in a map
          return {'data': data};
        }
      } else {
        debugPrint('API Response: Error - ${response.body}');
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('API Request Failed: $e');
      rethrow;
    }
  }

  /// Generic GET request method for List responses
  static Future<List<dynamic>> getList(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('API Request: GET $baseUrl$endpoint');
      debugPrint('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: Success - ${data.toString().substring(0, 100)}...');

        // Return as list
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else {
          throw Exception('Expected array response but got: ${data.runtimeType}');
        }
      } else {
        debugPrint('API Response: Error - ${response.body}');
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('API Request Failed: $e');
      rethrow;
    }
  }

  /// Fetch all products with optional parameters
  static Future<Map<String, dynamic>> fetchProducts({
    int page = 1,
    String? search,
    String? category,
    int perPage = 15,
    String? sortBy,
    String? sortDirection,
  }) async {
    String endpoint = '/products?page=$page&per_page=$perPage';

    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }

    if (category != null && category.isNotEmpty) {
      endpoint += '&category=$category';
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      endpoint += '&sort_by=$sortBy';
    }

    if (sortDirection != null && sortDirection.isNotEmpty) {
      endpoint += '&sort_direction=$sortDirection';
    }

    return await get(endpoint);
  }

  /// Fetch featured products (on sale)
  static Future<Map<String, dynamic>> fetchFeaturedProducts({int limit = 10}) async {
    return await get('/products/featured?limit=$limit');
  }

  /// Fetch all categories
  static Future<List<dynamic>> fetchCategories() async {
    return await getList('/categories');
  }

  /// Fetch products by category
  static Future<Map<String, dynamic>> fetchProductsByCategory(
    String categorySlug, {
    int page = 1,
    int perPage = 15,
    String? sortBy,
    String? sortDirection,
  }) async {
    String endpoint = '/categories/$categorySlug/products?page=$page&per_page=$perPage';

    if (sortBy != null && sortBy.isNotEmpty) {
      endpoint += '&sort_by=$sortBy';
    }

    if (sortDirection != null && sortDirection.isNotEmpty) {
      endpoint += '&sort_direction=$sortDirection';
    }

    return await get(endpoint);
  }

  /// Search products
  static Future<Map<String, dynamic>> searchProducts(
    String query, {
    int page = 1,
    int perPage = 15,
  }) async {
    if (query.isEmpty) {
      throw Exception('Search query is required');
    }

    return await get('/products/search?q=${Uri.encodeComponent(query)}&page=$page&per_page=$perPage');
  }

  /// Get single product by ID
  static Future<Map<String, dynamic>> fetchProduct(int id) async {
    return await get('/products/$id');
  }

  /// Check if Laravel API is available
  static Future<bool> checkApiHealth() async {
    try {
      debugPrint('Checking API health at: $baseUrl/categories');
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      ).timeout(const Duration(seconds: 10)); // Increased timeout for Azure

      debugPrint('Health check response: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Azure Laravel API is healthy');
        return true;
      } else {
        debugPrint('Azure Laravel API returned status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Azure Laravel API health check failed: $e');
      return false;
    }
  }
}
