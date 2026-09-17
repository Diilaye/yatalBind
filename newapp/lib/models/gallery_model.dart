// lib/models/gallery_model.dart
class GalleryPhoto {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;
  final String titleAr;
  final String description;
  final int year;
  final String type;
  final List<String> tags;
  final bool isActive;
  final int order;
  final String createdAt;

  GalleryPhoto({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.year,
    required this.type,
    required this.tags,
    required this.isActive,
    required this.order,
    required this.createdAt,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> j) => GalleryPhoto(
        id: j['id'] ?? j['_id'] ?? '',
        imageUrl: j['imageUrl'] ?? '',
        thumbnailUrl: j['thumbnailUrl'] ?? j['imageUrl'] ?? '',
        title: j['title'] ?? '',
        titleAr: j['titleAr'] ?? '',
        description: j['description'] ?? '',
        year: j['year'] ?? 0,
        type: j['type'] ?? 'autre',
        tags: List<String>.from(j['tags'] ?? []),
        isActive: j['isActive'] ?? true,
        order: j['order'] ?? 0,
        createdAt: j['createdAt'] ?? '',
      );
}

class GalleryMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  GalleryMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory GalleryMeta.fromJson(Map<String, dynamic> j) => GalleryMeta(
        total: j['total'] ?? 0,
        page: j['page'] ?? 1,
        limit: j['limit'] ?? 20,
        pages: j['pages'] ?? 1,
      );
}
