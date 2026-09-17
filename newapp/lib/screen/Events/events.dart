// lib/screen/events_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:yaatal_mbindum/bloc/events_bloc.dart';
import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';
import 'package:yaatal_mbindum/models/youtube_video_model.dart';
import '/utils/colors.dart';

// ─── Palette locale ────────────────────────────────────────────────────────────
const _kGold = yGoldColor;
const _kGoldLight = yGoldLight;
const _kDark = yDarkColor;
const _kWhite = yWhiteColor;

// ══════════════════════════════════════════════════════════════════════════════
// Écran principal
// ══════════════════════════════════════════════════════════════════════════════

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventsBloc(),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatefulWidget {
  const _EventsView();

  @override
  State<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView>
    with TickerProviderStateMixin {
  final LanguageController _lang = Get.find<LanguageController>();

  // ── Lecteur YouTube ────────────────────────────────────────────────────────
  YoutubePlayerController? _ytController;
  bool _playerReady = false;

  // ── Animations header ──────────────────────────────────────────────────────
  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _headerAnim,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void deactivate() {
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  // ── Sélection d'une vidéo ──────────────────────────────────────────────────
  void _onVideoSelected(YoutubeVideoModel video, EventsBloc bloc) {
    // Dispose de l'ancien contrôleur
    _ytController?.dispose();

    _ytController = YoutubePlayerController(
      initialVideoId: video.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    )..addListener(_onPlayerListen);

    _playerReady = false;
    bloc.selectVideo(video);
  }

  void _onPlayerListen() {
    if (_playerReady && mounted) setState(() {});
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Obx(() => Directionality(
          textDirection:
              _lang.isRTL.value ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: _kDark,
            body: Stack(
              children: [
                // ── Fond ───────────────────────────────────────────────────
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
                          _kDark.withOpacity(0.82),
                          _kDark.withOpacity(0.97),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Contenu ────────────────────────────────────────────────
                SafeArea(
                  child: Consumer<EventsBloc>(
                    builder: (context, bloc, _) => Column(
                      children: [
                        // Zone supérieure : header OU lecteur
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.06),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: bloc.isPlaying && _ytController != null
                              ? _PlayerSection(
                                  key: ValueKey(bloc.currentVideo?.videoId),
                                  controller: _ytController!,
                                  video: bloc.currentVideo!,
                                  lang: _lang,
                                  onReady: () =>
                                      setState(() => _playerReady = true),
                                  onClose: () {
                                    _ytController?.pause();
                                    bloc.closePlayer();
                                  },
                                )
                              : _HeaderSection(
                                  key: const ValueKey('header'),
                                  fade: _headerFade,
                                  slide: _headerSlide,
                                  lang: _lang,
                                  bloc: bloc,
                                ),
                        ),

                        // Liste des vidéos
                        Expanded(
                          child: _VideoList(
                            bloc: bloc,
                            currentVideoId: bloc.currentVideo?.videoId,
                            onVideoTap: (v) => _onVideoSelected(v, bloc),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section Header (aucune lecture en cours)
// ══════════════════════════════════════════════════════════════════════════════

class _HeaderSection extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final LanguageController lang;
  final EventsBloc bloc;

  const _HeaderSection({
    super.key,
    required this.fade,
    required this.slide,
    required this.lang,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final totalMin = bloc.totalDurationMinutes;
    final durationLabel = totalMin > 0 ? '$totalMin min' : '—';
    final countLabel = bloc.hasVideos ? '${bloc.videos.length} vidéos' : '—';

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleBtn(
                    icon: lang.isRTL.value
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      // Bandeau fallback
                      if (bloc.usedFallback)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  size: 12, color: Colors.orange),
                              SizedBox(width: 5),
                              Text(
                                'Mode hors-ligne',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      _CircleBtn(
                        icon: Icons.refresh_rounded,
                        onTap: () => bloc.refresh(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Titre
              Text(
                'previous_events'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _kWhite,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'C3s Yaatal Mbinde Al Xurane',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: _kWhite.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),

              // Stats chips
              Row(
                children: [
                  _StatChip(icon: Icons.timer_outlined, label: durationLabel),
                  const SizedBox(width: 10),
                  _StatChip(
                      icon: Icons.play_circle_outline_rounded,
                      label: countLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section Lecteur (vidéo sélectionnée)
// ══════════════════════════════════════════════════════════════════════════════

class _PlayerSection extends StatelessWidget {
  final YoutubePlayerController controller;
  final YoutubeVideoModel video;
  final LanguageController lang;
  final VoidCallback onReady;
  final VoidCallback onClose;

  const _PlayerSection({
    super.key,
    required this.controller,
    required this.video,
    required this.lang,
    required this.onReady,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mini top bar ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              _CircleBtn(
                icon: lang.isRTL.value
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                onTap: onClose,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  video.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // ── Lecteur ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: _kGold,
              progressColors: const ProgressBarColors(
                playedColor: _kGold,
                handleColor: _kGoldLight,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.black26,
              ),
              onReady: onReady,
            ),
          ),
        ),

        // ── Métadonnées sous le lecteur ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              if (video.duration.isNotEmpty) ...[
                _MetaChip(icon: Icons.timer_outlined, label: video.duration),
                const SizedBox(width: 8),
              ],
              if (video.viewCount.isNotEmpty)
                _MetaChip(
                    icon: Icons.visibility_outlined, label: video.viewCount),
              if (video.publishedAt.isNotEmpty) ...[
                const SizedBox(width: 8),
                _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: video.publishedAt),
              ],
            ],
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Liste des vidéos
// ══════════════════════════════════════════════════════════════════════════════

class _VideoList extends StatelessWidget {
  final EventsBloc bloc;
  final String? currentVideoId;
  final void Function(YoutubeVideoModel) onVideoTap;

  const _VideoList({
    required this.bloc,
    required this.currentVideoId,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kDark.withOpacity(0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: _kGold.withOpacity(0.22), width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── En-tête liste ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kGold, _kGoldLight],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'video_list'.tr.isEmpty ? 'Playlist' : 'video_list'.tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kWhite,
                      ),
                    ),
                  ],
                ),
                // Compteur / état
                _buildStateChip(bloc),
              ],
            ),
          ),

          // ── Contenu ─────────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildStateChip(EventsBloc bloc) {
    switch (bloc.loadState) {
      case VideoLoadState.loading:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child:
                    CircularProgressIndicator(strokeWidth: 1.5, color: _kGold),
              ),
              SizedBox(width: 6),
              Text('Chargement',
                  style: TextStyle(
                      fontSize: 10,
                      color: _kGold,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      case VideoLoadState.error:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Erreur',
            style: TextStyle(
                fontSize: 10,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
          ),
          child: Text(
            '${bloc.videos.length} vidéos',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _kGold,
            ),
          ),
        );
    }
  }

  Widget _buildBody() {
    switch (bloc.loadState) {
      case VideoLoadState.loading:
        return const _SkeletonList();

      case VideoLoadState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 44, color: _kWhite.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                bloc.errorMessage ?? 'Erreur de chargement',
                style: TextStyle(
                    color: _kWhite.withOpacity(0.45),
                    fontSize: 13,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: bloc.refresh,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [_kGold, _kGoldLight]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Réessayer',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kDark),
                  ),
                ),
              ),
            ],
          ),
        );

      case VideoLoadState.loaded:
        if (!bloc.hasVideos) return _buildEmpty();
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: bloc.videos.length,
          itemBuilder: (_, i) {
            final video = bloc.videos[i];
            final isActive = video.videoId == currentVideoId;
            return _VideoCard(
              video: video,
              isActive: isActive,
              onTap: () => onVideoTap(video),
            );
          },
        );

      default:
        return _buildEmpty();
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_library_outlined,
              size: 52, color: _kWhite.withOpacity(0.18)),
          const SizedBox(height: 10),
          Text(
            'Aucune vidéo disponible',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: _kWhite.withOpacity(0.35),
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Carte vidéo
// ══════════════════════════════════════════════════════════════════════════════

class _VideoCard extends StatelessWidget {
  final YoutubeVideoModel video;
  final bool isActive;
  final VoidCallback onTap;

  const _VideoCard({
    required this.video,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? yAccentColor.withOpacity(0.22)
              : _kWhite.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isActive ? _kGold.withOpacity(0.55) : _kWhite.withOpacity(0.09),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _kGold.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            _Thumbnail(
              url: video.thumbnailUrl,
              isActive: isActive,
            ),
            const SizedBox(width: 12),

            // ── Infos ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? _kGold : _kWhite,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: [
                      if (video.duration.isNotEmpty)
                        _InfoChip(
                            icon: Icons.timer_outlined, label: video.duration),
                      if (video.viewCount.isNotEmpty)
                        _InfoChip(
                            icon: Icons.visibility_outlined,
                            label: video.viewCount),
                      if (video.publishedAt.isNotEmpty)
                        _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: video.publishedAt),
                    ],
                  ),
                ],
              ),
            ),

            // ── Badge "En cours" ──────────────────────────────────────────
            if (isActive)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kGold, _kGoldLight]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En cours',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _kDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Thumbnail avec play overlay
// ══════════════════════════════════════════════════════════════════════════════

class _Thumbnail extends StatelessWidget {
  final String url;
  final bool isActive;
  const _Thumbnail({required this.url, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  width: 80,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return _placeholder(loading: true);
                  },
                )
              : _placeholder(),
        ),
        // Overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.black.withOpacity(isActive ? 0.1 : 0.28),
              child: Center(
                child: Icon(
                  isActive
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: isActive ? _kGold : _kWhite.withOpacity(0.85),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: 80,
      height: 54,
      decoration: BoxDecoration(
        color: yCardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 1.5, color: _kGold),
              )
            : Icon(Icons.movie_outlined,
                size: 22, color: _kWhite.withOpacity(0.25)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Skeleton loader
// ══════════════════════════════════════════════════════════════════════════════

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();
  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _kWhite.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Thumbnail skeleton
              Container(
                width: 80,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [
                      (_anim.value - 0.4).clamp(-1.0, 1.0),
                      _anim.value.clamp(-1.0, 1.0),
                      (_anim.value + 0.4).clamp(-1.0, 1.0),
                    ],
                    colors: [
                      _kWhite.withOpacity(0.05),
                      _kWhite.withOpacity(0.12),
                      _kWhite.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texte skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkimBar(width: double.infinity, anim: _anim.value),
                    const SizedBox(height: 6),
                    _SkimBar(width: 160, anim: _anim.value),
                    const SizedBox(height: 8),
                    _SkimBar(width: 100, anim: _anim.value, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkimBar extends StatelessWidget {
  final double width;
  final double anim;
  final double height;
  const _SkimBar({required this.width, required this.anim, this.height = 13});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [
            (anim - 0.4).clamp(-1.0, 1.0),
            anim.clamp(-1.0, 1.0),
            (anim + 0.4).clamp(-1.0, 1.0),
          ],
          colors: [
            _kWhite.withOpacity(0.05),
            _kWhite.withOpacity(0.13),
            _kWhite.withOpacity(0.05),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Petits widgets réutilisables
// ══════════════════════════════════════════════════════════════════════════════

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _kWhite.withOpacity(0.09),
          shape: BoxShape.circle,
          border: Border.all(color: _kWhite.withOpacity(0.16), width: 1),
        ),
        child: Icon(icon, color: _kWhite, size: 18),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [yAccentColor, ySecondaryColor]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: yCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _kWhite),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kWhite)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kGold.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: _kWhite.withOpacity(0.55))),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: _kGold.withOpacity(0.7)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: _kWhite.withOpacity(0.45))),
      ],
    );
  }
}
