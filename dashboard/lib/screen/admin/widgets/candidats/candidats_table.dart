import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/screen/admin/widgets/shared/shared_widgets.dart';
import 'package:dashboard/screen/admin/widgets/candidats/candidats_row.dart';

// Largeur minimum du tableau avant scroll horizontal
const double _kTableMinWidth = 760.0;

class CandidatsTable extends StatelessWidget {
  const CandidatsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CandidatsBloc>();

    if (bloc.isLoading) return const _TableSkeleton();
    if (bloc.errorMessage != null) return _TableError(bloc: bloc);

    return LayoutBuilder(builder: (context, constraints) {
      final needsScroll = constraints.maxWidth < _kTableMinWidth;

      final table = Container(
        width: needsScroll ? _kTableMinWidth : double.infinity,
        decoration: AppDecorations.card(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [
            if (bloc.selectedCount > 0) _SelectionBar(bloc: bloc),
            const _TableHeader(),
            const Divider(height: 1, color: AppColors.border),
            if (bloc.paginated.isEmpty)
              _buildEmptyState()
            else
              ...bloc.paginated.asMap().entries.map((entry) {
                final idx = entry.key;
                final candidat = entry.value;
                return Column(children: [
                  CandidatRow(
                    candidat: candidat,
                    isEven: idx.isEven,
                    globalIndex: (bloc.currentPage - 1) * 25 + idx + 1,
                  ),
                  if (idx < bloc.paginated.length - 1)
                    const Divider(
                        height: 1, color: AppColors.border, indent: 16),
                ]);
              }),
            const Divider(height: 1, color: AppColors.border),
            _TablePagination(bloc: bloc),
          ]),
        ),
      );

      if (needsScroll) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      }
      return table;
    });
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(CupertinoIcons.person_2,
            size: 42, color: AppColors.textMuted.withOpacity(0.5)),
        const SizedBox(height: 12),
        const Text('Aucun candidat trouvé',
            style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── Barre de sélection ───────────────────────────────────────────────────────

class _SelectionBar extends StatelessWidget {
  final CandidatsBloc bloc;
  const _SelectionBar({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: AppColors.accent.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(6)),
            child: Text('${bloc.selectedCount} sélectionné(s)',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton.icon(
            onPressed: () => bloc.selectAll(),
            icon: const Icon(CupertinoIcons.checkmark_square,
                size: 14, color: AppColors.accent),
            label: const Text('Tout sélectionner',
                style: TextStyle(fontSize: 12, color: AppColors.accent)),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),
          TextButton.icon(
            onPressed: () => bloc.clearSelection(),
            icon: const Icon(CupertinoIcons.xmark_square,
                size: 14, color: AppColors.textMuted),
            label: const Text('Désélectionner',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),
          const Text('Sélectionnez des destinataires pour envoyer un SMS',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: const Row(children: [
        SizedBox(width: 28),
        _HeaderCell('#', flex: 1),
        _HeaderCell('CANDIDAT', flex: 3),
        _HeaderCell('TÉLÉPHONE', flex: 2),
        _HeaderCell('DATE NAISS.', flex: 2),
        _HeaderCell('INSCRIPTION', flex: 2),
        _HeaderCell('FICHIER', flex: 2),
        _HeaderCell('ACTIONS', flex: 2, align: TextAlign.center),
      ]),
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
      child: Text(label,
          textAlign: align,
          style: AppTextStyles.tableHeader,
          overflow: TextOverflow.ellipsis),
    );
  }
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class _TablePagination extends StatelessWidget {
  final CandidatsBloc bloc;
  const _TablePagination({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 500;

      final rangeLabel = Text(bloc.rangeLabel,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500));

      final pageControls = Row(mainAxisSize: MainAxisSize.min, children: [
        PaginationButton(
          icon: CupertinoIcons.chevron_left,
          enabled: bloc.canGoPrev,
          onTap: () => context.read<CandidatsBloc>().previousPage(),
        ),
        const SizedBox(width: 4),
        ..._buildPageNumbers(context, bloc),
        const SizedBox(width: 4),
        PaginationButton(
          icon: CupertinoIcons.chevron_right,
          enabled: bloc.canGoNext,
          onTap: () => context.read<CandidatsBloc>().nextPage(),
        ),
      ]);

      if (isNarrow) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            rangeLabel,
            const SizedBox(height: 8),
            pageControls,
          ]),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          rangeLabel,
          const Spacer(),
          pageControls,
        ]),
      );
    });
  }

  List<Widget> _buildPageNumbers(BuildContext context, CandidatsBloc bloc) {
    final total = bloc.totalPages;
    final current = bloc.currentPage;
    final pages = <int>[];

    if (total <= 7) {
      pages.addAll(List.generate(total, (i) => i + 1));
    } else {
      pages.add(1);
      if (current > 3) pages.add(-1);
      for (int i = (current - 1).clamp(2, total - 1);
          i <= (current + 1).clamp(2, total - 1);
          i++) {
        pages.add(i);
      }
      if (current < total - 2) pages.add(-1);
      pages.add(total);
    }

    return pages.map((p) {
      if (p == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
            color: isActive ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: isActive ? AppColors.accent : AppColors.border),
          ),
          child: Center(
            child: Text('$p',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : AppColors.noir,
                )),
          ),
        ),
      );
    }).toList();
  }
}

// ─── Skeleton loader ──────────────────────────────────────────────────────────

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(
            8,
            (i) => Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      ShimmerBox(width: 60, height: 12),
                      const SizedBox(width: 16),
                      ShimmerBox(width: 140, height: 12),
                      const SizedBox(width: 16),
                      ShimmerBox(width: 100, height: 12),
                      const SizedBox(width: 16),
                      ShimmerBox(width: 80, height: 12),
                      const Spacer(),
                      ShimmerBox(width: 60, height: 28),
                    ]),
                  ),
                  if (i < 7) const Divider(height: 1, color: AppColors.border),
                ])),
      ),
    );
  }
}

// ─── État erreur ──────────────────────────────────────────────────────────────

class _TableError extends StatelessWidget {
  final CandidatsBloc bloc;
  const _TableError({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(CupertinoIcons.exclamationmark_circle,
            size: 36, color: AppColors.tagRedFg),
        const SizedBox(height: 10),
        Text(bloc.errorMessage ?? 'Erreur inconnue',
            style: const TextStyle(
                color: AppColors.tagRedFg, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => context.read<CandidatsBloc>().refresh(),
          icon: const Icon(CupertinoIcons.refresh, size: 14),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }
}
