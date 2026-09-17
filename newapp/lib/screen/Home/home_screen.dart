// lib/screen/Home/home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:yaatal_mbindum/bloc/controllers/home_controller.dart';
import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';
import 'package:yaatal_mbindum/models/home_config_model.dart';
import 'package:yaatal_mbindum/utils/colors.dart';
import 'package:yaatal_mbindum/widgets/app_bar_widget/home_app_bar.dart';
import 'package:yaatal_mbindum/widgets/app_bar_widget/search_bar_widget.dart';
import 'package:yaatal_mbindum/widgets/cart_widget.dart';
import 'package:yaatal_mbindum/widgets/concours/concours_list_widget.dart';
import 'package:yaatal_mbindum/screen/Concours/concours.dart';
import 'package:yaatal_mbindum/screen/Concours/participate_screen.dart';
import 'package:yaatal_mbindum/screen/Events/events.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();
    final ctrl = Get.find<HomeController>();

    return Obx(() => Directionality(
          textDirection:
              lang.isRTL.value ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                // ── Fond fixe ──────────────────────────────────────────────
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
                          yDarkColor.withOpacity(0.72),
                          yDarkColor.withOpacity(0.88),
                          yDarkColor.withOpacity(0.96),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Contenu dynamique ──────────────────────────────────────
                SafeArea(
                  child: ctrl.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: yGoldColor))
                      : ctrl.hasError.value
                          ? _ErrorView(onRetry: ctrl.fetchConfig)
                          : _HomeBody(ctrl: ctrl),
                ),
              ],
            ),
          ),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HomeBody extends StatefulWidget {
  final HomeController ctrl;
  const _HomeBody({required this.ctrl});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  int _currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    return RefreshIndicator(
      color: yGoldColor,
      onRefresh: ctrl.fetchConfig,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              CustomAppBar(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 28),

              // Sections ordonnées dynamiquement
              ...ctrl.visibleSections.map(
                (s) => _buildSection(context, s, ctrl),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dispatch par clé de section ──────────────────────────────────────────
  Widget _buildSection(
    BuildContext context,
    SectionConfig section,
    HomeController ctrl,
  ) {
    switch (section.key) {
      case 'slider':
        return Column(children: [
          _buildSlider(ctrl),
          _buildParticipateButton(context, ctrl),
          const SizedBox(height: 28),
        ]);

      case 'categories':
        if (ctrl.activeCategories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(section.titleOverride ??
                ctrl.text('categories', fallback: 'Catégories')),
            const SizedBox(height: 12),
            _DynamicCategories(categories: ctrl.activeCategories),
            const SizedBox(height: 28),
          ],
        );

      case 'events':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              section.titleOverride ??
                  ctrl.text('previous_events',
                      fallback: 'Événements Précédents'),
              onSeeAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EventsScreen()),
              ),
            ),
            const SizedBox(height: 14),
            const Cart(),
            const SizedBox(height: 28),
          ],
        );

      case 'concours':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              section.titleOverride ??
                  ctrl.text('yaatal_mbinde_contest',
                      fallback: 'Concours Yaatal Mbinde'),
              onSeeAll: () => Get.to(ConcoursScreen()),
            ),
            const SizedBox(height: 14),
            ConcoursWidget(),
            const SizedBox(height: 28),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ── Slider ────────────────────────────────────────────────────────────────
  Widget _buildSlider(HomeController ctrl) {
    if (ctrl.activeSliders.isEmpty) return const SizedBox(height: 220);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 220,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (i, _) => setState(() => _currentSlide = i),
            ),
            items: ctrl.activeSliders.map((s) => _SliderCard(item: s)).toList(),
          ),
        ),
        // Indicateurs
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ctrl.activeSliders.asMap().entries.map((e) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentSlide == e.key ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentSlide == e.key
                      ? yGoldColor
                      : yWhiteColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Bouton Participer ─────────────────────────────────────────────────────
  Widget _buildParticipateButton(BuildContext context, HomeController ctrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        gradient: const LinearGradient(colors: [yAccentColor, ySecondaryColor]),
        boxShadow: yGoldShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParticipateScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: yGoldColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.how_to_reg_rounded,
                      color: yGoldColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  ctrl.text('participate', fallback: 'Participer'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: yWhiteColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded,
                    color: yWhiteColor.withOpacity(0.7), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() => Container(
        decoration: BoxDecoration(
          color: yWhiteColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: yWhiteColor.withOpacity(0.18), width: 1),
        ),
        child: SearchBarWidget(),
      );

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [yGoldColor, yGoldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: yWhiteColor,
              )),
        ]),
      );

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [yGoldColor, yGoldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: yWhiteColor,
              )),
        ]),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: yGoldColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: yGoldColor.withOpacity(0.4), width: 1),
            ),
            child: Text('see_all'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: yGoldColor,
                )),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide card
// ─────────────────────────────────────────────────────────────────────────────
class _SliderCard extends StatelessWidget {
  final SliderItem item;
  const _SliderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (item.actionUrl != null && item.actionUrl!.isNotEmpty) {
          final uri = Uri.parse(item.actionUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: yDarkColor.withOpacity(0.5)),
            errorWidget: (_, __, ___) =>
                Container(color: yDarkColor, child: const Icon(Icons.image)),
          ),
          if (item.title.isNotEmpty || item.subtitle.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title.isNotEmpty)
                    Text(item.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: yWhiteColor,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8)
                          ],
                        )),
                  if (item.subtitle.isNotEmpty)
                    Text(item.subtitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: yWhiteColor.withOpacity(0.85),
                        )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Catégories dynamiques
// ─────────────────────────────────────────────────────────────────────────────
class _DynamicCategories extends StatelessWidget {
  final List<CategoryItem> categories;
  const _DynamicCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _CategoryTile(item: categories[i]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryItem item;
  const _CategoryTile({required this.item});

  Future<void> _openYoutube() async {
    final uri = Uri.parse(item.youtubePlaylistUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openYoutube,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [item.color, item.color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: yGoldColor.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipOval(
              child: item.iconUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.iconUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(
                          strokeWidth: 2, color: yGoldColor),
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.play_circle_fill,
                          color: yWhiteColor,
                          size: 30),
                    )
                  : const Icon(Icons.play_circle_fill,
                      color: yWhiteColor, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: yWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vue erreur
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: yGoldColor, size: 48),
            const SizedBox(height: 16),
            const Text('Erreur de chargement',
                style: TextStyle(color: yWhiteColor, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: yGoldColor),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
}
