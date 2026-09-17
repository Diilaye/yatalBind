// lib/models/home_config_model.dart
import 'dart:ui';

class HomeConfig {
  final List<SliderItem> sliders;
  final List<CategoryItem> categories;
  final Map<String, String> texts;
  final List<SectionConfig> sections;

  HomeConfig({
    required this.sliders,
    required this.categories,
    required this.texts,
    required this.sections,
  });

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    // Textes : tableau [{key,value}] → Map
    final rawTexts = json['texts'] as List? ?? [];
    final textsMap = <String, String>{
      for (final e in rawTexts) (e['key'] as String): (e['value'] as String),
    };

    return HomeConfig(
      sliders: (json['sliders'] as List? ?? [])
          .map((e) => SliderItem.fromJson(e))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      categories: (json['categories'] as List? ?? [])
          .map((e) => CategoryItem.fromJson(e))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      texts: textsMap,
      sections: (json['sections'] as List? ?? [])
          .map((e) => SectionConfig.fromJson(e))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  String text(String key, {String fallback = ''}) => texts[key] ?? fallback;

  List<SliderItem> get activeSliders =>
      sliders.where((s) => s.isActive).toList();

  List<CategoryItem> get activeCategories =>
      categories.where((c) => c.isActive).toList();

  List<SectionConfig> get visibleSections =>
      sections.where((s) => s.isVisible).toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class SliderItem {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? actionUrl;
  final bool isActive;
  final int order;

  SliderItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.actionUrl,
    required this.isActive,
    required this.order,
  });

  factory SliderItem.fromJson(Map<String, dynamic> j) => SliderItem(
        id: j['id'] ?? j['_id'] ?? '',
        imageUrl: j['imageUrl'] ?? '',
        title: j['title'] ?? '',
        subtitle: j['subtitle'] ?? '',
        actionUrl: j['actionUrl'],
        isActive: j['isActive'] ?? true,
        order: j['order'] ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class CategoryItem {
  final String id;
  final String label;
  final String iconUrl;
  final String youtubePlaylistUrl;
  final bool isActive;
  final int order;
  final Color color;

  CategoryItem({
    required this.id,
    required this.label,
    required this.iconUrl,
    required this.youtubePlaylistUrl,
    required this.isActive,
    required this.order,
    required this.color,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> j) {
    Color parsedColor;
    try {
      final hex = (j['color'] as String? ?? '#084D27').replaceFirst('#', '');
      parsedColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      parsedColor = const Color(0xFF084D27);
    }
    return CategoryItem(
      id: j['id'] ?? j['_id'] ?? '',
      label: j['label'] ?? '',
      iconUrl: j['iconUrl'] ?? '',
      youtubePlaylistUrl: j['youtubePlaylistUrl'] ?? '',
      isActive: j['isActive'] ?? true,
      order: j['order'] ?? 0,
      color: parsedColor,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class SectionConfig {
  final String key;
  final bool isVisible;
  final int order;
  final String? titleOverride;

  SectionConfig({
    required this.key,
    required this.isVisible,
    required this.order,
    this.titleOverride,
  });

  factory SectionConfig.fromJson(Map<String, dynamic> j) => SectionConfig(
        key: j['key'] ?? '',
        isVisible: j['isVisible'] ?? true,
        order: j['order'] ?? 0,
        titleOverride: j['titleOverride'],
      );
}
