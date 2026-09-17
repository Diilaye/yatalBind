import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/utils/coolors-by-dii.dart';
import 'package:dashboard/utils/padding-global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Palette locale ────────────────────────────────────────────────────────────
const _kAccent = Color(0xFF084D27); // vert foncé (cohérent avec appli)
const _kBg = Color(0xFFF1F5F8);
const _kSurface = Colors.white;
const _kBorder = Color(0xFFE4E9EF);
const _kTextMuted = Color(0xFF8A96A3);
const _kTagBlue = Color(0xFFE8F0FE);
const _kTagBlueFg = Color(0xFF1A56DB);
const _kTagGreen = Color(0xFFE6F4EA);
const _kTagGreenFg = Color(0xFF1E7E34);
const _kTagRed = Color(0xFFFFEBEE);
const _kTagRedFg = Color(0xFFC62828);

// ─── Écran principal ───────────────────────────────────────────────────────────

class SmsmScreen extends StatelessWidget {
  const SmsmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CandidatsBloc(),
      child: const _CandidatsView(),
    );
  }
}

class _CandidatsView extends StatefulWidget {
  const _CandidatsView();

  @override
  State<_CandidatsView> createState() => _CandidatsViewState();
}

class _CandidatsViewState extends State<_CandidatsView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CandidatsBloc>();
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          color: _kBg,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Header ────────────────────────────────────────────────────
              _buildHeader(context, bloc, size),

              // ── Stats bar ─────────────────────────────────────────────────
              if (!bloc.isLoading && bloc.errorMessage == null)
                _buildStatsBar(context, bloc),

              paddingVerticalGlobal(16),

              // ── Tableau ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: bloc.isLoading
                    ? _buildSkeleton()
                    : bloc.errorMessage != null
                        ? _buildError(context, bloc)
                        : _buildTable(context, bloc, size),
              ),

              paddingVerticalGlobal(32),
            ],
          ),
        ),

        // ── Modal aperçu fichier ───────────────────────────────────────────
        if (bloc.previewCandidat != null)
          _FilePreviewModal(candidat: bloc.previewCandidat!),
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, CandidatsBloc bloc, Size size) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          const Row(
            children: [
              Icon(CupertinoIcons.home, size: 13, color: _kTextMuted),
              SizedBox(width: 6),
              Icon(CupertinoIcons.chevron_forward,
                  size: 11, color: _kTextMuted),
              SizedBox(width: 6),
              Text('Admin',
                  style: TextStyle(
                      fontSize: 12,
                      color: _kTextMuted,
                      fontFamily: 'monospace')),
              SizedBox(width: 6),
              Icon(CupertinoIcons.chevron_forward,
                  size: 11, color: _kTextMuted),
              SizedBox(width: 6),
              Text('Candidats',
                  style: TextStyle(
                      fontSize: 12,
                      color: _kAccent,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // Titre + actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CANDIDATS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: noir,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bloc.isLoading
                        ? 'Chargement...'
                        : '${bloc.totalCount} inscription(s) au total',
                    style: const TextStyle(fontSize: 13, color: _kTextMuted),
                  ),
                ],
              ),
              const Spacer(),

              // Barre de recherche
              SizedBox(
                width: size.width * .26,
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<CandidatsBloc>().setSearch(v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Rechercher…',
                    hintStyle:
                        const TextStyle(color: _kTextMuted, fontSize: 13),
                    prefixIcon: const Icon(CupertinoIcons.search,
                        size: 16, color: _kTextMuted),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill,
                                size: 15, color: _kTextMuted),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<CandidatsBloc>().clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: _kBg,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Rafraîchir
              _ActionButton(
                icon: CupertinoIcons.refresh,
                tooltip: 'Actualiser',
                onTap: () => context.read<CandidatsBloc>().refresh(),
                loading: bloc.isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats bar ───────────────────────────────────────────────────────────────

  Widget _buildStatsBar(BuildContext context, CandidatsBloc bloc) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          _StatChip(
            label: 'Total',
            value: '${bloc.totalCount}',
            color: _kAccent,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Masculin',
            value: '${bloc.countMasculin}',
            color: _kTagBlueFg,
            bg: _kTagBlue,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Féminin',
            value: '${bloc.countFeminin}',
            color: const Color(0xFF8E24AA),
            bg: const Color(0xFFF3E5F5),
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Avec fichier',
            value: '${bloc.countAvecFichier}',
            color: _kTagGreenFg,
            bg: _kTagGreen,
          ),
        ],
      ),
    );
  }

  // ─── Table ───────────────────────────────────────────────────────────────────

  Widget _buildTable(BuildContext context, CandidatsBloc bloc, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // En-tête tableau
            _TableHeader(),

            const Divider(height: 1, color: _kBorder),

            // Lignes
            if (bloc.paginated.isEmpty)
              _buildEmptyState()
            else
              ...bloc.paginated.asMap().entries.map((entry) {
                final idx = entry.key;
                final candidat = entry.value;
                return Column(
                  children: [
                    _CandidatRow(
                      candidat: candidat,
                      isEven: idx.isEven,
                      globalIndex: (bloc.currentPage - 1) * 25 + idx + 1,
                    ),
                    if (idx < bloc.paginated.length - 1)
                      const Divider(height: 1, color: _kBorder, indent: 16),
                  ],
                );
              }),

            // Footer pagination
            const Divider(height: 1, color: _kBorder),
            _buildPagination(context, bloc),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.person_2,
              size: 42, color: _kTextMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'Aucun candidat trouvé',
            style: TextStyle(
                color: _kTextMuted, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, CandidatsBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            bloc.rangeLabel,
            style: const TextStyle(
                fontSize: 12, color: _kTextMuted, fontWeight: FontWeight.w500),
          ),
          const Spacer(),

          // Pages numérotées
          ..._buildPageNumbers(context, bloc),

          const SizedBox(width: 8),
          _PagBtn(
            icon: CupertinoIcons.chevron_right,
            enabled: bloc.canGoNext,
            onTap: () => context.read<CandidatsBloc>().nextPage(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, CandidatsBloc bloc) {
    final total = bloc.totalPages;
    final current = bloc.currentPage;

    final pages = <int>[];
    if (total <= 7) {
      pages.addAll(List.generate(total, (i) => i + 1));
    } else {
      pages.add(1);
      if (current > 3) pages.add(-1); // ellipsis
      for (int i = (current - 1).clamp(2, total - 1);
          i <= (current + 1).clamp(2, total - 1);
          i++) {
        pages.add(i);
      }
      if (current < total - 2) pages.add(-1); // ellipsis
      pages.add(total);
    }

    return [
      _PagBtn(
        icon: CupertinoIcons.chevron_left,
        enabled: bloc.canGoPrev,
        onTap: () => context.read<CandidatsBloc>().previousPage(),
      ),
      const SizedBox(width: 6),
      ...pages.map((p) {
        if (p == -1) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child:
                Text('…', style: TextStyle(color: _kTextMuted, fontSize: 12)),
          );
        }
        final isActive = p == current;
        return GestureDetector(
          onTap: () => context.read<CandidatsBloc>().goToPage(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? _kAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? _kAccent : _kBorder,
              ),
            ),
            child: Center(
              child: Text(
                '$p',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : noir,
                ),
              ),
            ),
          ),
        );
      }),
    ];
  }

  // ─── États ───────────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: List.generate(
            8,
            (i) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          _Shimmer(width: 60, height: 12),
                          const SizedBox(width: 16),
                          _Shimmer(width: 140, height: 12),
                          const SizedBox(width: 16),
                          _Shimmer(width: 100, height: 12),
                          const SizedBox(width: 16),
                          _Shimmer(width: 80, height: 12),
                          const SizedBox(width: 16),
                          _Shimmer(width: 80, height: 12),
                          const Spacer(),
                          _Shimmer(width: 60, height: 28),
                        ],
                      ),
                    ),
                    if (i < 7) const Divider(height: 1, color: _kBorder),
                  ],
                )),
      ),
    );
  }

  Widget _buildError(BuildContext context, CandidatsBloc bloc) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle,
              size: 36, color: _kTagRedFg),
          const SizedBox(height: 10),
          Text(
            bloc.errorMessage ?? 'Erreur inconnue',
            style:
                const TextStyle(color: _kTagRedFg, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => context.read<CandidatsBloc>().refresh(),
            icon: const Icon(CupertinoIcons.refresh, size: 14),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── En-tête tableau ──────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          _HeaderCell('#', flex: 1),
          _HeaderCell('CANDIDAT', flex: 3),
          _HeaderCell('TÉLÉPHONE', flex: 2),
          _HeaderCell('DATE NAISS.', flex: 2),
          _HeaderCell('INSCRIPTION', flex: 2),
          _HeaderCell('FICHIER', flex: 2),
          _HeaderCell('ACTIONS', flex: 2, align: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;
  const _HeaderCell(this.label, {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kTextMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Ligne candidat ───────────────────────────────────────────────────────────

class _CandidatRow extends StatefulWidget {
  final ConcurantModel candidat;
  final bool isEven;
  final int globalIndex;
  const _CandidatRow(
      {required this.candidat,
      required this.isEven,
      required this.globalIndex});

  @override
  State<_CandidatRow> createState() => _CandidatRowState();
}

class _CandidatRowState extends State<_CandidatRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.candidat;
    final hasFichier = c.fichierUrl != null && c.fichierUrl!.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered
            ? _kAccent.withOpacity(0.04)
            : widget.isEven
                ? _kSurface
                : _kBg.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // # Index
            Expanded(
              flex: 1,
              child: Text(
                '#${widget.globalIndex}',
                style: const TextStyle(
                    fontSize: 12, color: _kTextMuted, fontFamily: 'monospace'),
              ),
            ),

            // Candidat (avatar + nom)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _Avatar(initials: c.initials, sexe: c.sexe),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.fullName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A202C)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (c.id != null)
                          Text(
                            '#${c.id!.substring(0, 8)}…',
                            style: const TextStyle(
                                fontSize: 10,
                                color: _kTextMuted,
                                fontFamily: 'monospace'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Téléphone
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _copyToClipboard(context, c.telephone ?? ''),
                child: Row(
                  children: [
                    Text(
                      c.telephone ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.telephone != null ? _kAccent : _kTextMuted,
                        decoration: c.telephone != null
                            ? TextDecoration.underline
                            : null,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                    if (c.telephone != null) ...[
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.doc_on_doc,
                          size: 10, color: _kTextMuted.withOpacity(0.6)),
                    ],
                  ],
                ),
              ),
            ),

            // Date naissance
            Expanded(
              flex: 2,
              child: Text(
                c.dateNaissance != null
                    ? DateFormat('dd/MM/yyyy').format(c.dateNaissance!)
                    : '—',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
              ),
            ),

            // Date inscription
            Expanded(
              flex: 2,
              child: Text(
                c.createdAt != null
                    ? DateFormat('dd/MM/yy HH:mm').format(c.createdAt!)
                    : '—',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
              ),
            ),

            // Fichier badge
            Expanded(
              flex: 2,
              child: hasFichier
                  ? _FichierBadge(fichier: c.fichierJustificatif!)
                  : const Text('—',
                      style: TextStyle(fontSize: 12, color: _kTextMuted)),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasFichier) ...[
                    // Aperçu
                    _RowAction(
                      icon: CupertinoIcons.eye,
                      tooltip: 'Aperçu',
                      color: _kTagBlueFg,
                      bg: _kTagBlue,
                      onTap: () => context.read<CandidatsBloc>().openPreview(c),
                    ),
                    const SizedBox(width: 6),
                    // Ouvrir externe
                    _RowAction(
                      icon: CupertinoIcons.arrow_up_right_square,
                      tooltip: 'Ouvrir dans le navigateur',
                      color: _kTagGreenFg,
                      bg: _kTagGreen,
                      onTap: () => _launchUrl(context, c.fichierUrl!),
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Copier téléphone
                  if (c.telephone != null)
                    _RowAction(
                      icon: CupertinoIcons.phone,
                      tooltip: 'Copier le téléphone',
                      color: _kTextMuted,
                      bg: _kBg,
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

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(CupertinoIcons.checkmark_circle,
            color: Colors.white, size: 15),
        const SizedBox(width: 8),
        Text('"$text" copié', style: const TextStyle(fontSize: 13)),
      ]),
      backgroundColor: _kAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible d\'ouvrir le lien.'),
          backgroundColor: _kTagRedFg,
        ));
      }
    }
  }
}

// ─── Modal aperçu fichier ──────────────────────────────────────────────────────

class _FilePreviewModal extends StatelessWidget {
  final ConcurantModel candidat;
  const _FilePreviewModal({required this.candidat});

  @override
  Widget build(BuildContext context) {
    final fichier = candidat.fichierJustificatif;
    final url = candidat.fichierUrl ?? '';
    final isImage = fichier?.isImage ?? false;
    final isPdf = fichier?.isPdf ?? false;

    return GestureDetector(
      onTap: () => context.read<CandidatsBloc>().closePreview(),
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // ne pas fermer si clic sur la modale
            child: Container(
              width: 700,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 40)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Barre titre ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _kBorder)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _kTagBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(CupertinoIcons.doc_text,
                              size: 16, color: _kTagBlueFg),
                        ),
                        const SizedBox(width: 12),
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
                                style: const TextStyle(
                                    fontSize: 11, color: _kTextMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Taille fichier
                        if (fichier?.sizeLabel.isNotEmpty == true)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _kBorder),
                            ),
                            child: Text(
                              fichier!.sizeLabel,
                              style: const TextStyle(
                                  fontSize: 11, color: _kTextMuted),
                            ),
                          ),
                        // Bouton ouvrir externe
                        _ModalAction(
                          icon: CupertinoIcons.arrow_up_right_square,
                          label: 'Ouvrir',
                          color: _kTagGreenFg,
                          bg: _kTagGreen,
                          onTap: () async {
                            final uri = Uri.parse(url);
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                        const SizedBox(width: 8),
                        // Télécharger
                        _ModalAction(
                          icon: CupertinoIcons.cloud_download,
                          label: 'Télécharger',
                          color: _kTagBlueFg,
                          bg: _kTagBlue,
                          onTap: () async {
                            // Pour Cloudinary : forcer le téléchargement
                            // via fl_attachment
                            final dlUrl = url.contains('cloudinary.com')
                                ? url.replaceFirst(
                                    '/upload/', '/upload/fl_attachment/')
                                : url;
                            final uri = Uri.parse(dlUrl);
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                        const SizedBox(width: 8),
                        // Fermer
                        IconButton(
                          onPressed: () =>
                              context.read<CandidatsBloc>().closePreview(),
                          icon: const Icon(CupertinoIcons.xmark, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: _kBg,
                            foregroundColor: noir,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Contenu aperçu ─────────────────────────────────────────
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
      child: Image.network(
        widget.url,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: _kAccent,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => setState(() => _error = true));
          return _buildError();
        },
      ),
    );
  }

  Widget _buildError() => Container(
        height: 200,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.photo, size: 36, color: _kTextMuted),
            SizedBox(height: 8),
            Text('Impossible de charger l\'image',
                style: TextStyle(color: _kTextMuted, fontSize: 13)),
          ],
        ),
      );
}

// ─── Aperçu PDF (iframe web / message natif) ──────────────────────────────────

class _PdfPreview extends StatelessWidget {
  final String url;
  const _PdfPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    // Sur desktop web on peut afficher le PDF en iframe via url_launcher
    // Sur mobile/desktop natif on redirige
    return Container(
      height: 360,
      color: _kBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kTagRedFg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.doc_richtext,
                size: 36, color: _kTagRedFg),
          ),
          const SizedBox(height: 16),
          const Text(
            'Document PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cliquez sur "Ouvrir" pour visualiser le PDF\ndans votre navigateur',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kTextMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
            label: const Text('Ouvrir le PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTagRedFg,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aperçu fichier générique (DOC, DOCX) ────────────────────────────────────

class _GenericFilePreview extends StatelessWidget {
  final FichierJustificatif? fichier;
  final ConcurantModel candidat;
  final String url;
  const _GenericFilePreview(
      {required this.fichier, required this.candidat, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: _kBg,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kTagBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.doc_text,
                size: 36, color: _kTagBlueFg),
          ),
          const SizedBox(height: 16),
          Text(
            fichier?.nomFichier ?? 'Document',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (fichier != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(
                    label: fichier!.typeFichier?.toUpperCase() ?? '',
                    bg: _kTagBlue,
                    fg: _kTagBlueFg),
                const SizedBox(width: 8),
                if (fichier!.sizeLabel.isNotEmpty)
                  _Tag(label: fichier!.sizeLabel, bg: _kBg, fg: _kTextMuted),
              ],
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'L\'aperçu n\'est pas disponible pour ce type de fichier.\nUtilisez "Ouvrir" pour le visualiser.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _kTextMuted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Petits widgets utilitaires ───────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final String? sexe;
  const _Avatar({required this.initials, this.sexe});

  @override
  Widget build(BuildContext context) {
    final isFeminin = sexe == 'feminin';
    final bg = isFeminin ? const Color(0xFFF3E5F5) : const Color(0xFFE8F0FE);
    final fg = isFeminin ? const Color(0xFF8E24AA) : _kTagBlueFg;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
        ),
      ),
    );
  }
}

class _FichierBadge extends StatelessWidget {
  final FichierJustificatif fichier;
  const _FichierBadge({required this.fichier});

  @override
  Widget build(BuildContext context) {
    final isImg = fichier.isImage;
    final isPdf = fichier.isPdf;
    final ext = fichier.typeFichier?.toUpperCase() ?? '?';
    final Color bg;
    final Color fg;

    if (isImg) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    } else if (isPdf) {
      bg = _kTagRed;
      fg = _kTagRedFg;
    } else {
      bg = _kTagBlue;
      fg = _kTagBlueFg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImg
                ? CupertinoIcons.photo
                : isPdf
                    ? CupertinoIcons.doc_richtext
                    : CupertinoIcons.doc_text,
            size: 11,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(ext,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? bg;
  const _StatChip(
      {required this.label, required this.value, required this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _RowAction(
      {required this.icon,
      required this.tooltip,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _ModalAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _ModalAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool loading;
  const _ActionButton(
      {required this.icon,
      required this.tooltip,
      required this.onTap,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kAccent),
                  ),
                )
              : Icon(icon, size: 16, color: _kTextMuted),
        ),
      ),
    );
  }
}

class _PagBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PagBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(
          icon,
          size: 13,
          color: enabled ? noir : _kTextMuted.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Shimmer loader ────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  const _Shimmer({required this.width, required this.height});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
    _anim = Tween<double>(begin: -1, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: [
              _kBorder,
              Colors.grey[200]!,
              _kBorder,
            ],
          ),
        ),
      ),
    );
  }
}
