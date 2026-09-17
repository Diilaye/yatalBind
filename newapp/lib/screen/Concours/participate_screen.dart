import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/utils/colors.dart' as color;
import '/utils/images_string.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const String _kBaseUrl = 'https://api.yaatalmbindumalxuran.sn';
const String _kQueueKey = 'pending_submissions_v2';
const int _kMaxFileSizeBytes = 10 * 1024 * 1024; // 10 Mo
const int _kMaxFiles = 3;
const int _kMaxRetries = 3;
const Duration _kRetryDelay = Duration(seconds: 4);
const Duration _kTimeout = Duration(seconds: 60);

const List<String> _kAllowedExtensions = [
  'pdf',
  'doc',
  'docx',
  'jpg',
  'jpeg',
  'png',
  'webp',
];

final RegExp _kDangerousCharsRegex = RegExp(r'''[<>"'`;\\${}]''');

// ─── Modèle fichier sélectionné ───────────────────────────────────────────────

class _PickedFile {
  final Uint8List bytes;
  final String name;
  final String ext;
  final String mime;

  const _PickedFile({
    required this.bytes,
    required this.name,
    required this.ext,
    required this.mime,
  });

  bool get isImage => ['jpg', 'jpeg', 'png', 'webp'].contains(ext);

  String get sizeLabel {
    final sz = bytes.length;
    return sz >= 1024 * 1024
        ? '${(sz / 1024 / 1024).toStringAsFixed(1)} Mo'
        : '${(sz / 1024).toStringAsFixed(0)} Ko';
  }
}

// ─── Modèle soumission en attente ─────────────────────────────────────────────

class _PendingSubmission {
  final String id;
  final Map<String, String> fields;
  final List<Map<String, String>>
      filesMeta; // {name, mime, sizeLabel} seulement
  int retryCount;
  final DateTime createdAt;

  _PendingSubmission({
    required this.id,
    required this.fields,
    required this.filesMeta,
    this.retryCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fields': fields,
        'filesMeta': filesMeta,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory _PendingSubmission.fromJson(Map<String, dynamic> j) =>
      _PendingSubmission(
        id: j['id'],
        fields: Map<String, String>.from(j['fields']),
        filesMeta: List<Map<String, String>>.from(
          (j['filesMeta'] as List).map((e) => Map<String, String>.from(e)),
        ),
        retryCount: j['retryCount'] ?? 0,
        createdAt: DateTime.parse(j['createdAt']),
      );
}

// ─── Service file d'attente ───────────────────────────────────────────────────

class _QueueService {
  static Future<List<_PendingSubmission>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kQueueKey) ?? [];
      return raw
          .map((e) => _PendingSubmission.fromJson(jsonDecode(e)))
          .toList();
    } catch (e) {
      debugPrint('[queue] Erreur chargement : $e');
      return [];
    }
  }

  static Future<void> _save(List<_PendingSubmission> q) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _kQueueKey, q.map((e) => jsonEncode(e.toJson())).toList());
    } catch (e) {
      debugPrint('[queue] Erreur sauvegarde : $e');
      // QuotaExceededError géré ici — on ne crash pas
    }
  }

  static Future<void> add(_PendingSubmission s) async {
    final q = await load();
    // ✅ Éviter les doublons par id
    q.removeWhere((e) => e.id == s.id);
    q.add(s);
    await _save(q);
  }

  static Future<void> remove(String id) async {
    final q = await load();
    q.removeWhere((e) => e.id == id);
    await _save(q);
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kQueueKey);
    } catch (_) {}
  }

  static Future<void> incrementRetry(String id) async {
    final q = await load();
    final i = q.indexWhere((e) => e.id == id);
    if (i != -1) q[i].retryCount++;
    await _save(q);
  }
}

// ─── Écran principal ──────────────────────────────────────────────────────────

class ParticipateScreen extends StatefulWidget {
  const ParticipateScreen({super.key});

  @override
  State<ParticipateScreen> createState() => _ParticipateScreenState();
}

class _ParticipateScreenState extends State<ParticipateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _professorCtrl = TextEditingController();
  String _sexe = 'masculin';
  final List<_PickedFile> _pickedFiles = [];

  bool _isLoading = false;
  bool _isCompressing = false;
  double _uploadProgress = 0.0;
  String _loadingLabel = '';
  bool _isOnline = true;
  int _pendingCount = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
    _initConnectivity();
    _loadPendingCount();
  }

  Future<void> _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateOnlineStatus(results);
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) async {
      _updateOnlineStatus(results);
      if (_isOnline) await _flushQueue();
    });
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (mounted) setState(() => _isOnline = online);
  }

  Future<void> _loadPendingCount() async {
    final q = await _QueueService.load();
    if (mounted) setState(() => _pendingCount = q.length);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _connectivitySub.cancel();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _addressCtrl.dispose();
    _schoolCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _sanitize(String v) => v.replaceAll(_kDangerousCharsRegex, '').trim();

  bool _validatePhone(String p) =>
      RegExp(r'^(77|78|75|76|70)\d{7}$').hasMatch(p);

  bool _validateAge(DateTime d) {
    final now = DateTime.now();
    int age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) age--;
    return age >= 4 && age <= 42;
  }

  String _mimeFromExt(String ext) =>
      const {
        'pdf': 'application/pdf',
        'doc': 'application/msword',
        'docx':
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
      }[ext] ??
      'application/octet-stream';

  // ─── Compression ───────────────────────────────────────────────────────────

  Future<Uint8List> _compressIfNeeded(Uint8List bytes, String ext) async {
    if (bytes.length <= _kMaxFileSizeBytes) return bytes;
    int quality = 80;
    Uint8List result = bytes;
    final format = ext == 'png'
        ? CompressFormat.png
        : ext == 'webp'
            ? CompressFormat.webp
            : CompressFormat.jpeg;
    while (result.length > _kMaxFileSizeBytes && quality >= 20) {
      result = await FlutterImageCompress.compressWithList(bytes,
          quality: quality, format: format);
      quality -= 15;
    }
    return result;
  }

  // ─── Pipeline commun — toutes sources passent ici ─────────────────────────

  Future<void> _processPicked(Uint8List bytes, String fileName) async {
    if (_pickedFiles.length >= _kMaxFiles) {
      _showSnack('Maximum $_kMaxFiles fichiers autorisés.', isError: true);
      return;
    }
    final ext =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (ext.isEmpty || !_kAllowedExtensions.contains(ext)) {
      _showSnack('Extension non autorisée.', isError: true);
      return;
    }
    Uint8List finalBytes = bytes;
    final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
    if (isImage && bytes.length > _kMaxFileSizeBytes) {
      setState(() {
        _isCompressing = true;
        _loadingLabel = 'Compression...';
      });
      try {
        finalBytes = await _compressIfNeeded(bytes, ext);
        final saved = ((bytes.length - finalBytes.length) / 1024).round();
        _showSnack('Image compressée (−$saved Ko)');
      } catch (_) {
        _showSnack('Compression échouée, original conservé.');
      } finally {
        if (mounted) setState(() => _isCompressing = false);
      }
    } else if (!isImage && bytes.length > _kMaxFileSizeBytes) {
      final mb = (bytes.length / 1024 / 1024).toStringAsFixed(1);
      _showSnack('Document trop lourd ($mb Mo, max 10 Mo).', isError: true);
      return;
    }
    setState(() => _pickedFiles.add(_PickedFile(
          bytes: finalBytes,
          name: fileName,
          ext: ext,
          mime: _mimeFromExt(ext),
        )));
  }

  // ─── Sources ───────────────────────────────────────────────────────────────

  Future<void> _pickCamera() async {
    final f =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (f == null) return;
    await _processPicked(await f.readAsBytes(), f.name);
  }

  Future<void> _pickGallery() async {
    final f =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (f == null) return;
    await _processPicked(await f.readAsBytes(), f.name);
  }

  Future<void> _pickFile() async {
    final remaining = _kMaxFiles - _pickedFiles.length;
    FilePickerResult? r;
    try {
      r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _kAllowedExtensions,
        withData: true,
        allowMultiple: remaining > 1,
      );
    } catch (_) {
      _showSnack('Erreur sélection.', isError: true);
      return;
    }
    if (r == null || r.files.isEmpty) return;
    for (final pf in r.files) {
      if (_pickedFiles.length >= _kMaxFiles) break;
      if (pf.bytes == null || pf.bytes!.isEmpty) continue;
      await _processPicked(pf.bytes!, pf.name);
    }
  }

  void _removeFile(int index) => setState(() => _pickedFiles.removeAt(index));

  // ─── Date ──────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
              primary: color.yDarkColor, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d == null) return;
    if (!_validateAge(d)) {
      _showSnack('Âge entre 4 et 42 ans.', isError: true);
      return;
    }
    setState(() => _birthDateCtrl.text = DateFormat('yyyy-MM-dd').format(d));
  }

  // ─── Champs ────────────────────────────────────────────────────────────────

  Map<String, String> _buildFields() {
    final m = <String, String>{
      'prenom': _sanitize(_firstNameCtrl.text),
      'nom': _sanitize(_lastNameCtrl.text),
      'telephone': _phoneCtrl.text.trim(),
      'sexe': _sexe,
    };
    if (_birthDateCtrl.text.isNotEmpty) {
      m['dateNaissance'] = _birthDateCtrl.text.trim();
    }
    if (_addressCtrl.text.isNotEmpty) {
      m['adresse'] = _sanitize(_addressCtrl.text);
    }
    if (_schoolCtrl.text.isNotEmpty) m['ecole'] = _sanitize(_schoolCtrl.text);
    if (_professorCtrl.text.isNotEmpty) {
      m['professeur'] = _sanitize(_professorCtrl.text);
    }
    return m;
  }

  // ─── Envoi HTTP ───────────────────────────────────────────────────────────

  Future<bool> _sendRequest(
      Map<String, String> fields, List<_PickedFile> files) async {
    final uri = Uri.parse('$_kBaseUrl/api/v1/candidatures/inscrire');
    final request = http.MultipartRequest('POST', uri);
    fields.forEach((k, v) => request.fields[k] = v);
    for (final f in files) {
      final parts = f.mime.split('/');
      request.files.add(http.MultipartFile.fromBytes(
        'fichierJustificatif',
        f.bytes,
        filename: f.name,
        contentType: MediaType(parts[0], parts[1]),
      ));
    }
    final streamed = await request.send().timeout(_kTimeout);
    final responseBytes = BytesBuilder();
    await for (final chunk in streamed.stream) {
      responseBytes.add(chunk);
      if (mounted) {
        setState(
            () => _uploadProgress = (_uploadProgress + 0.04).clamp(0.0, 0.95));
      }
    }
    if (mounted) setState(() => _uploadProgress = 1.0);
    final response = http.Response(
      utf8.decode(responseBytes.toBytes()),
      streamed.statusCode,
      headers: streamed.headers,
    );
    debugPrint('[send] ${response.statusCode} — ${response.body}');
    return response.statusCode == 201;
  }

  // ─── Soumission ────────────────────────────────────────────────────────────

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_pickedFiles.isEmpty) {
      _showSnack('Joignez au moins un document justificatif.', isError: true);
      return;
    }
    final fields = _buildFields();
    final files = List<_PickedFile>.from(_pickedFiles);
    if (!_isOnline) {
      await _enqueue(fields, files);
      _showSnack(
          'Hors ligne — soumission sauvegardée, envoi automatique dès reconnexion.');
      _resetForm();
      return;
    }
    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
      _loadingLabel = 'Envoi en cours...';
    });
    bool success = false;
    for (int attempt = 1; attempt <= _kMaxRetries; attempt++) {
      try {
        success = await _sendRequest(fields, files);
        if (success) break;
      } on TimeoutException {
        debugPrint('[submit] Timeout — attempt $attempt');
      } catch (e) {
        debugPrint('[submit] attempt $attempt — $e');
      }
      if (attempt < _kMaxRetries) {
        setState(() {
          _loadingLabel = 'Nouvelle tentative ($attempt/$_kMaxRetries)...';
          _uploadProgress = 0.0;
        });
        await Future.delayed(_kRetryDelay);
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _uploadProgress = 0.0;
    });
    if (success) {
      _showSnack('Inscription enregistrée avec succès ! ✓');
      _resetForm();
    } else {
      await _enqueue(fields, files);
      _showSnack('Échec réseau — soumission sauvegardée pour envoi ultérieur.',
          isError: true);
      _resetForm();
    }
  }

  // ─── Queue ─────────────────────────────────────────────────────────────────

  Future<void> _enqueue(
      Map<String, String> fields, List<_PickedFile> files) async {
    await _QueueService.add(_PendingSubmission(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      fields: fields,
      filesMeta: files
          .map((f) =>
              {'name': f.name, 'base64': base64Encode(f.bytes), 'mime': f.mime})
          .toList(),
      createdAt: DateTime.now(),
    ));
    await _loadPendingCount();
  }

  Future<void> _flushQueue() async {
    final queue = await _QueueService.load();
    if (queue.isEmpty) return;
    for (final sub in queue) {
      if (sub.retryCount >= _kMaxRetries) continue;
      try {
        final files = sub.filesMeta
            .map((f) => _PickedFile(
                  bytes: base64Decode(f['base64']!),
                  name: f['name']!,
                  ext: f['name']!.split('.').last.toLowerCase(),
                  mime: f['mime']!,
                ))
            .toList();
        final ok = await _sendRequest(sub.fields, files);
        if (ok) {
          await _QueueService.remove(sub.id);
        } else {
          await _QueueService.incrementRetry(sub.id);
        }
      } catch (e) {
        await _QueueService.incrementRetry(sub.id);
        debugPrint('[queue] Échec ${sub.id} : $e');
      }
    }
    await _loadPendingCount();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _phoneCtrl,
      _birthDateCtrl,
      _addressCtrl,
      _schoolCtrl,
      _professorCtrl
    ]) {
      c.clear();
    }
    setState(() {
      _pickedFiles.clear();
      _sexe = 'masculin';
    });
  }

  // ─── Snackbar ──────────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 18),
        const SizedBox(width: 8),
        // ✅ FIX: Flexible au lieu de Expanded dans SnackBar (contexte non borné possible)
        Flexible(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor:
          isError ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(14),
      duration: Duration(seconds: isError ? 5 : 3),
    ));
  }

  // ─── Bottom sheet ──────────────────────────────────────────────────────────

  void _showSourceSheet() {
    final remaining = _kMaxFiles - _pickedFiles.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Ajouter votre Mbind/ أضف كتابتك',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color.yDarkColor)),
          const SizedBox(height: 4),
          Text(
            'PDF, DOC, DOCX, JPG, PNG, WEBP  •  Max 10 Mo\n$remaining emplacement(s) restant(s)',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // ✅ Row sans Expanded — spaceEvenly distribue l'espace uniformément
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!kIsWeb) ...[
                _sourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Caméra',
                    bg: const Color(0xFF1565C0),
                    onTap: () {
                      Navigator.pop(context);
                      _pickCamera();
                    }),
                _sourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Galerie',
                    bg: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.pop(context);
                      _pickGallery();
                    }),
              ],
              _sourceTile(
                  icon: Icons.folder_open_rounded,
                  label: 'Fichiers',
                  bg: color.yDarkColor,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  }),
            ],
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 240,
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.yDarkColor,
              color.yDarkColor.withValues(alpha: 0.72)
            ],
          ))),
        ),
        SafeArea(
            child: Column(children: [
          _buildAppBar(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_isOnline
                ? _buildOfflineBanner()
                : (_pendingCount > 0
                    ? _buildPendingBanner()
                    : const SizedBox.shrink()),
          ),
          if (_isLoading) _buildProgressBar(),
          Expanded(
              child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                child: Column(children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 14),
                  _buildFormCard(),
                  const SizedBox(height: 14),
                  _buildDocumentCard(),
                  const SizedBox(height: 22),
                  _buildSubmitButton(),
                ]),
              ),
            ),
          )),
        ])),
        if (_isLoading || _isCompressing) _buildLoadingOverlay(),
      ]),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context)),
          const Expanded(
              child: Text("Formulaire d'inscription",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold))),
          Stack(clipBehavior: Clip.none, children: [
            IconButton(
                icon: const Icon(Icons.cloud_sync_rounded,
                    color: Colors.white70, size: 22),
                tooltip: 'En attente',
                onPressed: _pendingCount > 0 ? _flushQueue : null),
            if (_pendingCount > 0)
              Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    child: Center(
                        child: Text('$_pendingCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  )),
          ]),
        ]),
      );

  // ─── Bandeaux réseau ───────────────────────────────────────────────────────
  // ✅ FIX: SizedBox(width: double.infinity) garantit une largeur finie
  //         Flexible au lieu de Expanded — tolère les parents non bornés

  Widget _buildOfflineBanner() => SizedBox(
        key: const ValueKey('offline'),
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFFB71C1C),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: const [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Hors ligne — soumissions sauvegardées et envoyées à la reconnexion',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPendingBanner() => SizedBox(
        key: const ValueKey('pending'),
        width: double.infinity,
        child: GestureDetector(
          onTap: _flushQueue,
          child: ColoredBox(
            color: const Color(0xFFE65100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.schedule_send_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$_pendingCount soumission(s) en attente — Appuyer pour envoyer',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildProgressBar() => Column(children: [
        LinearProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 3),
        if (_uploadProgress > 0)
          Container(
            color: color.yDarkColor.withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                  '${(_uploadProgress * 100).toStringAsFixed(0)}% — $_loadingLabel',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
      ]);

  Widget _buildLoadingOverlay() => Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18), blurRadius: 24)
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    color: color.yDarkColor,
                    strokeWidth: 3)),
            const SizedBox(height: 14),
            Text(_isCompressing ? 'Compression en cours...' : _loadingLabel,
                style: TextStyle(
                    color: color.yDarkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            if (_uploadProgress > 0) ...[
              const SizedBox(height: 6),
              Text('${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ]),
        )),
      );

  // ─── Cards ─────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard() => _card(
          child: Column(children: [
        SizedBox(width: 100, child: Image.asset(ySplashImage)),
        const SizedBox(height: 10),
        Text('Déposez votre candidature',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color.yDarkColor)),
        const SizedBox(height: 3),
        Text('أرسل طلبك هنا',
            style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      ]));

  Widget _buildFormCard() => _card(
          child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardTitle(
              icon: Icons.person_rounded, title: 'Informations personnelles'),
          const SizedBox(height: 18),
          _sectionLabel('Sexe / الجنس'),
          const SizedBox(height: 10),
          _buildSexeRow(),
          const SizedBox(height: 18),
          _field(
              ctrl: _firstNameCtrl,
              label: 'Prénom*',
              labelAr: '*الاسم الأول',
              icon: Icons.badge_outlined,
              required: true),
          const SizedBox(height: 12),
          _field(
              ctrl: _lastNameCtrl,
              label: 'Nom*',
              labelAr: '*الاسم الثاني',
              icon: Icons.person_outline_rounded,
              required: true),
          const SizedBox(height: 12),
          _field(
              ctrl: _phoneCtrl,
              label: 'Téléphone*',
              labelAr: '*رقم الهاتف',
              icon: Icons.phone_android_outlined,
              isPhone: true,
              required: true),
          const SizedBox(height: 12),
          _buildDateField(),
          const SizedBox(height: 12),
          _field(
              ctrl: _addressCtrl,
              label: 'Adresse',
              labelAr: 'العنوان',
              icon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          _field(
              ctrl: _schoolCtrl,
              label: 'École / Daara',
              labelAr: 'المدرسة',
              icon: Icons.school_outlined),
          const SizedBox(height: 12),
          _field(
              ctrl: _professorCtrl,
              label: 'Professeur',
              labelAr: 'المعلم',
              icon: Icons.person_pin_outlined),
          const SizedBox(height: 10),
          Text('* Champs obligatoires',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic)),
        ]),
      ));

  // ─── Card documents ────────────────────────────────────────────────────────

  Widget _buildDocumentCard() {
    final canAdd = _pickedFiles.length < _kMaxFiles;
    return _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ✅ FIX: Row header avec Flexible sur le titre
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              child: _cardTitle(
                  icon: Icons.attach_file_rounded,
                  title: 'Documents sa Mbinde/الوثائق *')),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color.yDarkColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${_pickedFiles.length}/$_kMaxFiles',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color.yDarkColor)),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
          'PDF, DOC, DOCX, JPG, PNG, WEBP  •  Max 10 Mo  •  Jusqu\'à $_kMaxFiles fichiers',
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
              height: 1.6)),
      const SizedBox(height: 14),

      if (_pickedFiles.isNotEmpty) ...[
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pickedFiles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _buildFileItem(_pickedFiles[i], i),
        ),
        const SizedBox(height: 12),
      ] else ...[
        Container(
          height: 90,
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!, width: 1.5)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_upload_outlined,
                size: 32, color: Colors.grey[300]),
            const SizedBox(height: 6),
            Text('Aucun document sélectionné',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 12),
      ],

      if (canAdd)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (_isCompressing || _isLoading) ? null : _showSourceSheet,
            icon: Icon(
                _pickedFiles.isEmpty ? Icons.upload_rounded : Icons.add_rounded,
                size: 20),
            label: Text(
              _pickedFiles.isEmpty
                  ? 'Ajouter un document/أضف مستندًا'
                  : 'Ajouter un autre (${_kMaxFiles - _pickedFiles.length} restant${_kMaxFiles - _pickedFiles.length > 1 ? "s" : ""})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: color.yDarkColor,
              side: BorderSide(color: color.yDarkColor, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        )
      else
        // ✅ FIX: pas d'Expanded ici — Row avec mainAxisAlignment.center suffit
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: color.yDarkColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: color.yDarkColor, size: 16),
              const SizedBox(width: 6),
              Text('Maximum atteint ($_kMaxFiles/$_kMaxFiles)',
                  style: TextStyle(
                      fontSize: 12,
                      color: color.yDarkColor,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
    ]));
  }

  // ─── Items fichier ─────────────────────────────────────────────────────────

  Widget _buildFileItem(_PickedFile f, int index) => Container(
        decoration: BoxDecoration(
          color: color.yDarkColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.yDarkColor.withValues(alpha: 0.15), width: 1.2),
        ),
        child: f.isImage ? _buildImageItem(f, index) : _buildDocItem(f, index),
      );

  Widget _buildImageItem(_PickedFile f, int index) => Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(children: [
            Image.memory(f.bytes,
                height: 140, width: double.infinity, fit: BoxFit.cover),
            // ✅ FIX PRINCIPAL: left:0 + right:0 sur le Positioned donne une
            //    width finie au Container → Expanded dans le Row enfant devient valide
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent
                    ])),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(Icons.image_outlined,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    // ✅ Expanded est safe ici car le Positioned contraint la largeur
                    Expanded(
                      child: Text(f.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    Text(f.sizeLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ]),
        ),
        Positioned(top: 6, right: 6, child: _deleteButton(index)),
      ]);

  Widget _buildDocItem(_PickedFile f, int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.yDarkColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                  f.ext == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.description_outlined,
                  color: color.yDarkColor,
                  size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.name,
                        style: TextStyle(
                            color: color.yDarkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    // ✅ FIX: mainAxisSize.min évite le conflit Expanded imbriqué
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              color: color.yDarkColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(f.ext.toUpperCase(),
                              style: TextStyle(
                                  color: color.yDarkColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Text(f.sizeLabel,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 10)),
                      ],
                    ),
                  ]),
            ),
            const SizedBox(width: 8),
            _deleteButton(index),
          ],
        ),
      );

  Widget _deleteButton(int index) => GestureDetector(
        onTap: () => _removeFile(index),
        child: Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ]),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
        ),
      );

  Widget _buildSubmitButton() {
    final bool busy = _isLoading || _isCompressing;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: busy ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.yDarkColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.yDarkColor.withValues(alpha: 0.45),
          elevation: busy ? 0 : 5,
          shadowColor: color.yDarkColor.withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!busy) const Icon(Icons.send_rounded, size: 20),
            if (!busy) const SizedBox(width: 10),
            // ✅ FIX: Flexible + overflow.ellipsis pour le texte du bouton
            Flexible(
              child: Text(
                busy
                    ? (_loadingLabel.isNotEmpty
                        ? _loadingLabel
                        : 'Traitement...')
                    : _isOnline
                        ? 'Valider ma candidature'
                        : 'Sauvegarder (hors ligne)',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets réutilisables ─────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      );

  // ✅ FIX: mainAxisSize.min + Flexible sur le Text évite l'overflow du titre
  Widget _cardTitle({required IconData icon, required String title}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.yDarkColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color.yDarkColor, size: 17),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color.yDarkColor),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[500]));

  Widget _buildSexeRow() => Row(children: [
        _sexeTile('masculin', 'Masculin', 'ذكر', Icons.male_rounded),
        const SizedBox(width: 10),
        _sexeTile('feminin', 'Féminin', 'أنثى', Icons.female_rounded),
      ]);

  Widget _sexeTile(String value, String label, String labelAr, IconData icon) {
    final bool sel = _sexe == value;
    return Expanded(
        child: GestureDetector(
      onTap: () => setState(() => _sexe = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: sel ? color.yDarkColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: sel ? color.yDarkColor : Colors.grey[300]!),
        ),
        child: Column(children: [
          Icon(icon, color: sel ? Colors.white : Colors.grey[400], size: 22),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: sel ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          Text(labelAr,
              style: TextStyle(
                  color: sel ? Colors.white60 : Colors.grey[400],
                  fontSize: 10)),
        ]),
      ),
    ));
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String labelAr,
    required IconData icon,
    bool isPhone = false,
    bool required = false,
  }) {
    final f = TextFormField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLength: isPhone ? 9 : 200,
      autocorrect: false,
      enableSuggestions: !isPhone,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color.yDarkColor, size: 19),
        labelText: '$label / $labelAr',
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
        counterText: '',
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color.yDarkColor, width: 1.8),
            borderRadius: BorderRadius.circular(13)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.4),
            borderRadius: BorderRadius.circular(13)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
            borderRadius: BorderRadius.circular(13)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.8),
            borderRadius: BorderRadius.circular(13)),
      ),
      validator: (v) {
        final t = (v ?? '').trim();
        if (required && t.isEmpty) return 'Ce champ est obligatoire.';
        if (t.isNotEmpty && _kDangerousCharsRegex.hasMatch(t)) {
          return 'Caractères non autorisés.';
        }
        if (isPhone && required && !_validatePhone(t)) {
          return 'Numéro invalide (ex: 77XXXXXXX).';
        }
        return null;
      },
    );
    if (kIsWeb) return PointerInterceptor(child: f);
    return f;
  }

  Widget _buildDateField() {
    final f = TextFormField(
      controller: _birthDateCtrl,
      readOnly: true,
      onTap: _pickDate,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon:
            Icon(Icons.cake_outlined, color: color.yDarkColor, size: 19),
        labelText: 'Date de naissance / تاريخ الميلاد',
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
        suffixIcon: Icon(Icons.edit_calendar_outlined,
            color: Colors.grey[400], size: 17),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color.yDarkColor, width: 1.8),
            borderRadius: BorderRadius.circular(13)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.4),
            borderRadius: BorderRadius.circular(13)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
            borderRadius: BorderRadius.circular(13)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.8),
            borderRadius: BorderRadius.circular(13)),
      ),
    );
    if (kIsWeb) {
      return PointerInterceptor(
          child: GestureDetector(
              onTap: _pickDate, child: AbsorbPointer(child: f)));
    }
    return f;
  }

  Widget _sourceTile({
    required IconData icon,
    required String label,
    required Color bg,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: bg.withValues(alpha: 0.2))),
            child: Icon(icon, color: bg, size: 27),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
        ]),
      );
}
