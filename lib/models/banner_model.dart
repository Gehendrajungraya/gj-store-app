class StoreBanner {
  final int id;
  final String image;
  final String title;
  final String subtitle;
  final String actionUrl;

  StoreBanner({required this.id, required this.image, required this.title,
      required this.subtitle, required this.actionUrl});

  factory StoreBanner.fromJson(Map<String,dynamic> j) => StoreBanner(
    id: int.tryParse('${j['id']}') ?? 0,
    image: '${j['image'] ?? ''}',
    title: '${j['title'] ?? ''}',
    subtitle: '${j['subtitle'] ?? ''}',
    actionUrl: '${j['action_url'] ?? j['url'] ?? ''}',
  );
}
