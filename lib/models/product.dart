class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? originalPrice;
  final String image;
  final double rating;
  final int reviews;
  final String description;
  final Map<String, String> specifications;
  final List<String> colors;
  final bool inStock;
  final bool featured;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.specifications,
    required this.colors,
    required this.inStock,
    required this.featured,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviews: json['reviews'],
      description: json['description'],
      specifications: Map<String, String>.from(json['specifications']),
      colors: List<String>.from(json['colors']),
      inStock: json['inStock'],
      featured: json['featured'],
    );
  }

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  bool get hasDiscount => discountPercentage > 0;
}

class Category {
  final String id;
  final String name;
  final String icon;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      products: (json['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;
  final String selectedColor;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedColor,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
