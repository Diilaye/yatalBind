import '/utils/colors.dart' as color;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerWidget extends StatefulWidget {
  final String filePath;
  final String? title;

  const PDFViewerWidget({
    super.key,
    required this.filePath,
    this.title,
  });

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget>
    with TickerProviderStateMixin {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  // ✅ Bytes chargés UNE SEULE FOIS en initState
  Uint8List? _pdfBytes;

  int totalPageCount = 0;
  int currentPage = 1;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isToolbarVisible = true;
  bool _isPageInputMode = false;

  late AnimationController _toolbarAnimController;
  late Animation<double> _toolbarFadeAnim;
  late Animation<Offset> _toolbarSlideAnim;
  late AnimationController _loadingAnimController;

  final TextEditingController _pageInputController = TextEditingController();
  final FocusNode _pageInputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadPdfAsset(); // ✅ Chargement immédiat dès l'init
  }

  void _initAnimations() {
    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _toolbarFadeAnim = CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeInOut,
    );
    _toolbarSlideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeOutCubic,
    ));
    _toolbarAnimController.forward();

    _loadingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  /// ✅ Charge le PDF en bytes depuis les assets Flutter
  Future<void> _loadPdfAsset() async {
    try {
      final ByteData data = await rootBundle.load(widget.filePath);
      if (!mounted) return;
      setState(() {
        _pdfBytes = data.buffer.asUint8List();
        // Ne pas mettre _isLoading = false ici
        // → onDocumentLoaded s'en chargera
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _toolbarAnimController.dispose();
    _loadingAnimController.dispose();
    _pageInputController.dispose();
    _pageInputFocus.dispose();
    super.dispose();
  }

  void _toggleToolbar() {
    setState(() => _isToolbarVisible = !_isToolbarVisible);
    if (_isToolbarVisible) {
      _toolbarAnimController.forward();
    } else {
      _toolbarAnimController.reverse();
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPageCount) {
      _pdfController.jumpToPage(page);
    }
  }

  void _submitPageInput() {
    final input = int.tryParse(_pageInputController.text);
    if (input != null) _goToPage(input);
    setState(() => _isPageInputMode = false);
    _pageInputController.clear();
  }

  double get _progress =>
      totalPageCount > 0 ? currentPage / totalPageCount : 0.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F4F0),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // ✅ Le viewer s'affiche dès que les bytes sont prêts
            if (_pdfBytes != null && !_hasError) _buildPdfViewer(),

            if (_isLoading && !_hasError) _buildLoadingOverlay(),
            if (_hasError) _buildErrorView(),
            if (!_isLoading && !_hasError) _buildBottomToolbar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: color.yAccentColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: color.yDarkColor,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            widget.title ?? 'LECTURE PDF',
            style: TextStyle(
              color: color.yDarkColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 1.2,
            ),
          ),
          if (!_isLoading && totalPageCount > 0)
            Text(
              '$totalPageCount page${totalPageCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: color.yDarkColor.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        if (!_isLoading && !_hasError)
          IconButton(
            icon: Icon(Icons.search_rounded, color: color.yDarkColor),
            onPressed: () => _pdfViewerKey.currentState?.openBookmarkView(),
            tooltip: 'Rechercher',
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: _buildProgressBar(),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      child: LinearProgressIndicator(
        value: _isLoading ? null : _progress,
        backgroundColor: color.yAccentColor,
        valueColor: AlwaysStoppedAnimation<Color>(color.yDarkColor),
        minHeight: 3,
      ),
    );
  }

  Widget _buildPdfViewer() {
    return GestureDetector(
      onTap: _toggleToolbar,
      child: SfPdfViewer.memory(
        _pdfBytes!, // ✅ bytes déjà chargés
        key: _pdfViewerKey,
        controller: _pdfController,
        scrollDirection: PdfScrollDirection.vertical,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        enableDoubleTapZooming: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          // ✅ C'est ici qu'on arrête le loading
          setState(() {
            totalPageCount = details.document.pages.count;
            _isLoading = false;
          });
        },
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() => currentPage = details.newPageNumber);
          HapticFeedback.selectionClick();
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xFFF5F4F0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _loadingAnimController,
              builder: (_, __) => Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.yAccentColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.yAccentColor.withValues(alpha: 0.4),
                      blurRadius: 20 * _loadingAnimController.value,
                      spreadRadius: 4 * _loadingAnimController.value,
                    ),
                  ],
                ),
                child: Icon(Icons.picture_as_pdf_rounded,
                    color: color.yDarkColor, size: 32),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement du document…',
              style: TextStyle(
                color: color.yDarkColor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: color.yDarkColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color.yAccentColor),
                borderRadius: BorderRadius.circular(4),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: const Color(0xFFF5F4F0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.red.shade300, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Impossible de charger le PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color.yDarkColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez que le fichier est bien déclaré\ndans pubspec.yaml.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: color.yDarkColor.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Retour'),
                style: FilledButton.styleFrom(
                  backgroundColor: color.yAccentColor,
                  foregroundColor: color.yDarkColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: _toolbarSlideAnim,
        child: FadeTransition(
          opacity: _toolbarFadeAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: color.yDarkColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _toolbarIconBtn(
                      icon: Icons.first_page_rounded,
                      onTap: currentPage > 1 ? () => _goToPage(1) : null,
                    ),
                    _toolbarIconBtn(
                      icon: Icons.chevron_left_rounded,
                      size: 28,
                      onTap: currentPage > 1
                          ? () => _pdfController.previousPage()
                          : null,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPageInputMode = true);
                        Future.delayed(
                          const Duration(milliseconds: 50),
                          () => _pageInputFocus.requestFocus(),
                        );
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isPageInputMode
                            ? _buildPageInput()
                            : _buildPageIndicator(),
                      ),
                    ),
                    _toolbarIconBtn(
                      icon: Icons.chevron_right_rounded,
                      size: 28,
                      onTap: currentPage < totalPageCount
                          ? () => _pdfController.nextPage()
                          : null,
                    ),
                    _toolbarIconBtn(
                      icon: Icons.last_page_rounded,
                      onTap: currentPage < totalPageCount
                          ? () => _goToPage(totalPageCount)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      key: const ValueKey('indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentPage / $totalPageCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Appuyer pour aller à',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageInput() {
    return SizedBox(
      key: const ValueKey('input'),
      width: 90,
      child: TextField(
        controller: _pageInputController,
        focusNode: _pageInputFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Page…',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submitPageInput(),
        onTapOutside: (_) {
          setState(() => _isPageInputMode = false);
          _pageInputController.clear();
        },
      ),
    );
  }

  Widget _toolbarIconBtn({
    required IconData icon,
    VoidCallback? onTap,
    double size = 22,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
