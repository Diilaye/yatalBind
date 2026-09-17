import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/bloc/sms-bloc.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/screen/admin/widgets/shared/shared_widgets.dart';

const double _kPanelBreak = 860.0;

class SmsComposePanel extends StatelessWidget {
  const SmsComposePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmsBloc(),
      child: const _SmsPanelContent(),
    );
  }
}

class _SmsPanelContent extends StatelessWidget {
  const _SmsPanelContent();

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SmsBloc>();

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= _kPanelBreak;

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: (constraints.maxWidth * 0.35).clamp(260.0, 340.0),
              child: _RecipientsPanel(bloc: bloc),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(bloc: bloc),
                  const SizedBox(height: 16),
                  _ComposeForm(bloc: bloc),
                ],
              ),
            ),
          ],
        );
      }

      // Layout étroit : colonne scrollable
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatsRow(bloc: bloc),
            const SizedBox(height: 16),
            _RecipientsPanel(bloc: bloc),
            const SizedBox(height: 16),
            _ComposeForm(bloc: bloc),
          ],
        ),
      );
    });
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final SmsBloc bloc;
  const _StatsRow({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final s = bloc.getStatistics();
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _StatsCard(
          label: 'Total',
          value: '${s['totalConcurants']}',
          icon: CupertinoIcons.person_2,
          color: AppColors.accent,
          bg: AppColors.accent.withOpacity(0.1)),
      _StatsCard(
          label: 'Avec tél.',
          value: '${s['validConcurants']}',
          icon: CupertinoIcons.phone,
          color: AppColors.tagGreenFg,
          bg: AppColors.tagGreen),
      _StatsCard(
          label: 'Sélectionnés',
          value: '${s['selectedConcurants']}',
          icon: CupertinoIcons.checkmark_circle,
          color: AppColors.tagBlueFg,
          bg: AppColors.tagBlue),
      if (bloc.filePhoneCount > 0)
        _StatsCard(
            label: 'Fichier',
            value: '${s['phoneNumbersFromFile']}',
            icon: CupertinoIcons.doc_text,
            color: AppColors.tagPurpleFg,
            bg: AppColors.tagPurple),
      _StatsCard(
          label: 'Destinataires',
          value: '${s['totalRecipients']}',
          icon: CupertinoIcons.paperplane,
          color: Colors.white,
          bg: AppColors.accent,
          isHighlighted: true),
    ]);
  }
}

class _StatsCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  final bool isHighlighted;
  const _StatsCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bg,
      this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isHighlighted ? AppColors.accent : AppColors.border),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 7),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isHighlighted
                          ? color.withOpacity(0.8)
                          : AppColors.textMuted)),
            ]),
      ]),
    );
  }
}

// ─── Panneau destinataires ────────────────────────────────────────────────────

class _RecipientsPanel extends StatefulWidget {
  final SmsBloc bloc;
  const _RecipientsPanel({required this.bloc});
  @override
  State<_RecipientsPanel> createState() => _RecipientsPanelState();
}

class _RecipientsPanelState extends State<_RecipientsPanel> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.bloc.searchText;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SmsBloc>();
    final filtered = bloc.filteredConcurants;
    final total =
        bloc.allConcurants.where((c) => c.telephone?.isNotEmpty == true).length;

    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RecipientsPanelHeader(
              bloc: bloc, searchCtrl: _searchCtrl, total: total),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 440),
            child: bloc.isLoading
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2)))
                : filtered.isEmpty
                    ? _buildEmpty(bloc)
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _RecipientTile(
                          candidat: filtered[i],
                          isSelected: bloc.isConcurantSelected(filtered[i]),
                          onToggle: () => context
                              .read<SmsBloc>()
                              .toggleConcurantSelection(filtered[i]),
                          isLast: i == filtered.length - 1,
                        ),
                      ),
          ),
          _FileImportFooter(bloc: bloc),
        ],
      ),
    );
  }

  Widget _buildEmpty(SmsBloc bloc) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
                bloc.searchText.isNotEmpty
                    ? CupertinoIcons.search
                    : CupertinoIcons.person_crop_circle_badge_xmark,
                size: 32,
                color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
                bloc.searchText.isNotEmpty
                    ? 'Aucun résultat'
                    : 'Aucun concurant',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (!bloc.isLoading) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.read<SmsBloc>().refreshConcurants(),
                child: const Text('Actualiser',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ),
      );
}

// ─── Header panel destinataires ───────────────────────────────────────────────

class _RecipientsPanelHeader extends StatelessWidget {
  final SmsBloc bloc;
  final TextEditingController searchCtrl;
  final int total;
  const _RecipientsPanelHeader(
      {required this.bloc, required this.searchCtrl, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(CupertinoIcons.person_2_fill,
              size: 13, color: AppColors.accent),
          const SizedBox(width: 7),
          const Expanded(
              child: Text('DESTINATAIRES',
                  style: AppTextStyles.tableHeader,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('${bloc.selectedCount} / $total',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: bloc.selectedCount > 0
                      ? AppColors.accent
                      : AppColors.textMuted)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: TextField(
            controller: searchCtrl,
            onChanged: (v) => context.read<SmsBloc>().setSearchText(v),
            style: const TextStyle(fontSize: 12),
            decoration: AppDecorations.searchField(
              hint: 'Nom, téléphone, daara…',
              prefix: const Icon(CupertinoIcons.search,
                  size: 13, color: AppColors.textMuted),
              suffix: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill,
                          size: 13, color: AppColors.textMuted),
                      onPressed: () {
                        searchCtrl.clear();
                        context.read<SmsBloc>().clearSearch();
                      })
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Wrap : évite overflow quand les deux boutons ne rentrent pas sur une ligne
        Wrap(spacing: 6, runSpacing: 4, children: [
          _SmallBtn(
            label: bloc.isAllFilteredSelected
                ? 'Désélectionner'
                : 'Tout sélectionner',
            onTap: () => context.read<SmsBloc>().toggleSelectAll(),
            color: AppColors.accent,
          ),
          if (bloc.selectedCount > 0)
            _SmallBtn(
              label: 'Effacer (${bloc.selectedCount})',
              onTap: () => context.read<SmsBloc>().deselectAll(),
              color: AppColors.tagRedFg,
            ),
        ]),
      ]),
    );
  }
}

// ─── Footer import fichier ────────────────────────────────────────────────────

class _FileImportFooter extends StatelessWidget {
  final SmsBloc bloc;
  const _FileImportFooter({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Importer depuis un fichier',
            style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<SmsBloc>().loadPhoneNumbersFromFile(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.tagBlue,
                  borderRadius: BorderRadius.circular(7),
                  border:
                      Border.all(color: AppColors.tagBlueFg.withOpacity(0.3)),
                ),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.doc_text,
                          size: 13, color: AppColors.tagBlueFg),
                      SizedBox(width: 6),
                      Flexible(
                          child: Text('Importer CSV / TXT',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.tagBlueFg,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                    ]),
              ),
            ),
          ),
          if (bloc.filePhoneCount > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<SmsBloc>().clearPhoneNumbersFromFile(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.tagRed,
                    borderRadius: BorderRadius.circular(7)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(CupertinoIcons.xmark,
                      size: 11, color: AppColors.tagRedFg),
                  const SizedBox(width: 4),
                  Text('${bloc.filePhoneCount}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tagRedFg,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ]),
        if (bloc.filePhoneCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${bloc.filePhoneCount} numéro(s) importé(s)',
                style:
                    const TextStyle(fontSize: 10, color: AppColors.tagGreenFg)),
          ),
      ]),
    );
  }
}

// ─── Tuile destinataire ───────────────────────────────────────────────────────

class _RecipientTile extends StatelessWidget {
  final ConcurantModel candidat;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool isLast;
  const _RecipientTile(
      {required this.candidat,
      required this.isSelected,
      required this.onToggle,
      required this.isLast});

  @override
  Widget build(BuildContext context) {
    final hasPhone = candidat.telephone?.isNotEmpty == true;
    return Column(children: [
      GestureDetector(
        onTap: hasPhone ? onToggle : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: isSelected
              ? AppColors.accent.withOpacity(0.06)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(children: [
            // Checkbox — fixe 22px
            SizedBox(
              width: 22,
              height: 22,
              child: hasPhone
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggle(),
                      activeColor: AppColors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side:
                          const BorderSide(color: AppColors.border, width: 1.5))
                  : Tooltip(
                      message: 'Pas de téléphone',
                      child: Icon(CupertinoIcons.phone_solid,
                          size: 13,
                          color: AppColors.textMuted.withOpacity(0.4))),
            ),
            const SizedBox(width: 7),

            // Avatar — fixe 28px
            CandidatAvatar(
                initials: candidat.initials, sexe: candidat.sexe, size: 28),
            const SizedBox(width: 8),

            // Infos — Expanded absorbe l'espace, textes ellipsis
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(candidat.fullName,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasPhone
                              ? AppColors.textDark
                              : AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Row(children: [
                    Icon(CupertinoIcons.phone,
                        size: 9,
                        color: hasPhone
                            ? AppColors.accent
                            : AppColors.textMuted.withOpacity(0.5)),
                    const SizedBox(width: 3),
                    Flexible(
                        flex: 2,
                        child: Text(candidat.telephone ?? 'Pas de numéro',
                            style: TextStyle(
                                fontSize: 10,
                                color: hasPhone
                                    ? AppColors.textMuted
                                    : AppColors.textMuted.withOpacity(0.5)),
                            overflow: TextOverflow.ellipsis)),
                    if (candidat.daara != null) ...[
                      const SizedBox(width: 4),
                      Flexible(
                          flex: 3,
                          child: Text('· ${candidat.daara}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1)),
                    ],
                  ]),
                ])),

            // Dot indicateur
            if (isSelected)
              Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle)),
          ]),
        ),
      ),
      if (!isLast)
        const Divider(height: 1, color: AppColors.border, indent: 12),
    ]);
  }
}

// ─── Formulaire de composition ────────────────────────────────────────────────

class _ComposeForm extends StatelessWidget {
  final SmsBloc bloc;
  const _ComposeForm({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ComposeHeader(bloc: bloc),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _FieldLabel(label: 'Sujet / Titre', icon: CupertinoIcons.tag),
            const SizedBox(height: 8),
            _FormField(
                controller: bloc.subtitleController,
                hint: 'Ex: Résultats Dépouillement 2025',
                validator: () => bloc.validateSubject()),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _FieldLabel(
                      label: 'Message', icon: CupertinoIcons.text_quote)),
              _SmsCounter(bloc: bloc),
            ]),
            const SizedBox(height: 8),
            _FormField(
                controller: bloc.descController,
                hint: 'Rédigez votre message ici…',
                maxLines: 5,
                validator: () => bloc.validateMessage()),
            const SizedBox(height: 6),
            _CharProgressBar(count: bloc.messageLength, max: 160),
            const SizedBox(height: 16),
            if (bloc.selectedCount > 0)
              _RecipientsPreview(
                  candidats: bloc.selectedConcurants.take(5).toList(),
                  total: bloc.totalRecipients,
                  fileCount: bloc.filePhoneCount),
            if (bloc.status == SmsStatus.error && bloc.errorMessage != null)
              _StatusBanner(
                  message: bloc.errorMessage!,
                  isError: true,
                  onDismiss: () => context.read<SmsBloc>().clearStatus()),
            if (bloc.status == SmsStatus.success && bloc.successMessage != null)
              _StatusBanner(
                  message: bloc.successMessage!,
                  isError: false,
                  onDismiss: () => context.read<SmsBloc>().clearStatus()),
            const SizedBox(height: 4),
            _SendButton(bloc: bloc),
          ]),
        ),
      ]),
    );
  }
}

// ─── Header formulaire ────────────────────────────────────────────────────────

class _ComposeHeader extends StatelessWidget {
  final SmsBloc bloc;
  const _ComposeHeader({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        const Icon(CupertinoIcons.chat_bubble_text_fill,
            size: 14, color: AppColors.accent),
        const SizedBox(width: 8),
        const Expanded(
            child: Text('COMPOSER',
                style: AppTextStyles.tableHeader,
                overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                bloc.totalRecipients > 0 ? AppColors.accent : AppColors.tagRed,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            bloc.totalRecipients > 0
                ? '${bloc.totalRecipients} dest.'
                : 'Aucun',
            style: TextStyle(
                fontSize: 11,
                color: bloc.totalRecipients > 0
                    ? Colors.white
                    : AppColors.tagRedFg,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

// ─── Bouton envoyer ───────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final SmsBloc bloc;
  const _SendButton({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final canSend = !bloc.isSending && bloc.isFormValid;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: canSend
            ? () async {
                final ok = await context.read<SmsBloc>().sendSmsMessage();
                if (ok && context.mounted)
                  showSuccessSnack(context, 'SMS envoyé avec succès !');
              }
            : null,
        icon: bloc.isSending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(CupertinoIcons.paperplane_fill, size: 16),
        label: Text(
            bloc.isSending ? 'Envoi…' : 'Envoyer (${bloc.totalRecipients})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
          disabledForegroundColor: Colors.white54,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── FormField ────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function()? validator;
  const _FormField(
      {required this.controller,
      required this.hint,
      this.maxLines = 1,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textMuted, fontSize: 13, height: 1.5),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: EdgeInsets.symmetric(
            horizontal: 14, vertical: maxLines > 1 ? 14 : 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }
}

// ─── Compteur SMS ─────────────────────────────────────────────────────────────

class _SmsCounter extends StatelessWidget {
  final SmsBloc bloc;
  const _SmsCounter({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final over = bloc.messageLength > 160;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${bloc.messageLength}/160',
          style: TextStyle(
              fontSize: 11,
              color: over ? AppColors.tagRedFg : AppColors.textMuted)),
      const SizedBox(width: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
            color: over ? AppColors.tagRed : AppColors.tagGreen,
            borderRadius: BorderRadius.circular(4)),
        child: Text('${bloc.smsCount}SMS',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: over ? AppColors.tagRedFg : AppColors.tagGreenFg)),
      ),
    ]);
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _CharProgressBar extends StatelessWidget {
  final int count, max;
  const _CharProgressBar({required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = (count / max).clamp(0.0, 1.0);
    final over = count > max;
    final warn = count > max * 0.8;
    final color = over
        ? AppColors.tagRedFg
        : warn
            ? Colors.orange
            : AppColors.accent;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3)),
      const SizedBox(height: 4),
      Text(
          over ? '${count - max} car. en trop' : '${max - count} car. restants',
          style: TextStyle(fontSize: 10, color: color)),
    ]);
  }
}

// ─── Aperçu destinataires ────────────────────────────────────────────────────

class _RecipientsPreview extends StatelessWidget {
  final List<ConcurantModel> candidats;
  final int total, fileCount;
  const _RecipientsPreview(
      {required this.candidats, required this.total, required this.fileCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Text('Aperçu destinataires',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          AppTag(
              label: '$total total',
              bg: AppColors.accent.withOpacity(0.1),
              fg: AppColors.accent),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 5, runSpacing: 5, children: [
          ...candidats.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CandidatAvatar(initials: c.initials, sexe: c.sexe, size: 16),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text('${c.fullName} · ${c.telephone}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              )),
          if (total > candidats.length)
            AppTag(
                label: '+${total - candidats.length}',
                bg: AppColors.accent.withOpacity(0.08),
                fg: AppColors.accent),
          if (fileCount > 0)
            AppTag(
                label: '$fileCount fichier',
                icon: CupertinoIcons.doc_text,
                bg: AppColors.tagPurple,
                fg: AppColors.tagPurpleFg),
        ]),
      ]),
    );
  }
}

// ─── Bannière statut ──────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;
  const _StatusBanner(
      {required this.message, required this.isError, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final bg = isError ? AppColors.tagRed : AppColors.tagGreen;
    final fg = isError ? AppColors.tagRedFg : AppColors.tagGreenFg;
    final icon = isError
        ? CupertinoIcons.exclamationmark_circle
        : CupertinoIcons.checkmark_circle;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12, color: fg),
                overflow: TextOverflow.ellipsis,
                maxLines: 2)),
        GestureDetector(
            onTap: onDismiss,
            child: Icon(CupertinoIcons.xmark, size: 12, color: fg)),
      ]),
    );
  }
}

// ─── Utilitaires ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.accent),
      const SizedBox(width: 6),
      Flexible(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _SmallBtn(
      {required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(5)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
