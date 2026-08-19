import 'package:flutter/material.dart';

import '../providers/store_state.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: AnimatedBuilder(
        animation: wishlistController,
        builder: (context, _) {
          if (wishlistController.products.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistController.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72),
            itemBuilder: (context, index) =>
                ProductCard(product: wishlistController.products[index]),
          );
        },
      ),
    );
  }
}
