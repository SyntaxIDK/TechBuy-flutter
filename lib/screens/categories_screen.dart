import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Category filter chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productProvider.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: productProvider.selectedCategory.isEmpty,
                            onSelected: (selected) {
                              if (selected) {
                                productProvider.setSelectedCategory('');
                              }
                            },
                          ),
                        );
                      }

                      final category = productProvider.categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: productProvider.selectedCategory == category.id,
                          onSelected: (selected) {
                            productProvider.setSelectedCategory(
                              selected ? category.id : '',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Products grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.filteredProducts[index];
                      return ProductGridCard(product: product);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 2, // Reduced from 3 to 2 to give more space to content
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        product.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Center(
                            child: Icon(
                              _getProductIcon(product.name),
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          final isFavorite = productProvider.isFavorite(product);
                          return GestureDetector(
                            onTap: () => productProvider.toggleFavorite(product),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_outline,
                                size: 16,
                                color: isFavorite ? Colors.red : Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3, // Increased from 2 to 3 to give more space to content
              child: Padding(
                padding: const EdgeInsets.all(6), // Further reduced from 8 to 6
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Add this to minimize space usage
                  children: [
                    Flexible( // Changed from Text to Flexible
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12, // Reduced font size
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 1), // Reduced from 2 to 1
                    Text(
                      product.brand,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price row
                    Flexible( // Changed from Row to Flexible Row
                      child: Row(
                        children: [
                          Flexible( // Made price text flexible
                            child: Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12, // Reduced font size
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '\$${product.originalPrice?.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                  fontSize: 10, // Reduced font size
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 1), // Reduced from 2 to 1
                    // Rating row
                    Flexible( // Changed from Row to Flexible Row
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12), // Reduced size
                          const SizedBox(width: 1), // Reduced spacing
                          Flexible( // Made rating flexible
                            child: Text(
                              '${product.rating} (${product.reviews})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10, // Reduced font size
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('macbook')) {
      return Icons.laptop_mac;
    } else if (productName.toLowerCase().contains('iphone')) {
      return Icons.phone_iphone;
    } else if (productName.toLowerCase().contains('pixel') ||
               productName.toLowerCase().contains('galaxy')) {
      return Icons.smartphone;
    } else {
      return Icons.laptop;
    }
  }
}
