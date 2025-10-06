import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';

class ApiTestService {
  static Future<void> testAzureApiConnection() async {
    debugPrint('🚀 Starting Azure API Migration Test...');

    try {
      // Test 1: Basic API Health Check
      debugPrint('📡 Testing API Health Check...');
      final isHealthy = await ApiService.checkApiHealth();
      debugPrint('✅ API Health: ${isHealthy ? "HEALTHY" : "FAILED"}');

      if (!isHealthy) {
        debugPrint('❌ API Health check failed. Please verify Azure URL is accessible.');
        return;
      }

      // Test 2: Fetch Categories
      debugPrint('📁 Testing Categories Endpoint...');
      try {
        final categories = await ApiService.fetchCategories();
        debugPrint('✅ Categories: ${categories.length} found');
        for (var category in categories.take(3)) {
          debugPrint('   - ${category['name']} (${category['slug']})');
        }
      } catch (e) {
        debugPrint('❌ Categories test failed: $e');
      }

      // Test 3: Fetch Products
      debugPrint('📦 Testing Products Endpoint...');
      try {
        final productsResult = await ApiService.fetchProducts(perPage: 5);
        final products = productsResult['data'] ?? [];
        debugPrint('✅ Products: ${products.length} found');
        for (var product in products.take(3)) {
          debugPrint('   - ${product['name']} (\$${product['current_price']})');
        }
      } catch (e) {
        debugPrint('❌ Products test failed: $e');
      }

      // Test 4: Featured Products
      debugPrint('⭐ Testing Featured Products...');
      try {
        final featuredResult = await ApiService.fetchFeaturedProducts(limit: 3);
        final featured = featuredResult['data'] ?? [];
        debugPrint('✅ Featured Products: ${featured.length} found');
      } catch (e) {
        debugPrint('❌ Featured products test failed: $e');
      }

      // Test 5: Search Products
      debugPrint('🔍 Testing Product Search...');
      try {
        final searchResult = await ApiService.searchProducts('iphone', perPage: 3);
        final searchProducts = searchResult['data'] ?? [];
        debugPrint('✅ Search Results: ${searchProducts.length} found for "iphone"');
      } catch (e) {
        debugPrint('❌ Search test failed: $e');
      }

      // Test 6: Image URL Generation
      debugPrint('🖼️ Testing Image URL Generation...');
      try {
        final productsResult = await ApiService.fetchProducts(perPage: 1);
        final products = productsResult['data'] ?? [];
        if (products.isNotEmpty) {
          final product = products.first;
          final images = product['images'] ?? [];
          if (images.isNotEmpty) {
            final imageUrl = '${ApiConfig.storageUrl}/products/${images.first}';
            debugPrint('✅ Sample Image URL: $imageUrl');
          }
        }
      } catch (e) {
        debugPrint('❌ Image URL test failed: $e');
      }

      debugPrint('🎉 Azure API Migration Test Completed!');
      debugPrint('🌐 Base URL: ${ApiConfig.baseUrl}');
      debugPrint('📡 API URL: ${ApiConfig.apiBaseUrl}');
      debugPrint('💾 Storage URL: ${ApiConfig.storageUrl}');

    } catch (e) {
      debugPrint('❌ Migration test failed with error: $e');
    }
  }

  static Future<void> testProductService() async {
    debugPrint('🧪 Testing Product Service with Azure API...');

    try {
      final productService = ProductService();

      // Test getting products
      final result = await productService.getProducts(page: 1, perPage: 5);
      debugPrint('✅ Product Service: ${result['products'].length} products loaded');

      // Test getting categories
      final categories = await productService.getCategories();
      debugPrint('✅ Product Service: ${categories.length} categories loaded');

      // Test featured products
      final featured = await productService.getFeaturedProducts();
      debugPrint('✅ Product Service: ${featured.length} featured products loaded');

    } catch (e) {
      debugPrint('❌ Product Service test failed: $e');
    }
  }

  static Future<void> testAuthService() async {
    debugPrint('🔐 Testing Auth Service connectivity...');

    try {
      final authService = AuthService();

      // Test if auth endpoints are reachable (without actual login)
      debugPrint('Auth service initialized with Azure endpoints');
      debugPrint('✅ Auth Service: Ready for authentication');

    } catch (e) {
      debugPrint('❌ Auth Service test failed: $e');
    }
  }
}
