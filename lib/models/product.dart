class Product {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String imageUrl;
  final String version;
  final int categoryId;
  final String createdAt;
  final String updatedAt;
  final String url;
  final String oldPrice;
  final double? rating;
  final int? reviewCount;
  final int? stock;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.version,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    this.oldPrice = '',
    this.rating,
    this.reviewCount,
    this.stock,
  });

  // Backward compatibility getters
  String get title => name;
  String get image => imageUrl;

  factory Product.fromJson(Map<String, dynamic> j) {
    int parsedId = 0;
    if (j['id'] != null) {
      if (j['id'] is int) {
        parsedId = j['id'];
      } else {
        parsedId = int.tryParse(j['id'].toString()) ?? 0;
      }
    }

    int parsedCategoryId = 0;
    if (j['category_id'] != null) {
      if (j['category_id'] is int) {
        parsedCategoryId = j['category_id'];
      } else {
        parsedCategoryId = int.tryParse(j['category_id'].toString()) ?? 0;
      }
    }

    String parsedPrice = '';
    if (j['price'] != null) {
      parsedPrice = j['price'].toString();
    }

    return Product(
      id: parsedId,
      name: '${j['name'] ?? j['title'] ?? ''}',
      slug: '${j['slug'] ?? ''}',
      description: '${j['description'] ?? ''}',
      price: parsedPrice,
      imageUrl: '${j['image_url'] ?? j['image'] ?? j['featured_image'] ?? ''}',
      version: '${j['version'] ?? ''}',
      categoryId: parsedCategoryId,
      createdAt: '${j['created_at'] ?? ''}',
      updatedAt: '${j['updated_at'] ?? ''}',
      url: '${j['url'] ?? ''}',
      oldPrice:
          '${j['old_price'] ?? j['compare_at_price'] ?? j['regular_price'] ?? ''}',
      rating: _doubleValue(j['rating'] ?? j['average_rating']),
      reviewCount: _intValue(j['review_count'] ?? j['reviews_count']),
      stock: _intValue(j['stock'] ?? j['stock_quantity'] ?? j['quantity']),
    );
  }

  static int? _intValue(dynamic value) {
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }

  static double? _doubleValue(dynamic value) {
    if (value == null) return null;
    return value is num ? value.toDouble() : double.tryParse(value.toString());
  }
}
