// lib/services/home_config_service.dart
import 'package:yaatal_mbindum/utils/requette-by-dii.dart';

class HomeConfigService {
  final _api = ApiService();

  Future<Map<String, dynamic>?> getHomeConfig() async {
    final response = await _api.get(url: 'home-config', includeAuth: false);
    if (response.success && response.data != null) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return null;
  }
}
