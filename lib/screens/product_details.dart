import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade50,
        child: Icon(Icons.image_not_supported_outlined, size: 70, color: Colors.deepPurple.shade200),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.deepPurple.shade50,
          child: Icon(Icons.broken_image_outlined, size: 70, color: Colors.deepPurple.shade200),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Add to Cart'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton(onPressed: () {}, child: const Text('Buy Now'))),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: _buildImage(product.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                if (product.version.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Version: ${product.version}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  product.price.isEmpty ? 'Free / Contact us' : 'Rs. ${product.price}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const Divider(height: 30),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description.isEmpty ? 'No description available.' : product.description,
                  style: const TextStyle(height: 1.5, fontSize: 15),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
