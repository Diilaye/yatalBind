// lib/bloc/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:yaatal_mbindum/services/home_config_service.dart';
import 'package:yaatal_mbindum/models/home_config_model.dart';

class HomeController extends GetxController {
  final _service = HomeConfigService();

  final Rx<HomeConfig?> config = Rx<HomeConfig?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final data = await _service.getHomeConfig();
      if (data != null) {
        config.value = HomeConfig.fromJson(data);
      } else {
        hasError.value = true;
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  String text(String key, {String fallback = ''}) =>
      config.value?.text(key, fallback: fallback) ?? key.tr;

  List<SliderItem> get activeSliders => config.value?.activeSliders ?? [];
  List<CategoryItem> get activeCategories =>
      config.value?.activeCategories ?? [];
  List<SectionConfig> get visibleSections =>
      config.value?.visibleSections ?? [];
}
