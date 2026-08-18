class StoreCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final int active;
  final int sortOrder;

  StoreCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.active,
    required this.sortOrder,
  });

  // Backward compatibility getters
  String get image => imageUrl;

  factory StoreCategory.fromJson(Map<String, dynamic> j) {
    int parsedId = 0;
    if (j['id'] != null) {
      if (j['id'] is int) {
        parsedId = j['id'];
      } else {
        parsedId = int.tryParse(j['id'].toString()) ?? 0;
      }
    }

    int parsedActive = 0;
    if (j['active'] != null) {
      if (j['active'] is int) {
        parsedActive = j['active'];
      } else {
        parsedActive = int.tryParse(j['active'].toString()) ?? 0;
      }
    }

    int parsedSortOrder = 0;
    if (j['sort_order'] != null) {
      if (j['sort_order'] is int) {
        parsedSortOrder = j['sort_order'];
      } else {
        parsedSortOrder = int.tryParse(j['sort_order'].toString()) ?? 0;
      }
    }

    return StoreCategory(
      id: parsedId,
      name: '${j['name'] ?? j['title'] ?? ''}',
      slug: '${j['slug'] ?? ''}',
      description: '${j['description'] ?? ''}',
      imageUrl: '${j['image_url'] ?? j['image'] ?? ''}',
      active: parsedActive,
      sortOrder: parsedSortOrder,
    );
  }
}
