import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade50,
        child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.deepPurple.shade200),
      );
    }
    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.deepPurple.shade50,
          child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.deepPurple.shade200),
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
            child: Text(
              product.price.isEmpty ? 'View price' : 'Rs. ${product.price}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.deepPurple),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Product'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
