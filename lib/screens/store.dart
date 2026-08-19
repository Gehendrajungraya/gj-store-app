import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api.dart';
import '../widgets/product_card.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ApiService.products(search: _searchController.text.trim());
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) debugPrint('Store load failed: $error');
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyMessage(error);
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyMessage(Object error) {
    if (error is ApiException) {
      if (error.isCloudflare) {
        return 'The store request was blocked or failed at the Cloudflare/server layer. Please try again later.';
      }

      switch (error.status) {
        case 401:
          return 'Please log in to access the store.';
        case 403:
          return 'You do not have permission to access the store.';
        case 404:
          return 'The store API endpoint could not be found. Please try again later.';
        case 422:
          return 'The store request was not valid. Please adjust your search and try again.';
        case 429:
          return 'The store is receiving too many requests. Please wait a moment and retry.';
        case 500:
          return 'The store backend encountered an error. Please try again later.';
        case 502:
        case 503:
        case 504:
        case 520:
        case 521:
        case 522:
        case 523:
        case 524:
        case 525:
        case 526:
          return 'The store server is temporarily unavailable. Please try again later.';
        default:
          return 'Request failed (${error.status}). Please try again.';
      }
    }

    final text = error.toString().toLowerCase();
    if (text.contains('certificate_verify_failed') || text.contains('handshake')) {
      return 'Secure connection with the store server failed. Please try again later.';
    }
    if (text.contains('socketexception') || text.contains('failed host lookup') || text.contains('clientexception')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    if (text.contains('timeout')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    if (text.contains('login failed') || text.contains('unauthorized')) {
      return 'Login failed. Please check your email and password.';
    }
    if (text.contains('no products') || text.contains('not found')) {
      return 'No products available right now.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchProducts(),
              decoration: InputDecoration(
                hintText: 'Search plugins...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No plugins found.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .72,
      ),
      itemBuilder: (context, index) => ProductCard(product: _products[index]),
    );
  }
}
