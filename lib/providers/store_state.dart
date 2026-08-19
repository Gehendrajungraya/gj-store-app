import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartLine {
  final Product product;
  int quantity;

  CartLine(this.product, {this.quantity = 1});
}

class CartController extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  int get itemCount => _lines.fold(0, (total, line) => total + line.quantity);

  void add(Product product) {
    final index = _lines.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      _lines.add(CartLine(product));
    } else {
      _lines[index].quantity++;
    }
    notifyListeners();
  }

  void remove(Product product) {
    _lines.removeWhere((line) => line.product.id == product.id);
    notifyListeners();
  }

  void changeQuantity(Product product, int delta) {
    final index = _lines.indexWhere((line) => line.product.id == product.id);
    if (index == -1) return;
    _lines[index].quantity += delta;
    if (_lines[index].quantity < 1) _lines.removeAt(index);
    notifyListeners();
  }

  double get subtotal => _lines.fold(0, (total, line) {
        final price = double.tryParse(line.product.price) ?? 0;
        return total + price * line.quantity;
      });

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

class WishlistController extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);
  bool contains(Product product) =>
      _products.any((item) => item.id == product.id);

  void toggle(Product product) {
    if (contains(product)) {
      _products.removeWhere((item) => item.id == product.id);
    } else {
      _products.add(product);
    }
    notifyListeners();
  }
}

final cartController = CartController();
final wishlistController = WishlistController();
