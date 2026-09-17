import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/screen/admin/widgets/shared/shared_widgets.dart';
import 'package:dashboard/utils/web_downloader.dart'
    if (dart.library.html) 'package:dashboard/utils/web_downloader_web.dart';

class CandidatRow extends StatefulWidget {
  final ConcurantModel candidat;
  final bool isEven;
  final int globalIndex;

  const CandidatRow({
    super.key,
    required this.candidat,
    required this.isEven,
    required this.globalIndex,
  });

  @override
  State<CandidatRow> createState() => _CandidatRowState();
}

class _CandidatRowState extends State<CandidatRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.candidat;
    final hasFichier = c.fichierUrl != null && c.fichierUrl!.isNotEmpty;
    final bloc = context.watch<CandidatsBloc>();
    final isSelected = bloc.isSelected(c);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: isSelected
            ? AppColors.accent.withOpacity(0.06)
            : _hovered
                ? AppColors.accent.withOpacity(0.04)
                : widget.isEven
                    ? AppColors.surface
                    : AppColors.bg.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Checkbox ─────────────────────────────────────────────────
            SizedBox(
              width: 28,
              child: c.telephone != null
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) =>
                          context.read<CandidatsBloc>().toggleSelection(c),
                      activeColor: AppColors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side:
                          const BorderSide(color: AppColors.border, width: 1.5),
                    )
                  : const SizedBox(),
            ),

            // ── # Index ──────────────────────────────────────────────────
            Expanded(
              flex: 1,
              child: Text(
                '#${widget.globalIndex}',
                style: AppTextStyles.mono,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Candidat ─────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Row(children: [
                CandidatAvatar(initials: c.initials, sexe: c.sexe),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.fullName,
                        style: AppTextStyles.cellPrimary,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (c.id != null)
                        Text(
                          '#${c.id!.substring(0, c.id!.length.clamp(0, 8))}…',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ]),
            ),

            // ── Téléphone ────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _copyToClipboard(context, c.telephone ?? ''),
                child: Row(children: [
                  Flexible(
                    child: Text(
                      c.telephone ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.telephone != null
                            ? AppColors.accent
                            : AppColors.textMuted,
                        decoration: c.telephone != null
                            ? TextDecoration.underline
                            : null,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (c.telephone != null) ...[
                    const SizedBox(width: 3),
                    Icon(
                      CupertinoIcons.doc_on_doc,
                      size: 10,
                      color: AppColors.textMuted.withOpacity(0.6),
                    ),
                  ],
                ]),
              ),
            ),

            // ── Date naissance ───────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(
                c.dateNaissance != null
                    ? DateFormat('dd/MM/yyyy').format(c.dateNaissance!)
                    : '—',
                style: AppTextStyles.cellSecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Date inscription ─────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(
                c.createdAt != null
                    ? DateFormat('dd/MM/yy HH:mm').format(c.createdAt!)
                    : '—',
                style: AppTextStyles.cellSecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Fichier badge ────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: hasFichier
                  ? Row(children: [
                      Flexible(
                        child: FichierBadge(fichier: c.fichierJustificatif!),
                      ),
                      if (c.isFichierCloudinary) ...[
                        const SizedBox(width: 5),
                        Tooltip(
                          message: 'Cloudinary',
                          child: Icon(
                            CupertinoIcons.cloud_fill,
                            size: 11,
                            color: AppColors.tagBlueFg.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ])
                  : const Text(
                      '—',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
            ),

            // ── Actions ──────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 4,
                children: [
                  if (hasFichier) ...[
                    // Aperçu
                    IconActionButton(
                      icon: CupertinoIcons.eye,
                      tooltip: 'Aperçu',
                      color: AppColors.tagBlueFg,
                      bg: AppColors.tagBlue,
                      onTap: () => context.read<CandidatsBloc>().openPreview(c),
                    ),
                    // Ouvrir dans un onglet
                    IconActionButton(
                      icon: CupertinoIcons.arrow_up_right_square,
                      tooltip: 'Ouvrir',
                      color: AppColors.tagGreenFg,
                      bg: AppColors.tagGreen,
                      onTap: () => _launchUrl(context, c.fichierUrl!),
                    ),
                    IconActionButton(
                      icon: CupertinoIcons.cloud_download,
                      tooltip: 'Télécharger',
                      color: AppColors.tagPurpleFg,
                      bg: AppColors.tagPurple,
                      onTap: () => _downloadWithName(c),
                    ),
                  ],
                  if (c.telephone != null)
                    IconActionButton(
                      icon: CupertinoIcons.phone,
                      tooltip: 'Copier tél.',
                      color: AppColors.textMuted,
                      bg: AppColors.bg,
                      onTap: () => _copyToClipboard(context, c.telephone!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadWithName(ConcurantModel c) {
    final rawUrl = c.fichierDownloadUrl ?? c.fichierUrl!;

    // ── 1. Slugifier une chaîne ──────────────────────────────────────
    // Minuscules, espaces → "_", tout caractère non alphanumérique supprimé
    String slug(String? s) => (s ?? 'inconnu')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final prenom = slug(c.prenom);
    final nom = slug(c.nom);

    // ── 2. Date d'inscription au format DD-MM-YYYY ───────────────────
    final date = c.createdAt != null
        ? DateFormat('dd-MM-yyyy').format(c.createdAt!)
        : 'date-inconnue';

    // ── 3. Extension depuis le dernier segment de l'URL ──────────────
    final ext = () {
      final seg = Uri.parse(rawUrl).pathSegments.lastOrNull ?? '';
      final parts = seg.split('.');
      return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '.pdf';
    }();

    final fileName = '${prenom}_${nom}_$date$ext';

    final downloadUrl =
        c.isFichierCloudinary ? '$rawUrl?fl_attachment=$fileName' : rawUrl;

    downloadFile(url: downloadUrl, fileName: fileName);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utilitaires
  // ─────────────────────────────────────────────────────────────────────────

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessSnack(context, '"$text" copié');
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        showErrorSnack(context, 'Impossible d\'ouvrir le lien.');
      }
    }
  }
}
