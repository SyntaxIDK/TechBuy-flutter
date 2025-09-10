import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/product.dart' as models;

class ProductProvider with ChangeNotifier {
  List<models.Category> _categories = [];
  final List<models.Product> _favorites = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isLoading = true;

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

      final String response =
          await rootBundle.loadString('assets/data/products.json');
      final data = json.decode(response);

      _categories = (data['categories'] as List)
          .map((category) => models.Category.fromJson(category))
          .toList();

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
}
