import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product, String selectedColor) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(
        product: product,
        quantity: 1,
        selectedColor: selectedColor,
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId, String selectedColor) {
    _items.removeWhere(
      (item) => item.product.id == productId && item.selectedColor == selectedColor,
    );
    notifyListeners();
  }

  void updateQuantity(String productId, String selectedColor, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, selectedColor);
      return;
    }

    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.selectedColor == selectedColor,
    );

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(Product product, String selectedColor) {
    return _items.any(
      (item) => item.product.id == product.id && item.selectedColor == selectedColor,
    );
  }

  int getQuantity(Product product, String selectedColor) {
    final item = _items.firstWhere(
      (item) => item.product.id == product.id && item.selectedColor == selectedColor,
      orElse: () => CartItem(product: product, quantity: 0, selectedColor: selectedColor),
    );
    return item.quantity;
  }
}
