// lib/screen/splash_screen.dart  — version optimisée performance

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '/utils/colors.dart';
import '/utils/images_string.dart';
import '/utils/text_string.dart';
import '/screen/nav_bar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Vidéo ─────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  // ── 1 controller maître pour toute la séquence (remplace 5 controllers) ──
  late final AnimationController _masterCtrl;

  // ── 2 controllers qui loopent (ne peuvent pas être dans le maître) ────────
  late final AnimationController _breatheCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Animations dérivées du maître ─────────────────────────────────────────
  late final Animation<double> _bgFadeAnim;
  late final Animation<double> _bookScaleAnim;
  late final Animation<double> _bookGlowAnim;
  late final Animation<double> _bookOpenAnim; // 0→1 remplace leftPage/rightPage
  late final Animation<double> _bookShadowAnim;
  late final Animation<int> _verseCharAnim;
  late final Animation<double> _verseOpacAnim;
  late final Animation<double> _logoFadeAnim;
  late final Animation<Offset> _logoSlideAnim;
  late final Animation<double> _subtitleFadeAnim;

  // ── Animations loopées ────────────────────────────────────────────────────
  late final Animation<double> _breatheAnim;
  late final Animation<double> _breatheScaleAnim;
  late final Animation<double> _shimmerAnim;

  // ── State ─────────────────────────────────────────────────────────────────
  static const _verse = 'نٓ ۚ وَٱلْقَلَمِ وَمَا يَسْطُرُونَ';
  static const _verseLtn = 'Nūn Wa Al-Qalami';
  String _shownVerse = '';
  bool _verseComplete = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initVideo();
    // Le maître démarre immédiatement — pas de Future.delayed en cascade
    _masterCtrl.forward();
  }

  // ── Vidéo ──────────────────────────────────────────────────────────────────
  Future<void> _initVideo() async {
    if (kIsWeb) return;
    try {
      // ✅ Préférez une URL CDN pour éviter de charger le MP4 en RAM
      // Si vous voulez garder l'asset local, gardez .asset() mais
      // compressez le MP4 à < 5MB et 480p max
      _videoCtrl = VideoPlayerController.asset('assets/images/coran2.mp4');
      await _videoCtrl!.initialize();
      _videoCtrl!
        ..setLooping(true)
        ..setVolume(0.0)
        ..play();
      if (mounted) setState(() => _videoReady = true);
    } catch (e) {
      debugPrint('[Splash] Video fallback: $e');
    }
  }

  // ── Animations ─────────────────────────────────────────────────────────────
  void _initAnimations() {
    // ── Maître 6 secondes ──────────────────────────────────────────────────
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    // Intervals : début/fin en fraction de 6000ms
    // 0ms→600ms   : fade BG
    _bgFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.10, curve: Curves.easeIn)));

    // 600ms→1500ms : livre apparaît
    _bookScaleAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.10, 0.25, curve: Curves.elasticOut)));

    _bookGlowAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.10, 0.25, curve: Curves.easeOut)));

    // 1500ms→3000ms : livre s'ouvre
    _bookOpenAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.25, 0.50, curve: Curves.easeInOut)));

    _bookShadowAnim = Tween<double>(begin: 6, end: 42).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.25, 0.42, curve: Curves.easeOut)));

    // 3000ms→4800ms : verset
    _verseOpacAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.50, 0.52, curve: Curves.easeIn)));

    _verseCharAnim = StepTween(begin: 0, end: _verse.length).animate(
        CurvedAnimation(
            parent: _masterCtrl,
            curve: const Interval(0.50, 0.80, curve: Curves.linear)));

    // 4800ms→6000ms : logos
    _logoFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.80, 0.92, curve: Curves.easeOut)));

    _logoSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.38), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _masterCtrl,
                curve: const Interval(0.80, 0.93, curve: Curves.easeOut)));

    _subtitleFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.88, 1.0, curve: Curves.easeOut)));

    // Listener unique pour le verset
    _masterCtrl.addListener(() {
      if (!mounted) return;
      final n = _verseCharAnim.value.clamp(0, _verse.length);
      if (n != _shownVerse.length) {
        setState(() {
          _shownVerse = _verse.substring(0, n);
          if (n == _verse.length) _verseComplete = true;
        });
      }
    });

    // Navigation à la fin
    _masterCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Get.offAll(() => const NavBarScreen());
      }
    });

    // ── Controllers loopés (inchangés) ──────────────────────────────────────
    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));
    _breatheScaleAnim = Tween<double>(begin: 1.0, end: 1.025).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.8, end: 2.8).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat();
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _masterCtrl.dispose();
    _breatheCtrl.dispose();
    _particleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bp = _BP.of(size.width);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ────────────────────────────────────────────────────
          RepaintBoundary(child: _buildBg()),

          // ── Atmosphère ────────────────────────────────────────────────────
          RepaintBoundary(child: _buildAtmosphere()),

          // ── Particules ────────────────────────────────────────────────────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlesPainter(
                  progress: _particleCtrl.value,
                  opacity:
                      (_bookOpenAnim.value * (1.0 - _logoFadeAnim.value * 0.65))
                          .clamp(0.0, 1.0),
                ),
              ),
            ),
          ),

          // ── Livre 3D ─────────────────────────────────────────────────────
          // RepaintBoundary isole le livre du reste du Stack
          Center(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _masterCtrl,
                  _breatheCtrl,
                  _shimmerCtrl,
                ]),
                builder: (_, __) => _buildBook(size, bp),
              ),
            ),
          ),

          // ── Verset ────────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _masterCtrl,
            builder: (_, __) => _buildVerse(size, bp),
          ),

          // ── Logos ─────────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _masterCtrl,
            builder: (_, __) => _logoFadeAnim.value > 0
                ? _buildLogos(size, bp)
                : const SizedBox.shrink(),
          ),

          // ── Barre de progression ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _masterCtrl,
              builder: (_, __) => _buildProgress(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Background ───────────────────────────────────────────────────────────
  Widget _buildBg() {
    Widget media;
    if (_videoReady && _videoCtrl != null && !kIsWeb) {
      media = FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoCtrl!.value.size.width,
          height: _videoCtrl!.value.size.height,
          child: VideoPlayer(_videoCtrl!),
        ),
      );
    } else {
      media = Image.asset('assets/images/coran1.gif', fit: BoxFit.cover);
    }
    return FadeTransition(
      opacity: _bgFadeAnim,
      child: SizedBox.expand(child: media),
    );
  }

  // ─── Atmosphère ───────────────────────────────────────────────────────────
  Widget _buildAtmosphere() {
    return AnimatedBuilder(
      animation: _bgFadeAnim,
      builder: (_, __) => Opacity(
        opacity: _bgFadeAnim.value,
        child: Stack(fit: StackFit.expand, children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.35,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.80),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  yGoldColor.withOpacity(0.14 * _bookGlowAnim.value),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.82,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Livre 3D ─────────────────────────────────────────────────────────────
  Widget _buildBook(Size size, _BP bp) {
    final bw = bp.bookWidth(size.width);
    final bh = bw * 1.38;
    final op = _bookOpenAnim.value; // 0→1
    final lAngle = -(math.pi / 2.05) * op; // page gauche
    final rAngle = (math.pi / 2.05) * op; // page droite
    final elev = _bookShadowAnim.value;

    return Transform.translate(
      offset: Offset(0, _breatheAnim.value),
      child: Transform.scale(
        scale: _bookScaleAnim.value * _breatheScaleAnim.value,
        child: SizedBox(
          width: bw,
          height: bh,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Ombre
              Positioned(
                bottom: -(elev * 0.42),
                left: bw * 0.1,
                right: bw * 0.1,
                child: Container(
                  height: elev * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(bw * 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: elev * 2,
                        spreadRadius: elev * 0.05,
                      )
                    ],
                  ),
                ),
              ),
              // Page droite
              Positioned(
                left: bw / 2,
                child: _buildPage(
                  w: bw / 2,
                  h: bh,
                  angle: rAngle,
                  isLeft: false,
                  op: op,
                  shimmer: _shimmerAnim.value,
                  bw: bw,
                  bh: bh,
                ),
              ),
              // Page gauche
              Positioned(
                right: bw / 2,
                child: _buildPage(
                  w: bw / 2,
                  h: bh,
                  angle: lAngle,
                  isLeft: true,
                  op: op,
                  shimmer: _shimmerAnim.value,
                  bw: bw,
                  bh: bh,
                ),
              ),
              // Spine
              Positioned(
                left: bw / 2 - 5,
                child: Container(
                  width: 10,
                  height: bh,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF5A3A00),
                        yGoldColor,
                        Color(0xFFEDD97A),
                        yGoldColor,
                        Color(0xFF5A3A00),
                      ],
                      stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: yGoldColor.withOpacity(0.8),
                        blurRadius: 14,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
              // Lueur intérieure
              if (op > 0.5)
                Positioned(
                  left: bw / 2 - 35,
                  top: bh * 0.28,
                  child: Opacity(
                    opacity: ((op - 0.5) / 0.5).clamp(0.0, 0.7),
                    child: Container(
                      width: 70,
                      height: bh * 0.44,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [
                          Colors.white.withOpacity(0.28),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildPage, _buildVerse, _buildLogos, _buildProgress, _decorLine,
  // _gradSegment → IDENTIQUES à votre version originale, aucun changement.
  // Copiez-les tels quels depuis votre fichier actuel.

  Widget _buildPage({
    required double w,
    required double h,
    required double angle,
    required bool isLeft,
    required double op,
    required double shimmer,
    required double bw,
    required double bh,
  }) {
    final br = BorderRadius.only(
      topLeft: isLeft ? const Radius.circular(7) : Radius.zero,
      bottomLeft: isLeft ? const Radius.circular(7) : Radius.zero,
      topRight: isLeft ? Radius.zero : const Radius.circular(7),
      bottomRight: isLeft ? Radius.zero : const Radius.circular(7),
    );
    return Transform(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: ClipRRect(
        borderRadius: br,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                  end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                  colors: const [
                    Color(0xFFF8EEC0),
                    Color(0xFFEDD98A),
                    Color(0xFFE4C870)
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            CustomPaint(
              painter: _PageLinesPainter(isLeft: isLeft),
              size: Size(w, h),
            ),
            if (op < 0.28)
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (r) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Colors.transparent,
                      Color(0xFFFFDB6A),
                      Colors.transparent
                    ],
                    stops: [
                      (shimmer - 0.6).clamp(0.0, 1.0),
                      shimmer.clamp(0.0, 1.0),
                      (shimmer + 0.6).clamp(0.0, 1.0),
                    ],
                  ).createShader(r),
                  blendMode: BlendMode.srcATop,
                  child: Container(
                      color: Colors.white.withOpacity(
                          (0.38 * (1.0 - op * 3.5)).clamp(0.0, 0.38))),
                ),
              ),
            if (op > 0.68)
              Positioned.fill(
                child: Opacity(
                  opacity: ((op - 0.68) / 0.32).clamp(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.08, vertical: h * 0.12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.brightness_3,
                            color: yGoldColor.withOpacity(0.6), size: w * 0.14),
                        SizedBox(height: h * 0.04),
                        Text(
                          isLeft ? 'بِسْمِ اللَّهِ' : 'الرَّحْمَٰنِ الرَّحِيمِ',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.115,
                            color: const Color(0xFF4A2E00),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            height: 1.7,
                          ),
                        ),
                        SizedBox(height: h * 0.04),
                        Icon(Icons.brightness_3,
                            color: yGoldColor.withOpacity(0.6), size: w * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: isLeft ? null : 0,
              right: isLeft ? 0 : null,
              top: 0,
              bottom: 0,
              child: Container(
                width: 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                        isLeft ? Alignment.centerLeft : Alignment.centerRight,
                    end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 9,
              left: isLeft ? 9 : null,
              right: isLeft ? null : 9,
              child: Opacity(
                  opacity: (op * 0.65).clamp(0.0, 0.65),
                  child: Icon(Icons.brightness_3, color: yGoldColor, size: 11)),
            ),
            Positioned(
              bottom: 9,
              left: isLeft ? 9 : null,
              right: isLeft ? null : 9,
              child: Opacity(
                  opacity: (op * 0.65).clamp(0.0, 0.65),
                  child: Icon(Icons.brightness_3, color: yGoldColor, size: 11)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildVerse(Size size, _BP bp) {
    if (_verseOpacAnim.value == 0) return const SizedBox.shrink();
    return Positioned(
      top: size.height * 0.09,
      left: size.width * 0.06,
      right: size.width * 0.06,
      child: Opacity(
        opacity: _verseOpacAnim.value.clamp(0.0, 1.0),
        child: Column(children: [
          _decorLine(),
          const SizedBox(height: 14),
          Stack(alignment: Alignment.center, children: [
            Text(
              _shownVerse,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bp.verseFs,
                fontFamily: 'Poppins',
                foreground: Paint()
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
                  ..color = yGoldColor.withOpacity(0.55),
              ),
            ),
            Text(
              _shownVerse,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bp.verseFs,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: yGoldColor,
                shadows: const [
                  Shadow(color: Color(0xFFF0CB6A), blurRadius: 20),
                  Shadow(color: Color(0xFFD4A843), blurRadius: 6),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),
          if (!_verseComplete)
            Container(
              width: 2,
              height: bp.verseFs,
              decoration: BoxDecoration(
                color: yGoldColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: yGoldColor, blurRadius: 8)],
              ),
            ),
          const SizedBox(height: 10),
          if (_masterCtrl.value > 0.65)
            Opacity(
              opacity: ((_masterCtrl.value - 0.65) / 0.15).clamp(0.0, 1.0),
              child: Text(
                _verseLtn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: bp.subFs,
                  fontWeight: FontWeight.w300,
                  color: yWhiteColor.withOpacity(0.58),
                  letterSpacing: 3.8,
                ),
              ),
            ),
          const SizedBox(height: 14),
          _decorLine(),
        ]),
      ),
    );
  }

  Widget _buildLogos(Size size, _BP bp) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: _logoFadeAnim,
        child: SlideTransition(
          position: _logoSlideAnim,
          child: Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.055),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image(image: const AssetImage(YSplashLogo), height: bp.logoH),
              const SizedBox(height: 14),
              FadeTransition(
                opacity: _subtitleFadeAnim,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      width: size.width * 0.09,
                      height: 1,
                      color: yGoldColor.withOpacity(0.45)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child:
                        Icon(Icons.brightness_3, color: yGoldColor, size: 12),
                  ),
                  Container(
                      width: size.width * 0.09,
                      height: 1,
                      color: yGoldColor.withOpacity(0.45)),
                ]),
              ),
              const SizedBox(height: 13),
              FadeTransition(
                opacity: _subtitleFadeAnim,
                child: Column(children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [yWhiteColor, yGoldLight, yWhiteColor],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(b),
                    child: Text(
                      yAppStartName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: bp.appNameFs,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    yAppMidlleName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: bp.appSubFs,
                      fontWeight: FontWeight.w300,
                      color: yGoldColor.withOpacity(0.88),
                      letterSpacing: 4.2,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _logoFadeAnim,
                child: Image(
                  image: const AssetImage(ySplashImage),
                  height: bp.logoH * 0.72,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      height: 2.5,
      child: LinearProgressIndicator(
        value: _masterCtrl.value,
        backgroundColor: Colors.white.withOpacity(0.07),
        valueColor: AlwaysStoppedAnimation<Color>(yGoldColor.withOpacity(0.85)),
      ),
    );
  }

  Widget _decorLine() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _gradSegment(false),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: yGoldColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: yGoldColor, blurRadius: 7)],
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: yGoldLight,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: yGoldLight, blurRadius: 10)],
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: yGoldColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: yGoldColor, blurRadius: 7)],
        ),
      ),
      _gradSegment(true),
    ]);
  }

  Widget _gradSegment(bool right) => Container(
        width: 55,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: right
                ? [yGoldColor, Colors.transparent]
                : [Colors.transparent, yGoldColor],
          ),
        ),
      );
}

// ─── Breakpoints ──────────────────────────────────────────────────────────────
class _BP {
  final double verseFs, subFs, logoH, appNameFs, appSubFs;
  final double Function(double) bookWidth;
  const _BP({
    required this.verseFs,
    required this.subFs,
    required this.logoH,
    required this.appNameFs,
    required this.appSubFs,
    required this.bookWidth,
  });
  factory _BP.of(double w) {
    if (w >= 1024)
      return _BP(
          verseFs: 33,
          subFs: 15,
          logoH: 112,
          appNameFs: 29,
          appSubFs: 15,
          bookWidth: (_) => 280);
    if (w >= 600)
      return _BP(
          verseFs: 26,
          subFs: 13,
          logoH: 90,
          appNameFs: 23,
          appSubFs: 13,
          bookWidth: (sw) => sw * 0.46);
    return _BP(
        verseFs: 21,
        subFs: 11,
        logoH: 74,
        appNameFs: 20,
        appSubFs: 11,
        bookWidth: (sw) => sw * 0.56);
  }
}

// ─── Painters (inchangés) ─────────────────────────────────────────────────────
class _PageLinesPainter extends CustomPainter {
  final bool isLeft;
  const _PageLinesPainter({required this.isLeft});
  @override
  void paint(Canvas canvas, Size size) {
    final lp = Paint()
      ..color = const Color(0xFFB09030).withOpacity(0.22)
      ..strokeWidth = 0.55;
    double y = 30.0;
    while (y < size.height - 28) {
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), lp);
      y += 16.5;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFFD4A843).withOpacity(0.38)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
    final mx = isLeft ? size.width - 20.0 : 20.0;
    canvas.drawLine(
      Offset(mx, 22),
      Offset(mx, size.height - 22),
      Paint()
        ..color = const Color(0xFFD4A843).withOpacity(0.28)
        ..strokeWidth = 0.7,
    );
  }

  @override
  bool shouldRepaint(_PageLinesPainter o) => false;
}

class _ParticlesPainter extends CustomPainter {
  final double progress, opacity;
  const _ParticlesPainter({required this.progress, required this.opacity});

  static final _pts = List<_Pt>.generate(36, (i) {
    final r = math.Random(i * 131 + 19);
    return _Pt(r.nextDouble(), r.nextDouble() * 2.8 + 0.8,
        r.nextDouble() * 0.22 + 0.07, r.nextDouble(), r.nextDouble() * 24 + 7);
  });

  @override
  void paint(Canvas canvas, Size sz) {
    if (opacity < 0.02) return;
    for (final p in _pts) {
      final t = (progress * p.s + p.ph) % 1.0;
      final dy = (1.0 - t) * sz.height;
      final dx = p.x * sz.width + math.sin(t * math.pi * 2.3 + p.ph * 5) * p.w;
      final a = math.sin(t * math.pi).clamp(0.0, 1.0) * opacity * 0.72;
      if (a < 0.02) continue;
      canvas.drawCircle(
          Offset(dx, dy),
          p.r,
          Paint()
            ..color = yGoldColor.withOpacity(a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.r));
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter o) =>
      o.progress != progress || o.opacity != opacity;
}

class _Pt {
  final double x, r, s, ph, w;
  const _Pt(this.x, this.r, this.s, this.ph, this.w);
}
