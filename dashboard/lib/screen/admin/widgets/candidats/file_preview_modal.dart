// lib/screen/admin/widgets/candidats/file_preview_modal.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/utils/url_helper.dart';
import 'package:dashboard/screen/admin/widgets/shared/shared_widgets.dart';

// ─── Modal principale ─────────────────────────────────────────────────────────

class FilePreviewModal extends StatelessWidget {
  final ConcurantModel candidat;

  const FilePreviewModal({super.key, required this.candidat});

  @override
  Widget build(BuildContext context) {
    final fichier = candidat.fichierJustificatif;
    // ── Résolution robuste des URLs (chemin relatif → URL absolue) ────────────
    final url = candidat.fichierUrl ?? '';
    final downloadUrl = candidat.fichierDownloadUrl ?? url;
    final isImage = fichier?.isImage ?? false;
    final isPdf = fichier?.isPdf ?? false;

    return GestureDetector(
      onTap: () => context.read<CandidatsBloc>().closePreview(),
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 720,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModalHeader(
                    candidat: candidat,
                    fichier: fichier,
                    url: url,
                    downloadUrl: downloadUrl,
                  ),
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                      child: isImage
                          ? _ImagePreview(url: url)
                          : isPdf
                              ? _PdfPreview(url: url)
                              : _GenericFilePreview(
                                  fichier: fichier,
                                  candidat: candidat,
                                  url: url,
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header du modal ──────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  final ConcurantModel candidat;
  final FichierJustificatif? fichier;
  final String url;
  final String downloadUrl;

  const _ModalHeader({
    required this.candidat,
    required this.fichier,
    required this.url,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.tagBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(CupertinoIcons.doc_text,
                size: 16, color: AppColors.tagBlueFg),
          ),
          const SizedBox(width: 12),

          // Infos candidat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidat.fullName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  fichier?.nomFichier ?? 'Document',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Badge source Cloudinary
          if (candidat.isFichierCloudinary)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: const Color(0xFF1A56DB).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.cloud,
                      size: 10, color: Color(0xFF1A56DB)),
                  SizedBox(width: 4),
                  Text('Cloudinary',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1A56DB),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // Taille fichier
          if (fichier?.sizeLabel.isNotEmpty == true)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                fichier!.sizeLabel,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),

          // Ouvrir
          LabeledActionButton(
            icon: CupertinoIcons.arrow_up_right_square,
            label: 'Ouvrir',
            color: AppColors.tagGreenFg,
            bg: AppColors.tagGreen,
            onTap: () => UrlHelper.open(url),
          ),
          const SizedBox(width: 8),

          // Télécharger
          LabeledActionButton(
            icon: CupertinoIcons.cloud_download,
            label: 'Télécharger',
            color: AppColors.tagBlueFg,
            bg: AppColors.tagBlue,
            onTap: () => UrlHelper.download(url),
          ),
          const SizedBox(width: 8),

          // Fermer
          IconButton(
            onPressed: () => context.read<CandidatsBloc>().closePreview(),
            icon: const Icon(CupertinoIcons.xmark, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bg,
              foregroundColor: AppColors.noir,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aperçu image ─────────────────────────────────────────────────────────────

class _ImagePreview extends StatefulWidget {
  final String url;
  const _ImagePreview({required this.url});

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    if (_error) return _buildError();
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        color: AppColors.bg,
        padding: const EdgeInsets.all(16),
        child: Image.network(
          widget.url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 12),
                  const Text('Chargement de l\'image…',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => setState(() => _error = true));
            return _buildError();
          },
        ),
      ),
    );
  }

  Widget _buildError() => Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(CupertinoIcons.photo, size: 36, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('Impossible de charger l\'image',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
}

// ─── Aperçu PDF ───────────────────────────────────────────────────────────────

class _PdfPreview extends StatelessWidget {
  final String url;
  const _PdfPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    // Diagnostic : afficher l'URL résolue en debug
    assert(() {
      debugPrint('[FilePreview] URL PDF résolue : $url');
      return true;
    }());

    return Container(
      height: 360,
      color: AppColors.bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.tagRedFg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.doc_richtext,
                size: 36, color: AppColors.tagRedFg),
          ),
          const SizedBox(height: 16),
          const Text(
            'Document PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cliquez sur "Ouvrir" pour visualiser le PDF\ndans votre navigateur.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 8),

          // ── URL résolue visible (aide au debug) ───────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              url.isEmpty ? '⚠ URL non disponible' : url,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace'),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ouvrir dans un nouvel onglet
              ElevatedButton.icon(
                onPressed: url.isNotEmpty ? () => UrlHelper.open(url) : null,
                icon:
                    const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
                label: const Text('Ouvrir le PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tagRedFg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(width: 12),
              // Télécharger
              OutlinedButton.icon(
                onPressed:
                    url.isNotEmpty ? () => UrlHelper.download(url) : null,
                icon: const Icon(CupertinoIcons.cloud_download,
                    size: 15, color: AppColors.tagRedFg),
                label: const Text('Télécharger',
                    style: TextStyle(color: AppColors.tagRedFg)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.tagRedFg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Aperçu fichier générique ─────────────────────────────────────────────────

class _GenericFilePreview extends StatelessWidget {
  final FichierJustificatif? fichier;
  final ConcurantModel candidat;
  final String url;

  const _GenericFilePreview({
    required this.fichier,
    required this.candidat,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: AppColors.bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.tagBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.doc_text,
                size: 36, color: AppColors.tagBlueFg),
          ),
          const SizedBox(height: 16),
          Text(
            fichier?.nomFichier ?? 'Document',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (fichier != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTag(
                  label: fichier!.typeFichier?.toUpperCase() ?? '',
                  bg: AppColors.tagBlue,
                  fg: AppColors.tagBlueFg,
                ),
                if (fichier!.sizeLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  AppTag(
                    label: fichier!.sizeLabel,
                    bg: AppColors.bg,
                    fg: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          const SizedBox(height: 20),
          const Text(
            'L\'aperçu n\'est pas disponible pour ce type de fichier.\nUtilisez "Ouvrir" ou "Télécharger" pour y accéder.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppColors.textMuted, height: 1.6),
          ),
        ],
      ),
    );
  }
}
