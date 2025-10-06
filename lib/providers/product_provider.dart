import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart' as models;
import '../services/api_service.dart';
import '../utils/image_helper.dart';

class ProductProvider with ChangeNotifier {
  List<models.Category> _categories = [];
  final List<models.Product> _favorites = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isLoading = true;
  bool _hasInternetConnection = true;
  String _dataSource = 'local'; // 'local', 'online', or 'hybrid'

  // GitHub raw URL for your hosted online_products.json
  static const String _onlineDataUrl =
      'https://raw.githubusercontent.com/SyntaxIDK/TechBuy-flutter/main/assets/data/online_products.json';

  List<models.Category> get categories => _categories;
  List<models.Product> get favorites => _favorites;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<models.Product> get allProducts {
    return _categories.expand((category) => category.products).toList();
  }

  List<models.Product> get featuredProducts {
    return allProducts.where((product) => product.featured).toList();
  }

  List<models.Product> get filteredProducts {
    var products = _selectedCategory.isEmpty
        ? allProducts
        : _categories
            .firstWhere((cat) => cat.id == _selectedCategory)
            .products;

    if (_searchQuery.isNotEmpty) {
      products = products
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.brand.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return products;
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        _hasInternetConnection = true;
      } else {
        _hasInternetConnection = false;
      }

      // Load data from the appropriate source
      if (_hasInternetConnection && _dataSource == 'online') {
        // Load from online URL
        final response = await http.get(Uri.parse(_onlineDataUrl));
        final data = json.decode(response.body);

        _categories = (data['categories'] as List)
            .map((category) => models.Category.fromJson(category))
            .toList();
      } else if (_dataSource == 'local') {
        // Load from local assets
        final String response =
            await rootBundle.loadString('assets/data/products.json');
        final data = json.decode(response);

        _categories = (data['categories'] as List)
            .map((category) => models.Category.fromJson(category))
            .toList();
      } else if (_dataSource == 'hybrid') {
        // Load from both local and online, prioritizing online
        try {
          final response = await http.get(Uri.parse(_onlineDataUrl));
          final data = json.decode(response.body);

          _categories = (data['categories'] as List)
              .map((category) => models.Category.fromJson(category))
              .toList();
        } catch (e) {
          // If online load fails, fallback to local
          final String response =
              await rootBundle.loadString('assets/data/products.json');
          final data = json.decode(response);

          _categories = (data['categories'] as List)
              .map((category) => models.Category.fromJson(category))
              .toList();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void toggleFavorite(models.Product product) {
    if (_favorites.any((fav) => fav.id == product.id)) {
      _favorites.removeWhere((fav) => fav.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(models.Product product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  models.Product? getProductById(String id) {
    try {
      return allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // New methods for handling different data sources

  /// Check internet connectivity status
  Future<bool> checkInternetConnection() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      _hasInternetConnection = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
      return _hasInternetConnection;
    } catch (e) {
      _hasInternetConnection = false;
      return false;
    }
  }

  /// Load products from local JSON file only
  Future<void> loadLocalProducts() async {
    try {
      _isLoading = true;
      _dataSource = 'local';
      notifyListeners();

      final String response =
          await rootBundle.loadString('assets/data/products.json');
      final data = json.decode(response);

      _categories = (data['categories'] as List)
          .map((category) => models.Category.fromJson(category))
          .toList();

      _isLoading = false;
      notifyListeners();
      debugPrint('Loaded ${_categories.length} categories from local file');
    } catch (e) {
      debugPrint('Error loading local products: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load products from online JSON URL
  Future<void> loadOnlineProducts({String? customUrl}) async {
    try {
      _isLoading = true;
      _dataSource = 'online';
      notifyListeners();

      // Check internet connection first
      if (!await checkInternetConnection()) {
        throw Exception('No internet connection available');
      }

      // Use the provided custom URL, or default to your GitHub hosted file
      final url = customUrl ?? _onlineDataUrl;

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response has the expected structure
        if (data['categories'] != null) {
          _categories = (data['categories'] as List)
              .map((category) => models.Category.fromJson(category))
              .toList();
        } else {
          throw Exception('Invalid JSON structure: missing categories');
        }

        _isLoading = false;
        notifyListeners();
        debugPrint('Loaded ${_categories.length} categories from GitHub: $url');
      } else {
        throw Exception('Failed to load online data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading online products: $e');
      // Fallback to local data
      await loadLocalProducts();
    }
  }

  /// Load products using hybrid approach (online first, then local fallback)
  Future<void> loadHybridProducts() async {
    try {
      _isLoading = true;
      _dataSource = 'hybrid';
      notifyListeners();

      // First try to load from online
      if (await checkInternetConnection()) {
        try {
          final response = await http.get(
            Uri.parse(_onlineDataUrl),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final onlineData = json.decode(response.body);
            List<models.Category> onlineCategories = (onlineData['categories'] as List)
                .map((category) => models.Category.fromJson(category))
                .toList();

            // Load local data as well
            final String localResponse =
                await rootBundle.loadString('assets/data/products.json');
            final localData = json.decode(localResponse);
            List<models.Category> localCategories = (localData['categories'] as List)
                .map((category) => models.Category.fromJson(category))
                .toList();

            // Merge categories (online takes priority, but we keep local ones not found online)
            _categories = _mergeCategories(localCategories, onlineCategories);

            _isLoading = false;
            notifyListeners();
            debugPrint('Loaded hybrid data: ${_categories.length} categories');
            return;
          }
        } catch (e) {
          debugPrint('Online loading failed, falling back to local: $e');
        }
      }

      // Fallback to local only
      await loadLocalProducts();
    } catch (e) {
      debugPrint('Error in hybrid loading: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Merge local and online categories, giving priority to online data
  List<models.Category> _mergeCategories(
      List<models.Category> local, List<models.Category> online) {
    Map<String, models.Category> merged = {};

    // Add all local categories first
    for (var category in local) {
      merged[category.id] = category;
    }

    // Override with online categories and add new ones
    for (var category in online) {
      if (merged.containsKey(category.id)) {
        // Merge products within the category
        var localCategory = merged[category.id]!;
        var mergedProducts = <models.Product>[];

        // Add local products
        mergedProducts.addAll(localCategory.products);

        // Add online products (replace if same ID)
        for (var onlineProduct in category.products) {
          mergedProducts.removeWhere((p) => p.id == onlineProduct.id);
          mergedProducts.add(onlineProduct);
        }

        merged[category.id] = models.Category(
          id: category.id,
          name: category.name,
          icon: category.icon,
          products: mergedProducts,
        );
      } else {
        merged[category.id] = category;
      }
    }

    return merged.values.toList();
  }

  /// Get current data source
  String get dataSource => _dataSource;

  /// Get internet connection status
  bool get hasInternetConnection => _hasInternetConnection;

  /// Refresh data from current source
  Future<void> refreshData() async {
    switch (_dataSource) {
      case 'local':
        await loadLocalProducts();
        break;
      case 'online':
        await loadOnlineProducts();
        break;
      case 'hybrid':
        await loadHybridProducts();
        break;
      case 'api':
        await loadApiProducts();
        break;
      default:
        await loadProducts();
    }
  }

  /// Load products from Laravel API
  Future<void> loadApiProducts() async {
    try {
      _isLoading = true;
      _dataSource = 'api';
      notifyListeners();

      debugPrint('Starting Laravel API product loading...');

      // Check internet connection first
      if (!await checkInternetConnection()) {
        throw Exception('No internet connection available');
      }

      // Check if Laravel API is available
      if (!await ApiService.checkApiHealth()) {
        throw Exception('Laravel API is not available');
      }

      debugPrint('Laravel API health check passed, fetching data...');

      // Fetch products from Laravel API
      final productsData = await ApiService.fetchProducts(perPage: 100);
      debugPrint('Fetched products data: ${productsData['data']?.length ?? 0} products');

      List<models.Category> apiCategories = [];
      Map<String, List<models.Product>> categoryProducts = {};

      // Convert Laravel products to our app's format
      if (productsData['data'] != null) {
        for (var productJson in productsData['data']) {
          try {
            final product = _convertLaravelProductToAppProduct(productJson);
            // Get category slug from the product's category object
            final categorySlug = productJson['category']?['slug'] ?? 'uncategorized';

            if (!categoryProducts.containsKey(categorySlug)) {
              categoryProducts[categorySlug] = [];
            }
            categoryProducts[categorySlug]!.add(product);
            debugPrint('Converted product: ${product.name} to category: $categorySlug');
          } catch (e) {
            debugPrint('Error converting product: $e');
            debugPrint('Product data: $productJson');
            // Continue with other products instead of failing completely
            continue;
          }
        }
      }

      debugPrint('Processed ${categoryProducts.length} product categories');
      debugPrint('Category-Product mapping: ${categoryProducts.keys.toList()}');

      // Try to fetch categories, but if it fails, create them from products
      try {
        final categoriesData = await ApiService.fetchCategories();
        debugPrint('Fetched ${categoriesData.length} categories from Laravel API');

        if (categoriesData.isNotEmpty) {
          // Create categories with their products using API data
          for (var categoryJson in categoriesData) {
            final categorySlug = categoryJson['slug'];
            final categoryName = categoryJson['name'];
            final products = categoryProducts[categorySlug] ?? [];

            apiCategories.add(models.Category(
              id: categorySlug,
              name: categoryName,
              icon: _getCategoryIcon(categorySlug),
              products: products,
            ));

            debugPrint('Created category: $categoryName with ${products.length} products');
          }
        } else {
          throw Exception('Categories endpoint returned empty data');
        }
      } catch (e) {
        debugPrint('Categories endpoint failed: $e');
        debugPrint('Creating categories from products instead...');

        // Create categories directly from the products since categories endpoint failed
        for (var entry in categoryProducts.entries) {
          final slug = entry.key;
          final products = entry.value;

          // Get category info from the first product in this category
          final categoryName = products.isNotEmpty && products.first.id.contains('api-')
              ? _getCategoryNameFromSlug(slug)
              : slug;

          apiCategories.add(models.Category(
            id: slug,
            name: categoryName,
            icon: _getCategoryIcon(slug),
            products: products,
          ));

          debugPrint('Created category from products: $categoryName with ${products.length} products');
        }
      }

      _categories = apiCategories;
      _isLoading = false;
      notifyListeners();
      debugPrint('Successfully loaded ${_categories.length} categories from Laravel API');
      debugPrint('Total products across all categories: ${_categories.expand((c) => c.products).length}');

    } catch (e) {
      debugPrint('Error loading API products: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      // Show error to user instead of silently falling back
      _isLoading = false;
      notifyListeners();

      // Don't fallback automatically - let user know what happened
      rethrow;
    }
  }

  /// Convert Laravel API product format to our app's Product model
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

    // Convert specifications from Laravel format - handle both array and map
    Map<String, dynamic> specs = {};
    if (laravelProduct['specifications'] != null) {
      final specificationsData = laravelProduct['specifications'];
      if (specificationsData is Map<String, dynamic>) {
        specs = Map<String, dynamic>.from(specificationsData);
      } else if (specificationsData is List && specificationsData.isNotEmpty) {
        // If it's a list, try to convert it to a map
        for (var item in specificationsData) {
          if (item is Map<String, dynamic>) {
            specs.addAll(item);
          }
        }
      }
      // If it's an empty array or null, specs remains empty
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

  /// Get appropriate icon for category based on slug
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

  /// Check if Laravel API is available
  Future<bool> checkApiAvailability() async {
    try {
      return await ApiService.checkApiHealth();
    } catch (e) {
      return false;
    }
  }

  /// Get category name from slug (for uncategorized products)
  String _getCategoryNameFromSlug(String slug) {
    switch (slug.toLowerCase()) {
      case 'iphones':
        return 'iPhones';
      case 'macbooks':
        return 'MacBooks';
      case 'android-phones':
        return 'Android Phones';
      case 'laptops':
        return 'Laptops';
      case 'tablets':
        return 'Tablets';
      case 'accessories':
        return 'Accessories';
      case 'monitors':
        return 'Monitors';
      case 'gaming':
        return 'Gaming';
      default:
        // Convert slug to a more readable format
        return slug
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
    }
  }
}
