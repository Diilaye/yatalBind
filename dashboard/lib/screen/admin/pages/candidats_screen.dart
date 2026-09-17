import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/screen/admin/widgets/shared/shared_widgets.dart';
import 'package:dashboard/screen/admin/widgets/candidats/candidats_table.dart';
import 'package:dashboard/screen/admin/widgets/candidats/file_preview_modal.dart';
import 'package:dashboard/screen/admin/widgets/sms/sms_compose_panel.dart';

enum _AdminTab { candidats, sms }

class CandidatsScreen extends StatelessWidget {
  const CandidatsScreen({super.key});

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
  _AdminTab _activeTab = _AdminTab.candidats;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CandidatsBloc>();

    return Stack(
      children: [
        Container(
          color: AppColors.bg,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context, bloc),
              if (!bloc.isLoading && bloc.errorMessage == null)
                _buildStatsBar(bloc),
              _buildTabs(context, bloc),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _activeTab == _AdminTab.candidats
                    ? const CandidatsTable()
                    : const SmsComposePanel(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        if (bloc.previewCandidat != null)
          FilePreviewModal(candidat: bloc.previewCandidat!),
      ],
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, CandidatsBloc bloc) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb — protégé contre overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              const Icon(CupertinoIcons.home,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              const Icon(CupertinoIcons.chevron_forward,
                  size: 11, color: AppColors.textMuted),
              const SizedBox(width: 5),
              const Text('Admin',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(width: 5),
              const Icon(CupertinoIcons.chevron_forward,
                  size: 11, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                _activeTab == _AdminTab.candidats ? 'Candidats' : 'SMS',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Titre + actions — adaptatif via LayoutBuilder
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;

            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeTab == _AdminTab.candidats ? 'CANDIDATS' : 'ENVOI SMS',
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: 3),
                Text(
                  bloc.isLoading
                      ? 'Chargement…'
                      : '${bloc.totalCount} inscription(s)',
                  style: AppTextStyles.subtitle,
                ),
              ],
            );

            final searchField = _activeTab == _AdminTab.candidats
                ? SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          context.read<CandidatsBloc>().setSearch(v),
                      style: const TextStyle(fontSize: 13),
                      decoration: AppDecorations.searchField(
                        hint: 'Rechercher…',
                        prefix: const Icon(CupertinoIcons.search,
                            size: 15, color: AppColors.textMuted),
                        suffix: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 14,
                                    color: AppColors.textMuted),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  context.read<CandidatsBloc>().clearSearch();
                                },
                              )
                            : null,
                      ),
                    ),
                  )
                : const SizedBox.shrink();

            final smsBtnVisible =
                bloc.selectedCount > 0 && _activeTab == _AdminTab.candidats;
            final smsBtn = smsBtnVisible
                ? GestureDetector(
                    onTap: () => setState(() => _activeTab = _AdminTab.sms),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(CupertinoIcons.paperplane_fill,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('SMS (${bloc.selectedCount})',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  )
                : const SizedBox.shrink();

            final refreshBtn = RefreshButton(
              onTap: () => context.read<CandidatsBloc>().refresh(),
              loading: bloc.isLoading,
            );

            if (isNarrow) {
              // Empilé : titre / recherche + boutons
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: searchField),
                    if (smsBtnVisible) ...[const SizedBox(width: 8), smsBtn],
                    const SizedBox(width: 8),
                    refreshBtn,
                  ]),
                ],
              );
            }

            // Large : titre à gauche, contrôles à droite sur même ligne
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                titleBlock,
                const Spacer(),
                if (_activeTab == _AdminTab.candidats)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          (constraints.maxWidth * 0.32).clamp(160.0, 280.0),
                      minWidth: 160,
                    ),
                    child: searchField,
                  ),
                if (smsBtnVisible) ...[const SizedBox(width: 10), smsBtn],
                const SizedBox(width: 10),
                refreshBtn,
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Stats bar ──────────────────────────────────────────────────────────────

  Widget _buildStatsBar(CandidatsBloc bloc) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      // Wrap : les chips passent à la ligne sur petits écrans
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        StatChip(
            label: 'Total',
            value: '${bloc.totalCount}',
            color: AppColors.accent),
        StatChip(
            label: 'GOOR YALLA YI',
            value: '${bloc.countMasculin}',
            color: AppColors.tagBlueFg,
            bg: AppColors.tagBlue),
        StatChip(
            label: 'SOXNA YI',
            value: '${bloc.countFeminin}',
            color: AppColors.tagPurpleFg,
            bg: AppColors.tagPurple),
        StatChip(
            label: 'Avec fichier',
            value: '${bloc.countAvecFichier}',
            color: AppColors.tagGreenFg,
            bg: AppColors.tagGreen),
        StatChip(
            label: 'Cloudinary',
            value: '${bloc.countCloudinary}',
            color: AppColors.tagBlueFg,
            bg: AppColors.tagBlue),
      ]),
    );
  }

  // ─── Onglets ────────────────────────────────────────────────────────────────

  Widget _buildTabs(BuildContext context, CandidatsBloc bloc) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _Tab(
            label: 'Liste des candidats',
            icon: CupertinoIcons.person_2,
            isActive: _activeTab == _AdminTab.candidats,
            onTap: () => setState(() => _activeTab = _AdminTab.candidats),
          ),
          const SizedBox(width: 4),
          _Tab(
            label: 'Envoyer SMS',
            icon: CupertinoIcons.chat_bubble_text,
            isActive: _activeTab == _AdminTab.sms,
            badge: bloc.selectedCount > 0 ? '${bloc.selectedCount}' : null,
            onTap: () => setState(() => _activeTab = _AdminTab.sms),
          ),
        ]),
      ),
    );
  }
}

// ─── Widget onglet ────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: isActive ? AppColors.accent : Colors.transparent,
            width: 2.5,
          )),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 14,
              color: isActive ? AppColors.accent : AppColors.textMuted),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.accent : AppColors.textMuted)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      ),
    );
  }
}
