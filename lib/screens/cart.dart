import 'package:flutter/material.dart';

import '../providers/store_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: AnimatedBuilder(
        animation: cartController,
        builder: (context, _) {
          if (cartController.lines.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...cartController.lines.map((line) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.extension_outlined),
                      title: Text(line.product.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(line.product.price.isEmpty
                          ? 'Contact us for price'
                          : 'Rs. ${line.product.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => cartController.changeQuantity(
                                  line.product, -1),
                              icon: const Icon(Icons.remove_circle_outline)),
                          Text('${line.quantity}'),
                          IconButton(
                              onPressed: () => cartController.changeQuantity(
                                  line.product, 1),
                              icon: const Icon(Icons.add_circle_outline)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              _SummaryRow(
                  label: 'Subtotal',
                  value: 'Rs. ${cartController.subtotal.toStringAsFixed(2)}'),
              const _SummaryRow(
                  label: 'Shipping', value: 'Calculated at checkout'),
              const Divider(height: 28),
              _SummaryRow(
                  label: 'Total',
                  value: 'Rs. ${cartController.subtotal.toStringAsFixed(2)}',
                  prominent: true),
              const SizedBox(height: 18),
              FilledButton.icon(
                  onPressed: () => _showCheckout(context),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Checkout')),
            ],
          );
        },
      ),
    );
  }

  void _showCheckout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Wrap(
          runSpacing: 12,
          children: [
            const Text('Checkout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Checkout is ready for the store backend payment flow.'),
            const TextField(
                decoration: InputDecoration(
                    labelText: 'Full name', border: OutlineInputBorder())),
            const TextField(
                decoration: InputDecoration(
                    labelText: 'Shipping address',
                    border: OutlineInputBorder())),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool prominent;

  const _SummaryRow(
      {required this.label, required this.value, this.prominent = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontWeight: prominent ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: prominent ? FontWeight.bold : FontWeight.normal))
        ]),
      );
}
