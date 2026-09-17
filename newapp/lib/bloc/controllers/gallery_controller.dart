// lib/bloc/controllers/gallery_controller.dart
import 'package:get/get.dart';
import 'package:yaatal_mbindum/services/gallery_service.dart';
import 'package:yaatal_mbindum/models/gallery_model.dart';

class GalleryController extends GetxController {
  final _service = GalleryService();

  final RxList<GalleryPhoto> photos = <GalleryPhoto>[].obs;
  final RxList<int> years = <int>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoadingMore = false.obs;

  final RxnInt selectedYear = RxnInt(null);
  final RxnString selectedType = RxnString(null);

  int _currentPage = 1;
  bool _hasMore = true;
  Rx<GalleryMeta?> meta = Rx<GalleryMeta?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchYears();
    fetchPhotos(reset: true);
  }

  Future<void> fetchYears() async {
    years.value = await _service.getYears();
  }

  Future<void> fetchPhotos({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      photos.clear();
    }
    if (!_hasMore) return;

    try {
      reset ? isLoading.value = true : isLoadingMore.value = true;
      hasError.value = false;

      final data = await _service.getPhotos(
        year: selectedYear.value,
        type: selectedType.value,
        page: _currentPage,
        limit: 20,
      );

      if (data != null) {
        final list = (data['data'] as List)
            .map((e) => GalleryPhoto.fromJson(e))
            .toList();
        photos.addAll(list);
        meta.value = GalleryMeta.fromJson(data['meta']);
        _hasMore = _currentPage < (meta.value?.pages ?? 1);
        _currentPage++;
      } else {
        hasError.value = true;
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void setYear(int? year) {
    selectedYear.value = year;
    fetchPhotos(reset: true);
  }

  void setType(String? type) {
    selectedType.value = type;
    fetchPhotos(reset: true);
  }

  void loadMore() => fetchPhotos();
}
