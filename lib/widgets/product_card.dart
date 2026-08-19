import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details.dart';
import '../providers/store_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade50,
        child: Icon(Icons.image_not_supported_outlined,
            size: 50, color: Colors.deepPurple.shade200),
      );
    }
    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.deepPurple.shade50,
          child: Icon(Icons.broken_image_outlined,
              size: 50, color: Colors.deepPurple.shade200),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImage(product.imageUrl)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (product.version.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'v${product.version}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                        product.price.isEmpty
                            ? 'View price'
                            : 'Rs. ${product.price}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.deepPurple))),
                AnimatedBuilder(
                  animation: wishlistController,
                  builder: (context, _) => IconButton(
                    tooltip: 'Wishlist',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => wishlistController.toggle(product),
                    icon: Icon(
                        wishlistController.contains(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product))),
                        child: const Text('View'))),
                const SizedBox(width: 8),
                IconButton.filled(
                    tooltip: 'Add to cart',
                    onPressed: () {
                      cartController.add(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')));
                    },
                    icon: const Icon(Icons.add_shopping_cart)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
