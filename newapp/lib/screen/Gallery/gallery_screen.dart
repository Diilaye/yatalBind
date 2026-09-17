// lib/screen/Gallery/gallery_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../bloc/controllers/gallery_controller.dart';
import '../../bloc/controllers/language_controller.dart';
import '../../models/gallery_model.dart';
import '../../utils/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RÈGLE APPLIQUÉE DANS CE FICHIER :
// • Obx()  → uniquement quand UNE SEULE variable .obs est lue directement
// • GetBuilder<T> → pour les rebuilds liés à un controller complet
// • Jamais de Obx imbriqués dans un autre Obx
// • Get.find() toujours appelé DANS le callback, jamais en champ de classe
// ─────────────────────────────────────────────────────────────────────────────

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Déclarés dans build() — pas en champ de classe
    final lang = Get.find<LanguageController>();
    final ctrl = Get.find<GalleryController>();

    return Obx(() => Directionality(
          textDirection:
              lang.isRTL.value ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/plandetravail.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          yDarkColor.withOpacity(0.75),
                          yDarkColor.withOpacity(0.92),
                          yDarkColor.withOpacity(0.98),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  // ✅ GetBuilder au lieu de Obx — pas de conflit d'imbrication
                  child: GetBuilder<GalleryController>(
                    builder: (c) => c.isLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(color: yGoldColor))
                        : _GalleryBody(ctrl: ctrl),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GalleryBody extends StatefulWidget {
  final GalleryController ctrl;
  const _GalleryBody({required this.ctrl});

  @override
  State<_GalleryBody> createState() => _GalleryBodyState();
}

class _GalleryBodyState extends State<_GalleryBody>
    with TickerProviderStateMixin {
  bool _isGridView = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _scrollCtrl = ScrollController();

  final List<String> _types = [
    'all',
    'ceremonie',
    'concours',
    'coulisses',
    'laureats',
    'autre'
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        widget.ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _changeFilter() {
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(ctrl)),
        SliverToBoxAdapter(child: _buildYearFilters(ctrl)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: _buildTypeFilters(ctrl)),
        SliverToBoxAdapter(child: _buildViewToggle(ctrl)),

        // ✅ UN SEUL GetBuilder pour la grille/liste
        // Pas de Obx + AnimatedBuilder imbriqués
        GetBuilder<GalleryController>(
          builder: (c) {
            if (c.photos.isEmpty) {
              return const SliverToBoxAdapter(child: _EmptyView());
            }
            return _FadingSliver(
              animation: _fadeAnim,
              isGrid: _isGridView,
              ctrl: c,
            );
          },
        ),

        // ✅ Indicateur pagination — Obx simple sur UNE variable
        GetBuilder<GalleryController>(
          builder: (c) => SliverToBoxAdapter(
            child: c.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(color: yGoldColor),
                    ),
                  )
                : const SizedBox(height: 100),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(GalleryController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleBtn(
                  Icons.arrow_back_rounded, () => Navigator.pop(context)),
              _circleBtn(Icons.refresh_rounded, () {
                ctrl.fetchPhotos(reset: true);
                _changeFilter();
              }),
            ],
          ),
          const SizedBox(height: 20),
          Text('gallery'.tr,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: yWhiteColor,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 4),
          Text('yaatal_mbindoum'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: yWhiteColor.withOpacity(0.6),
              )),
          const SizedBox(height: 18),

          // ✅ GetBuilder — pas d'Obx imbriqué
          GetBuilder<GalleryController>(
            builder: (c) => Row(children: [
              _statChip(
                Icons.photo_library_outlined,
                '+${c.meta.value?.total ?? c.photos.length} ${'photos_count'.tr}',
              ),
              const SizedBox(width: 12),
              _statChip(
                Icons.calendar_today_outlined,
                '${c.years.length} ${'years'.tr}',
              ),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Filtres année ─────────────────────────────────────────────────────────
  // ✅ GetBuilder au lieu de Obx — élimine le crash ligne 282
  Widget _buildYearFilters(GalleryController ctrl) {
    return GetBuilder<GalleryController>(
      builder: (c) {
        final years = [null, ...c.years];
        return SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: years.length,
            itemBuilder: (_, i) {
              final y = years[i];
              final isSelected = c.selectedYear.value == y;
              return GestureDetector(
                onTap: () {
                  c.setYear(y);
                  _changeFilter();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? yGoldColor : yWhiteColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? yGoldColor
                          : yWhiteColor.withOpacity(0.22),
                      width: 1.2,
                    ),
                    boxShadow: isSelected ? yGoldShadow : [],
                  ),
                  child: Text(
                    y == null ? 'all_years'.tr : y.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? yDarkColor : yWhiteColor,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Filtres type ──────────────────────────────────────────────────────────
  // ✅ GetBuilder au lieu de Obx — élimine le crash ligne 282
  Widget _buildTypeFilters(GalleryController ctrl) {
    return GetBuilder<GalleryController>(
      builder: (c) => SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _types.length,
          itemBuilder: (_, i) {
            final t = _types[i] == 'all' ? null : _types[i];
            final label = _types[i] == 'all' ? 'Tous' : _types[i];
            final isSelected = c.selectedType.value == t;
            return GestureDetector(
              onTap: () {
                c.setType(t);
                _changeFilter();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isSelected ? yAccentColor : yWhiteColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? yAccentColor
                        : yWhiteColor.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? yWhiteColor : yWhiteColor.withOpacity(0.7),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Toggle vue ────────────────────────────────────────────────────────────
  Widget _buildViewToggle(GalleryController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ GetBuilder — une seule source de vérité
          GetBuilder<GalleryController>(
            builder: (c) => Text(
              '${c.photos.length} ${'photos_count'.tr}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: yWhiteColor.withOpacity(0.7),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: yWhiteColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: yWhiteColor.withOpacity(0.15), width: 1),
            ),
            child: Row(children: [
              _toggleBtn(Icons.grid_view_rounded, _isGridView,
                  () => setState(() => _isGridView = true)),
              _toggleBtn(Icons.view_list_rounded, !_isGridView,
                  () => setState(() => _isGridView = false)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────
  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: yWhiteColor.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: yWhiteColor.withOpacity(0.20), width: 1),
          ),
          child: Icon(icon, color: yWhiteColor, size: 20),
        ),
      );

  Widget _statChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [yAccentColor, ySecondaryColor]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: yCardShadow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: yWhiteColor),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: yWhiteColor,
              )),
        ]),
      );

  Widget _toggleBtn(IconData icon, bool isSelected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected ? yGoldColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 20,
              color: isSelected ? yDarkColor : yWhiteColor.withOpacity(0.45)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver avec fade — widget séparé, hors de tout Obx/GetBuilder parent
// ─────────────────────────────────────────────────────────────────────────────
class _FadingSliver extends StatelessWidget {
  final Animation<double> animation;
  final bool isGrid;
  final GalleryController ctrl;

  const _FadingSliver({
    required this.animation,
    required this.isGrid,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => SliverOpacity(
        opacity: animation.value.clamp(0.0, 1.0),
        sliver: isGrid ? _buildGrid() : _buildList(),
      ),
    );
  }

  SliverGrid _buildGrid() => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(
            padding: EdgeInsets.only(
              left: i % 2 == 0 ? 20 : 0,
              right: i % 2 != 0 ? 20 : 0,
            ),
            child: _PhotoCard(
              photo: ctrl.photos[i],
              index: i,
              allPhotos: ctrl.photos,
            ),
          ),
          childCount: ctrl.photos.length,
        ),
      );

  SliverList _buildList() => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _PhotoListItem(
            photo: ctrl.photos[i],
            index: i,
            allPhotos: ctrl.photos,
          ),
          childCount: ctrl.photos.length,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Card
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  final GalleryPhoto photo;
  final int index;
  final List<GalleryPhoto> allPhotos;

  const _PhotoCard({
    required this.photo,
    required this.index,
    required this.allPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openViewer(context),
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: yCardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: photo.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: yCardBgColor),
                  errorWidget: (_, __, ___) => Container(
                    color: yCardBgColor,
                    child: Icon(Icons.image_outlined,
                        size: 48, color: yWhiteColor.withOpacity(0.3)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          yDarkColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ GetBuilder — pas d'Obx imbriqué
                        GetBuilder<LanguageController>(
                          builder: (lang) => Text(
                            lang.currentLanguage == 'ar'
                                ? photo.titleAr
                                : photo.title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: yWhiteColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 9, color: yGoldColor.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(photo.year.toString(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: yWhiteColor.withOpacity(0.65),
                                fontSize: 9,
                              )),
                        ]),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: yDarkColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(photo.type,
                        style: const TextStyle(
                          color: yGoldColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: yDarkColor.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.zoom_in_rounded,
                        color: yWhiteColor, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: _PhotoViewer(photos: allPhotos, initialIndex: index),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo List Item
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoListItem extends StatelessWidget {
  final GalleryPhoto photo;
  final int index;
  final List<GalleryPhoto> allPhotos;

  const _PhotoListItem({
    required this.photo,
    required this.index,
    required this.allPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: _PhotoViewer(photos: allPhotos, initialIndex: index),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: yWhiteColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: yWhiteColor.withOpacity(0.12), width: 1),
          ),
          child: Row(children: [
            Hero(
              tag: 'photo_${photo.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: photo.thumbnailUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: yCardBgColor,
                    child: Icon(Icons.image_outlined,
                        color: yWhiteColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ GetBuilder — remplace Obx
                  GetBuilder<LanguageController>(
                    builder: (lang) => Text(
                      lang.currentLanguage == 'ar'
                          ? photo.titleAr
                          : photo.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: yWhiteColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: yGoldColor),
                    const SizedBox(width: 4),
                    Text(photo.year.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: yWhiteColor.withOpacity(0.55),
                        )),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: yGoldColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(photo.type,
                          style: const TextStyle(
                            color: yGoldColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: yGoldColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    color: yGoldColor, size: 18),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visionneuse plein écran
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoViewer extends StatefulWidget {
  final List<GalleryPhoto> photos;
  final int initialIndex;
  const _PhotoViewer({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late PageController _pageCtrl;
  late int _currentIndex;
  bool _uiVisible = true;

  // ✅ Pas de champ lang — lu dans build() uniquement

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _uiVisible = !_uiVisible),
        child: Stack(children: [
          PhotoViewGallery.builder(
            pageController: _pageCtrl,
            itemCount: widget.photos.length,
            builder: (_, i) {
              final p = widget.photos[i];
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(p.imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: 'photo_${p.id}'),
              );
            },
            onPageChanged: (i) => setState(() => _currentIndex = i),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          AnimatedOpacity(
            opacity: _uiVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Stack(children: [
              // Top bar — pas de reactive, setState suffit
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _viewerBtn(
                            Icons.close_rounded, () => Navigator.pop(context)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _viewerBtn(Icons.share_rounded, () {}),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    // ✅ GetBuilder — remplace Obx définitivement
                    child: GetBuilder<LanguageController>(
                      builder: (lang) {
                        final p = widget.photos[_currentIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lang.currentLanguage == 'ar'
                                  ? p.titleAr
                                  : p.title,
                              style: const TextStyle(
                                color: yWhiteColor,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 12, color: yGoldColor),
                              const SizedBox(width: 6),
                              Text(p.year.toString(),
                                  style: TextStyle(
                                    color: yWhiteColor.withOpacity(0.7),
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                  )),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: yGoldColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(p.type,
                                    style: const TextStyle(
                                      color: yGoldColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ]),
                            if (p.tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: p.tags
                                    .map((t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: yWhiteColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text('#$t',
                                              style: TextStyle(
                                                color: yWhiteColor
                                                    .withOpacity(0.7),
                                                fontSize: 10,
                                              )),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _viewerBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 56, color: yWhiteColor.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('Aucune photo disponible',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: yWhiteColor.withOpacity(0.5),
                    fontSize: 16,
                  )),
            ],
          ),
        ),
      );
}
