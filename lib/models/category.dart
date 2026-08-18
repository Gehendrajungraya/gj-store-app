class StoreCategory {
  final int id;
  final String name;
  final String image;
  StoreCategory({required this.id, required this.name, required this.image});

  factory StoreCategory.fromJson(Map<String,dynamic> j) => StoreCategory(
    id: int.tryParse('${j['id']}') ?? 0,
    name: '${j['name'] ?? j['title'] ?? ''}',
    image: '${j['image'] ?? ''}',
  );
}
