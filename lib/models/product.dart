class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final String price;
  final String url;

  Product({required this.id, required this.title, required this.description,
      required this.image, required this.price, required this.url});

  factory Product.fromJson(Map<String,dynamic> j) => Product(
    id: int.tryParse('${j['id']}') ?? 0,
    title: '${j['title'] ?? j['name'] ?? ''}',
    description: '${j['description'] ?? ''}',
    image: '${j['image'] ?? j['featured_image'] ?? ''}',
    price: '${j['price'] ?? ''}',
    url: '${j['url'] ?? ''}',
  );
}
