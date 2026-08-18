class StoreBanner {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String actionUrl;
  final String startDate;
  final String endDate;
  final int active;
  final int sortOrder;

  StoreBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.buttonText,
    required this.actionUrl,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.sortOrder,
  });

  // Backward compatibility getters
  String get image => imageUrl;

  factory StoreBanner.fromJson(Map<String, dynamic> j) {
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

    return StoreBanner(
      id: parsedId,
      title: '${j['title'] ?? ''}',
      subtitle: '${j['subtitle'] ?? ''}',
      imageUrl: '${j['image_url'] ?? j['image'] ?? ''}',
      buttonText: '${j['button_text'] ?? ''}',
      actionUrl: '${j['action_url'] ?? j['url'] ?? ''}',
      startDate: '${j['start_date'] ?? ''}',
      endDate: '${j['end_date'] ?? ''}',
      active: parsedActive,
      sortOrder: parsedSortOrder,
    );
  }
}
