import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/store_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  Product get product => widget.product;

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade50,
        child: Icon(Icons.image_not_supported_outlined,
            size: 70, color: Colors.deepPurple.shade200),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.deepPurple.shade50,
          child: Icon(Icons.broken_image_outlined,
              size: 70, color: Colors.deepPurple.shade200),
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
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () {
                        for (var i = 0; i < quantity; i++) {
                          cartController.add(product);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')));
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'))),
              const SizedBox(width: 10),
              Expanded(
                  child: FilledButton(
                      onPressed: () {
                        for (var i = 0; i < quantity; i++) {
                          cartController.add(product);
                        }
                        Navigator.pushNamed(context, '/cart');
                      },
                      child: const Text('Buy Now'))),
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
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900),
                ),
                if (product.version.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Version: ${product.version}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline)),
                    Text('$quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      product.price.isEmpty
                          ? 'Free / Contact us'
                          : 'Rs. ${product.price}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () => wishlistController.toggle(product),
                        icon: AnimatedBuilder(
                            animation: wishlistController,
                            builder: (_, __) => Icon(
                                wishlistController.contains(product)
                                    ? Icons.favorite
                                    : Icons.favorite_border))),
                  ],
                ),
                const Divider(height: 30),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description.isEmpty
                      ? 'No description available.'
                      : product.description,
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
