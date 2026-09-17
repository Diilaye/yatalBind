// lib/screen/admin/pages/gallery_admin_screen.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_theme.dart';
import '../../../utils/requette-by-dii.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http_parser/http_parser.dart' as http_parser;

class GalleryAdminScreen extends StatefulWidget {
  const GalleryAdminScreen({super.key});
  @override
  State<GalleryAdminScreen> createState() => _GalleryAdminScreenState();
}

class _GalleryAdminScreenState extends State<GalleryAdminScreen> {
  bool _loading = true;
  List _photos = [];
  List<int> _years = [];
  int? _selYear;
  String? _selType;
  int _page = 1;
  int _total = 0;
  final Set<String> _selected = {};

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
    _loadYears();
    _loadPhotos(reset: true);
  }

  Future<void> _loadYears() async {
    final res = await ApiService().get(url: 'gallery/years');
    if (res.success) {
      setState(() => _years = List<int>.from(res.data['data'] ?? []));
    }
  }

  Future<void> _loadPhotos({bool reset = false}) async {
    setState(() => _loading = true);
    if (reset) {
      _page = 1;
      _photos.clear();
    }

    final params = <String, String>{
      'page': _page.toString(),
      'limit': '20',
      'active': 'all',
      if (_selYear != null) 'year': _selYear.toString(),
      if (_selType != null && _selType != 'all') 'type': _selType!,
    };

    final res = await ApiService().get(url: 'gallery', queryParameters: params);
    if (res.success) {
      setState(() {
        _photos.addAll(res.data['data'] as List);
        _total = res.data['meta']['total'] ?? 0;
      });
    }
    setState(() => _loading = false);
  }

  // ── Suppression en masse ───────────────────────────────────────────────────
  Future<void> _bulkDelete() async {
    if (_selected.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text(
            'Supprimer ${_selected.length} photo(s) ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ApiService().post(
      url: 'gallery/bulk-delete',
      body: {'ids': _selected.toList()},
    );
    _selected.clear();
    _loadPhotos(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          if (_selected.isNotEmpty) _buildBulkBar(),
          Expanded(
            child: _loading && _photos.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
        color: AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Galerie', style: AppTextStyles.pageTitle),
              const SizedBox(height: 4),
              Text('$_total photo(s) au total', style: AppTextStyles.subtitle),
            ]),
            ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _UploadPhotosDialog(onRefresh: () {
                  _loadPhotos(reset: true);
                  _loadYears();
                }),
              ),
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('Uploader des photos'),
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
      );

  // ── Filtres ────────────────────────────────────────────────────────────────
  Widget _buildFilters() => Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(children: [
          // Années
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [null, ..._years].map((y) {
                final sel = _selYear == y;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selYear = y);
                    _loadPhotos(reset: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : AppColors.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border),
                    ),
                    child: Text(y == null ? 'Toutes' : y.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: sel ? Colors.white : AppColors.textDark,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Types
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _types.map((t) {
                final sel = _selType == t || (_selType == null && t == 'all');
                return GestureDetector(
                  onTap: () {
                    setState(() => _selType = t == 'all' ? null : t);
                    _loadPhotos(reset: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.accentLight.withOpacity(0.15)
                          : AppColors.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border),
                    ),
                    child: Text(t,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? AppColors.accent : AppColors.textDark,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      );

  // ── Barre sélection multiple ───────────────────────────────────────────────
  Widget _buildBulkBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: AppColors.accent.withOpacity(0.08),
        child: Row(children: [
          Text('${_selected.length} sélectionné(s)',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.accent)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _selected.clear()),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Désélectionner'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ]),
      );

  // ── Grille photos ──────────────────────────────────────────────────────────
  Widget _buildGrid() {
    if (_photos.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.photo_library_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Aucune photo', style: TextStyle(color: AppColors.textMuted)),
        ]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemCount: _photos.length,
      itemBuilder: (_, i) {
        final p = _photos[i];
        final id = p['id'] ?? p['_id'] ?? '';
        final sel = _selected.contains(id);

        return GestureDetector(
          onTap: () => setState(() {
            sel ? _selected.remove(id) : _selected.add(id);
          }),
          onLongPress: () => _showPhotoOptions(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    p['thumbnailUrl'] ?? p['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bg,
                      child:
                          const Icon(Icons.image, color: AppColors.textMuted),
                    ),
                  ),
                  // Overlay sélection
                  if (sel)
                    Container(
                      color: AppColors.accent.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                  // Info bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Row(children: [
                            Text(
                              '${p['year'] ?? ''} · ${p['type'] ?? ''}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 9,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p['isActive'] == true
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPhotoOptions(Map p) {
    final id = p['id'] ?? p['_id'] ?? '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                p['isActive'] == true
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.accent,
              ),
              title: Text(p['isActive'] == true ? 'Désactiver' : 'Activer'),
              onTap: () async {
                Navigator.pop(context);
                await ApiService().patch(
                  url: 'gallery/$id',
                  body: {'isActive': !(p['isActive'] == true)},
                );
                _loadPhotos(reset: true);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ApiService().delete(url: 'gallery/$id');
                _loadPhotos(reset: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog upload photos
// ─────────────────────────────────────────────────────────────────────────────
class _UploadPhotosDialog extends StatefulWidget {
  final VoidCallback onRefresh;
  const _UploadPhotosDialog({required this.onRefresh});

  @override
  State<_UploadPhotosDialog> createState() => _UploadPhotosDialogState();
}

class _UploadPhotosDialogState extends State<_UploadPhotosDialog> {
  final _titleCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  int _year = DateTime.now().year;
  String _type = 'autre';
  List<PlatformFile> _files = [];
  bool _uploading = false;

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() => _files = result.files);
    }
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.isEmpty || _files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Titre et images requis')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final token = await ApiService().getToken();
      final uri = Uri.parse('${ApiConfig.fullBaseUrl}/gallery');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // ── Champs texte ──────────────────────────────────────────────
      request.fields['title'] = _titleCtrl.text.trim();
      request.fields['titleAr'] = _titleArCtrl.text.trim();
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['year'] = _year.toString();
      request.fields['type'] = _type;
      request.fields['tags'] = _tagsCtrl.text.trim();

      // ── Fichiers images ───────────────────────────────────────────
      for (final f in _files) {
        if (f.bytes == null || f.bytes!.isEmpty) continue;

        // ✅ Détecter le contentType depuis l'extension
        final ext = f.extension?.toLowerCase() ?? 'jpg';
        final contentType = _getMimeType(ext);

        request.files.add(
          http.MultipartFile.fromBytes(
            'images', // ← doit correspondre à upload.array('images')
            f.bytes!,
            filename: f.name,
            contentType: contentType, // ✅ CRUCIAL sur Flutter Web
          ),
        );
      }

      if (kDebugMode) {
        print('📤 Uploading ${request.files.length} file(s) to ${uri}');
        print('📋 Fields: ${request.fields}');
      }

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        print('📥 Upload response: ${response.statusCode}');
        print('📥 Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photos uploadées avec succès ✓'),
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
      if (kDebugMode) print('❌ Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// ✅ Retourne le MediaType correct selon l'extension
  http_parser.MediaType _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return http_parser.MediaType('image', 'jpeg');
      case 'png':
        return http_parser.MediaType('image', 'png');
      case 'webp':
        return http_parser.MediaType('image', 'webp');
      case 'gif':
        return http_parser.MediaType('image', 'gif');
      default:
        return http_parser.MediaType('image', 'jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Uploader des photos',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone drop images
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border,
                        width: 2,
                        style: BorderStyle.solid),
                  ),
                  child: _files.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_rounded,
                                size: 42, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            const Text('Cliquer pour sélectionner',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600)),
                            Text('JPG, PNG, WEBP — max 10MB',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: _files.length,
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                _files[i].bytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              if (_files.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_files.length} image(s) sélectionnée(s)',
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              _field('Titre', _titleCtrl),
              const SizedBox(height: 10),
              _field('Titre (arabe)', _titleArCtrl),
              const SizedBox(height: 10),
              _field('Description', _descCtrl),
              const SizedBox(height: 10),
              _field('Tags (séparés par virgule)', _tagsCtrl,
                  hint: 'finale, 2024, ceremonie'),
              const SizedBox(height: 10),

              // Année
              Row(children: [
                const SizedBox(
                    width: 120,
                    child: Text('Année', style: AppTextStyles.tableHeader)),
                DropdownButton<int>(
                  value: _year,
                  items: List.generate(10, (i) {
                    final y = DateTime.now().year - i;
                    return DropdownMenuItem(value: y, child: Text('$y'));
                  }),
                  onChanged: (v) => setState(() => _year = v!),
                ),
              ]),
              const SizedBox(height: 10),

              // Type
              Row(children: [
                const SizedBox(
                    width: 120,
                    child: Text('Type', style: AppTextStyles.tableHeader)),
                DropdownButton<String>(
                  value: _type,
                  items: [
                    'ceremonie',
                    'concours',
                    'coulisses',
                    'laureats',
                    'autre'
                  ]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
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
          onPressed: _uploading ? null : _upload,
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
              : Text(
                  'Uploader ${_files.length > 0 ? '(${_files.length})' : ''}'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.tableHeader),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          decoration: AppDecorations.searchField(hint: hint ?? label),
          style: AppTextStyles.cellPrimary,
        ),
      ]);
}
