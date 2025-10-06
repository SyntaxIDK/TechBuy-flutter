import 'dart:convert';
import '../models/product.dart' as models;
import '../config/api_config.dart';
import '../services/http_service.dart';
import '../utils/image_helper.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  final HttpService _httpService = HttpService();

  // Fetch products with pagination
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    int? categoryId,
  }) async {
    try {
      String endpoint = '${ApiConfig.products}?page=$page&per_page=$perPage';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }

      if (categoryId != null) {
        endpoint += '&category_id=$categoryId';
      }

      final response = await _httpService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Convert Laravel products to our app's Product model
        final products = (data['data'] as List)
            .map((json) => _convertLaravelProductToAppProduct(json))
            .toList();

        return {
          'products': products,
          'pagination': data['pagination'],
          'links': data['links'],
          'meta': data['meta'],
        };
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch single product
  Future<models.Product> getProduct(int id) async {
    try {
      final response = await _httpService.get('${ApiConfig.products}/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _convertLaravelProductToAppProduct(data['data']);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw Exception('Error fetching product: $e');
    }
  }

  // Fetch featured products
  Future<List<models.Product>> getFeaturedProducts() async {
    try {
      final response = await _httpService.get('${ApiConfig.products}/featured');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => _convertLaravelProductToAppProduct(json))
            .toList();
      } else {
        throw Exception('Failed to load featured products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      throw Exception('Error fetching featured products: $e');
    }
  }

  // Search products
  Future<List<models.Product>> searchProducts(String query) async {
    try {
      final response = await _httpService.get('${ApiConfig.products}/search?q=$query');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => _convertLaravelProductToAppProduct(json))
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      throw Exception('Error searching products: $e');
    }
  }

  // Fetch categories
  Future<List<models.Category>> getCategories() async {
    try {
      final response = await _httpService.get(ApiConfig.categories);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => _convertLaravelCategoryToAppCategory(json))
            .toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  // Get products by category
  Future<List<models.Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _httpService.get('${ApiConfig.products}/category/$categoryId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => _convertLaravelProductToAppProduct(json))
            .toList();
      } else {
        throw Exception('Failed to load category products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching category products: $e');
      throw Exception('Error fetching category products: $e');
    }
  }

  // Convert Laravel product to app Product model
  models.Product _convertLaravelProductToAppProduct(Map<String, dynamic> laravelProduct) {
    // Extract images - Laravel returns array of image URLs
    List<String> images = [];
    if (laravelProduct['images'] != null) {
      images = List<String>.from(laravelProduct['images']);
    }

    // Use Azure image URL with proper path handling
    String imageUrl = images.isNotEmpty
        ? ImageHelper.getProductImageUrl(images.first)
        : 'assets/images/placeholder.jpg';

    // Convert specifications from Laravel format
    Map<String, dynamic> specs = {};
    if (laravelProduct['specifications'] != null) {
      specs = Map<String, dynamic>.from(laravelProduct['specifications']);
    }

    // Add additional specs from Laravel product data
    specs.addAll({
      'sku': laravelProduct['sku'] ?? 'N/A',
      'stock': '${laravelProduct['stock_quantity'] ?? 0} units available',
      'weight': laravelProduct['weight'] ?? 'N/A',
      'dimensions': laravelProduct['dimensions'] ?? 'N/A',
      'model': laravelProduct['model'] ?? 'N/A',
    });

    // Fix the type casting issues
    final productId = laravelProduct['id'] ?? 0;
    final reviewCount = 50 + (productId is int ? productId : (productId as num).toInt()) * 5;

    return models.Product(
      id: 'api-${laravelProduct['id']}',
      name: laravelProduct['name'] ?? 'Unknown Product',
      brand: laravelProduct['brand'] ?? 'Unknown Brand',
      price: (laravelProduct['current_price'] ?? laravelProduct['price'] ?? 0).toDouble(),
      originalPrice: (laravelProduct['price'] ?? 0).toDouble(),
      image: imageUrl,
      rating: 4.0 + (productId % 10) / 10, // Generate rating from ID
      reviews: reviewCount, // Fixed type casting
      description: laravelProduct['description'] ?? laravelProduct['short_description'] ?? 'No description available',
      specifications: specs.map((key, value) => MapEntry(key, value.toString())), // Convert all values to String
      colors: ['Black', 'White'], // Default colors since Laravel API might not have this
      inStock: laravelProduct['in_stock'] ?? (laravelProduct['stock_quantity'] ?? 0) > 0,
      featured: laravelProduct['is_on_sale'] ?? false, // Mark sale items as featured
    );
  }

  // Convert Laravel category to app Category model
  models.Category _convertLaravelCategoryToAppCategory(Map<String, dynamic> laravelCategory) {
    return models.Category(
      id: 'api-${laravelCategory['id']}',
      name: laravelCategory['name'] ?? 'Unknown Category',
      icon: _getCategoryIcon(laravelCategory['slug'] ?? ''),
      products: [], // Products will be loaded separately
    );
  }

  // Get appropriate icon for category based on slug
  String _getCategoryIcon(String categorySlug) {
    switch (categorySlug.toLowerCase()) {
      case 'iphones':
      case 'phones':
      case 'smartphones':
        return 'phone_iphone';
      case 'macbooks':
      case 'laptops':
      case 'computers':
        return 'laptop_mac';
      case 'tablets':
      case 'ipads':
        return 'tablet_mac';
      case 'accessories':
      case 'headphones':
        return 'headset';
      case 'monitors':
      case 'displays':
        return 'monitor';
      case 'gaming':
        return 'sports_esports';
      default:
        return 'category';
    }
  }
}
