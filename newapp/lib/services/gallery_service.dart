// lib/services/gallery_service.dart
import 'package:yaatal_mbindum/utils/requette-by-dii.dart';

class GalleryService {
  final _api = ApiService();

  Future<Map<String, dynamic>?> getPhotos({
    int? year,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'active': 'true',
      if (year != null) 'year': year.toString(),
      if (type != null) 'type': type,
    };

    final response = await _api.get(
      url: 'gallery',
      includeAuth: false,
      queryParameters: params,
    );

    if (response.success) return response.data as Map<String, dynamic>;
    return null;
  }

  Future<List<int>> getYears() async {
    final response = await _api.get(
      url: 'gallery/years',
      includeAuth: false,
    );
    if (response.success && response.data != null) {
      return List<int>.from(response.data['data'] ?? []);
    }
    return [];
  }
}
