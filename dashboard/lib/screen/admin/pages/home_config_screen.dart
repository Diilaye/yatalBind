// lib/screen/admin/pages/home_config_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/app_theme.dart';
import '../../../utils/requette-by-dii.dart'; // votre ApiService
import '../widgets/shared/shared_widgets.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http_parser/http_parser.dart' as http_parser;

class HomeConfigScreen extends StatefulWidget {
  const HomeConfigScreen({super.key});
  @override
  State<HomeConfigScreen> createState() => _HomeConfigScreenState();
}

class _HomeConfigScreenState extends State<HomeConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = true;
  Map<String, dynamic> _config = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadConfig();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Chargement ─────────────────────────────────────────────────────────────
  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService().get(url: 'home-config');
      if (res.success) {
        setState(() => _config = res.data['data'] ?? {});
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(),

          // ── Tabs ─────────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Slider'),
                Tab(text: 'Catégories'),
                Tab(text: 'Textes & Sections'),
              ],
            ),
          ),

          // ── Corps ─────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _SliderTab(config: _config, onRefresh: _loadConfig),
                      _CategoriesTab(config: _config, onRefresh: _loadConfig),
                      _TextsSectionsTab(
                          config: _config, onRefresh: _loadConfig),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
        color: AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gestion Home Screen', style: AppTextStyles.pageTitle),
              const SizedBox(height: 4),
              Text('Slider • Catégories • Textes',
                  style: AppTextStyles.subtitle),
            ]),
            IconButton(
              onPressed: _loadConfig,
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.accent,
              tooltip: 'Rafraîchir',
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglet Slider
// ─────────────────────────────────────────────────────────────────────────────
class _SliderTab extends StatelessWidget {
  final Map<String, dynamic> config;
  final VoidCallback onRefresh;
  const _SliderTab({required this.config, required this.onRefresh});

  List get sliders => (config['sliders'] as List? ?? []);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton ajouter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${sliders.length} slide(s)', style: AppTextStyles.subtitle),
              ElevatedButton.icon(
                onPressed: () => _showAddSlider(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter un slide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Liste des slides
          Expanded(
            child: sliders.isEmpty
                ? const Center(child: Text('Aucun slide'))
                : ListView.separated(
                    itemCount: sliders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _SliderCard(slide: sliders[i], onRefresh: onRefresh),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddSlider(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddSliderDialog(onRefresh: onRefresh),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final Map<String, dynamic> slide;
  final VoidCallback onRefresh;
  const _SliderCard({required this.slide, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            slide['imageUrl'] ?? '',
            width: 100,
            height: 65,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 65,
              color: AppColors.bg,
              child: const Icon(Icons.image, color: AppColors.textMuted),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  slide['title']?.isNotEmpty == true
                      ? slide['title']
                      : '(sans titre)',
                  style: AppTextStyles.cellPrimary),
              if (slide['subtitle']?.isNotEmpty == true)
                Text(slide['subtitle'], style: AppTextStyles.cellSecondary),
              const SizedBox(height: 6),
              Row(children: [
                _badge(
                  slide['isActive'] == true ? 'Actif' : 'Inactif',
                  slide['isActive'] == true
                      ? AppColors.tagGreen
                      : AppColors.tagRed,
                  slide['isActive'] == true
                      ? AppColors.tagGreenFg
                      : AppColors.tagRedFg,
                ),
                const SizedBox(width: 8),
                Text('Ordre: ${slide['order'] ?? 0}',
                    style: AppTextStyles.cellMuted),
              ]),
            ],
          ),
        ),

        // Actions
        PopupMenuButton<String>(
          onSelected: (action) async {
            if (action == 'toggle') {
              await ApiService().patch(
                url: 'home-config/sliders/${slide['id'] ?? slide['_id']}',
                body: {'isActive': !(slide['isActive'] == true)},
              );
              onRefresh();
            } else if (action == 'delete') {
              await ApiService().delete(
                url: 'home-config/sliders/${slide['id'] ?? slide['_id']}',
              );
              onRefresh();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(slide['isActive'] == true ? 'Désactiver' : 'Activer'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: AppDecorations.tag(bg),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog — Ajouter slide
// ─────────────────────────────────────────────────────────────────────────────
class _AddSliderDialog extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AddSliderDialog({required this.onRefresh});

  @override
  State<_AddSliderDialog> createState() => _AddSliderDialogState();
}

class _AddSliderDialogState extends State<_AddSliderDialog> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_imageBytes == null || _imageBytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une image')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final token = await ApiService().getToken();
      final uri = Uri.parse('${ApiConfig.fullBaseUrl}/home-config/sliders');

      final ext = _imageName?.split('.').last.toLowerCase() ?? 'jpg';
      final contentType = _getMimeType(ext);

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // ── Champs ────────────────────────────────────────────────────
      request.fields['title'] = _titleCtrl.text.trim();
      request.fields['subtitle'] = _subtitleCtrl.text.trim();
      request.fields['actionUrl'] = _actionCtrl.text.trim();

      // ── Image ─────────────────────────────────────────────────────
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // ← doit correspondre à upload.single('image')
          _imageBytes!,
          filename: _imageName ?? 'slide.jpg',
          contentType: contentType, // ✅ CRUCIAL sur Flutter Web
        ),
      );

      if (kDebugMode) {
        print('📤 Uploading slider image: $_imageName');
        print('📋 Fields: ${request.fields}');
      }

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        print('📥 Slider response: ${response.statusCode}');
        print('📥 Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slide ajouté avec succès ✓'),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onRefresh();
      } else {
        Map<String, dynamic> body = {};
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Erreur ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Slider upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  http.MediaType _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return http.MediaType('image', 'jpeg');
      case 'png':
        return http.MediaType('image', 'png');
      case 'webp':
        return http.MediaType('image', 'webp');
      default:
        return http.MediaType('image', 'jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Ajouter un slide',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_rounded,
                                size: 36, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            Text('Cliquer pour choisir une image',
                                style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _field('Titre', _titleCtrl),
              const SizedBox(height: 12),
              _field('Sous-titre', _subtitleCtrl),
              const SizedBox(height: 12),
              _field('URL action (optionnel)', _actionCtrl),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _uploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Uploader'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tableHeader),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            decoration: AppDecorations.searchField(hint: label),
            style: AppTextStyles.cellPrimary,
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglet Catégories
// ─────────────────────────────────────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  final Map<String, dynamic> config;
  final VoidCallback onRefresh;
  const _CategoriesTab({required this.config, required this.onRefresh});

  List get cats => (config['categories'] as List? ?? []);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cats.length} catégorie(s)',
                  style: AppTextStyles.subtitle),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AddCategoryDialog(onRefresh: onRefresh),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cats.isEmpty
                ? const Center(child: Text('Aucune catégorie'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (_, i) =>
                        _CategoryCard(cat: cats[i], onRefresh: onRefresh),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> cat;
  final VoidCallback onRefresh;
  const _CategoryCard({required this.cat, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(
          'FF${(cat['color'] as String).replaceFirst('#', '')}',
          radix: 16));
    } catch (_) {
      color = AppColors.accent;
    }

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Icône
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: ClipOval(
              child: cat['iconUrl']?.isNotEmpty == true
                  ? Image.network(cat['iconUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.category, color: color, size: 28))
                  : Icon(Icons.category, color: color, size: 28),
            ),
          ),
          const SizedBox(height: 10),
          Text(cat['label'] ?? '',
              style: AppTextStyles.cellPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(cat['youtubePlaylistUrl'] ?? '',
              style: AppTextStyles.cellMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconBtn(
                icon: cat['isActive'] == true
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textMuted,
                onTap: () async {
                  await ApiService().patch(
                    url: 'home-config/categories/${cat['id'] ?? cat['_id']}',
                    body: {'isActive': !(cat['isActive'] == true)},
                  );
                  onRefresh();
                },
              ),
              _iconBtn(
                icon: Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                onTap: () async {
                  await ApiService().delete(
                      url: 'home-config/categories/${cat['id'] ?? cat['_id']}');
                  onRefresh();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
          {required IconData icon,
          required Color color,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog Ajouter catégorie
// ─────────────────────────────────────────────────────────────────────────────
class _AddCategoryDialog extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AddCategoryDialog({required this.onRefresh});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _labelCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  String _color = '#084D27';
  Uint8List? _iconBytes;
  String? _iconName;
  bool _uploading = false;

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (result?.files.single.bytes != null) {
      setState(() {
        _iconBytes = result!.files.single.bytes;
        _iconName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_labelCtrl.text.isEmpty || _urlCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Label et URL requis')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final token = await ApiService().getToken();
      final uri = Uri.parse('${ApiConfig.fullBaseUrl}/home-config/categories');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['label'] = _labelCtrl.text.trim();
      request.fields['youtubePlaylistUrl'] = _urlCtrl.text.trim();
      request.fields['youtubePlaylistId'] = _idCtrl.text.trim();
      request.fields['color'] = _color;

      // ── Icône (optionnelle) ───────────────────────────────────────
      if (_iconBytes != null && _iconBytes!.isNotEmpty) {
        final ext = _iconName?.split('.').last.toLowerCase() ?? 'jpg';
        final contentType = _getMimeType(ext);
        request.files.add(
          http.MultipartFile.fromBytes(
            'icon',
            _iconBytes!,
            filename: _iconName ?? 'icon.jpg',
            contentType: contentType,
          ),
        );
      }

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
        widget.onRefresh();
      } else {
        Map<String, dynamic> body = {};
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(body['message'] ?? 'Erreur')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  http_parser.MediaType _getMimeType(String ext) {
    switch (ext) {
      case 'png':
        return http_parser.MediaType('image', 'png');
      case 'webp':
        return http_parser.MediaType('image', 'webp');
      default:
        return http_parser.MediaType('image', 'jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nouvelle catégorie',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickIcon,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: _iconBytes != null
                      ? ClipOval(
                          child: Image.memory(_iconBytes!, fit: BoxFit.cover))
                      : const Icon(Icons.add_photo_alternate,
                          size: 32, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              _field('Label', _labelCtrl, hint: 'Ex: Musique'),
              const SizedBox(height: 12),
              _field('URL Playlist YouTube', _urlCtrl,
                  hint: 'https://youtube.com/playlist?list=...'),
              const SizedBox(height: 12),
              _field('ID Playlist (optionnel)', _idCtrl, hint: 'PLxxxxxxx'),
              const SizedBox(height: 12),
              // Sélecteur couleur simple
              Row(children: [
                const Text('Couleur : ', style: AppTextStyles.tableHeader),
                ...[
                  '#084D27',
                  '#E53935',
                  '#1E88E5',
                  '#8E24AA',
                  '#F57C00',
                ].map((c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(int.parse('FF${c.replaceFirst('#', '')}',
                              radix: 16)),
                          border: Border.all(
                            color: _color == c
                                ? Colors.black54
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _uploading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _uploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Créer'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tableHeader),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            decoration: AppDecorations.searchField(hint: hint ?? label),
            style: AppTextStyles.cellPrimary,
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglet Textes & Sections
// ─────────────────────────────────────────────────────────────────────────────
class _TextsSectionsTab extends StatefulWidget {
  final Map<String, dynamic> config;
  final VoidCallback onRefresh;
  const _TextsSectionsTab({required this.config, required this.onRefresh});

  @override
  State<_TextsSectionsTab> createState() => _TextsSectionsTabState();
}

class _TextsSectionsTabState extends State<_TextsSectionsTab> {
  final Map<String, TextEditingController> _textCtrls = {};
  List<Map<String, dynamic>> _sections = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs textes
    for (final e in (widget.config['texts'] as List? ?? [])) {
      _textCtrls[e['key']] = TextEditingController(text: e['value']);
    }
    // Sections
    _sections =
        List<Map<String, dynamic>>.from(widget.config['sections'] ?? []);
  }

  @override
  void dispose() {
    _textCtrls.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _saveTexts() async {
    setState(() => _saving = true);
    try {
      final texts = _textCtrls.entries
          .map((e) => {'key': e.key, 'value': e.value.text})
          .toList();
      await ApiService()
          .patch(url: 'home-config/texts', body: {'texts': texts});
      widget.onRefresh();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Textes sauvegardés ✓')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _saveSections() async {
    setState(() => _saving = true);
    try {
      await ApiService()
          .patch(url: 'home-config/sections', body: {'sections': _sections});
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sections sauvegardées ✓')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Textes ────────────────────────────────────────────────────
          _sectionTitle('Textes dynamiques'),
          const SizedBox(height: 16),
          ..._textCtrls.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  SizedBox(
                    width: 180,
                    child: Text(e.key, style: AppTextStyles.cellPrimary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      decoration: AppDecorations.searchField(hint: e.key),
                      style: AppTextStyles.cellPrimary,
                    ),
                  ),
                ]),
              )),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveTexts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sauvegarder les textes'),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // ── Sections ──────────────────────────────────────────────────
          _sectionTitle('Ordre & visibilité des sections'),
          const SizedBox(height: 4),
          Text('Cochez/décochez pour afficher/masquer une section.',
              style: AppTextStyles.subtitle),
          const SizedBox(height: 16),

          ..._sections.asMap().entries.map((entry) {
            final i = entry.key;
            final s = _sections[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: AppDecorations.card(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                // Ordre
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${s['order'] ?? i}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        )),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    s['key']?.toString().toUpperCase() ?? '',
                    style: AppTextStyles.cellPrimary,
                  ),
                ),
                // Basculer visibilité
                Switch(
                  value: s['isVisible'] ?? true,
                  activeColor: AppColors.accent,
                  onChanged: (v) =>
                      setState(() => _sections[i]['isVisible'] = v),
                ),
                // Monter
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  onPressed: i > 0
                      ? () => setState(() {
                            final tmp = _sections[i - 1];
                            _sections[i - 1] = _sections[i]..['order'] = i - 1;
                            _sections[i] = tmp..['order'] = i;
                          })
                      : null,
                ),
                // Descendre
                IconButton(
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  onPressed: i < _sections.length - 1
                      ? () => setState(() {
                            final tmp = _sections[i + 1];
                            _sections[i + 1] = _sections[i]..['order'] = i + 1;
                            _sections[i] = tmp..['order'] = i;
                          })
                      : null,
                ),
              ]),
            );
          }),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveSections,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sauvegarder les sections'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ));
}
