import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart' as models;

class ProductProvider with ChangeNotifier {
  List<models.Category> _categories = [];
  final List<models.Product> _favorites = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isLoading = true;
  bool _hasInternetConnection = true;
  String _dataSource = 'local'; // 'local', 'online', or 'hybrid'

  // For demonstration, we'll use a working JSON API endpoint
  // You can replace this with your own GitHub raw URL once you set it up
  static const String _onlineDataUrl =
      'https://jsonplaceholder.typicode.com/posts/1'; // This will work for testing

  // Alternative: Use a working GitHub example (this is a real working URL for demo)
  static const String _demoGitHubUrl =
      'https://raw.githubusercontent.com/flutter/samples/main/web/samples_index.json';

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

      // For demonstration purposes, if no custom URL is provided,
      // we'll load the online_products.json file to simulate online data
      if (customUrl == null || customUrl.isEmpty) {
        // Simulate online loading with the demo online_products.json
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

        final String response =
            await rootBundle.loadString('assets/data/online_products.json');
        final data = json.decode(response);

        _categories = (data['categories'] as List)
            .map((category) => models.Category.fromJson(category))
            .toList();

        _isLoading = false;
        notifyListeners();
        debugPrint('Loaded ${_categories.length} categories from simulated online source (online_products.json)');
        return;
      }

      // If a custom URL is provided, try to fetch from the actual URL
      final response = await http.get(
        Uri.parse(customUrl),
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
        debugPrint('Loaded ${_categories.length} categories from custom online URL');
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
      default:
        await loadProducts();
    }
  }
}

