import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/banner_model.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api.dart';
import '../widgets/product_card.dart';
import 'notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StoreBanner> _banners = [];
  List<StoreCategory> _categories = [];
  List<Product> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  int? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.banners(),
        ApiService.categories(),
        ApiService.products(
            search: _searchQuery, categoryId: _selectedCategoryId),
      ]);

      var bannersList = results[0] as List<StoreBanner>;
      var categoriesList = results[1] as List<StoreCategory>;
      var productsList = results[2] as List<Product>;

      // Filter and sort banners
      bannersList = bannersList.where((b) => b.active == 1).toList();
      bannersList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Filter and sort categories
      categoriesList = categoriesList.where((c) => c.active == 1).toList();
      categoriesList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (mounted) {
        setState(() {
          _banners = bannersList;
          _categories = categoriesList;
          _products = productsList;
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Home load failed: $error');
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyMessage(error);
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('clientexception')) {
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

  Future<void> _filterProductsOnly() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productsList = await ApiService.products(
          search: _searchQuery, categoryId: _selectedCategoryId);
      if (mounted) {
        setState(() {
          _products = productsList;
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Product filter failed: $error');
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyMessage(error);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the banner link.')),
          );
        }
      }
    }
  }

  Widget _buildBannerImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade100,
        child: const Icon(Icons.image_not_supported,
            size: 50, color: Colors.white),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.deepPurple.shade100,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'GJ STORE',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen())),
                  icon: const Icon(Icons.notifications_none, size: 28),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Search Box
            TextField(
              controller: _searchController,
              onSubmitted: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
                _filterProductsOnly();
              },
              decoration: InputDecoration(
                hintText: 'Search plugins...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterProductsOnly();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),

            if (_errorMessage != null) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_isLoading &&
                _banners.isEmpty &&
                _categories.isEmpty &&
                _products.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else ...[
              // Banners Carousel
              if (_banners.isNotEmpty) ...[
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return GestureDetector(
                        onTap: () => _launchUrl(banner.actionUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildBannerImage(banner.imageUrl),
                              Container(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.bottomLeft,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black87
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            banner.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (banner.subtitle.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              banner.subtitle,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (banner.buttonText.isNotEmpty)
                                      ElevatedButton(
                                        onPressed: () =>
                                            _launchUrl(banner.actionUrl),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(banner.buttonText),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
              ],

              // Categories
              const Text(
                'Categories',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedCategoryId == null;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                          _filterProductsOnly();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.deepPurple : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All',
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final cat = _categories[index - 1];
                    final isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = isSelected ? null : cat.id;
                        });
                        _filterProductsOnly();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),

              // Featured / Latest Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured / Latest',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_products.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.category_outlined,
                            size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text(
                          'No products found matching the criteria.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .72,
                  ),
                  itemBuilder: (context, index) =>
                      ProductCard(product: _products[index]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
