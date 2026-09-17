// lib/screen/admin/widgets/shared/shared_widgets.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/utils/app_theme.dart';
import 'package:dashboard/models/concurant-model.dart';

// ─── Shimmer loader ────────────────────────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
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
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: [
              AppColors.border,
              Colors.grey[200]!,
              AppColors.border,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tag coloré ───────────────────────────────────────────────────────────────

class AppTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const AppTag({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton icône avec tooltip ────────────────────────────────────────────────

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final double size;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.bg,
    required this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: size * 0.5, color: color),
        ),
      ),
    );
  }
}

// ─── Bouton avec label ────────────────────────────────────────────────────────

class LabeledActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const LabeledActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

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
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bouton refresh ───────────────────────────────────────────────────────────

class RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  final String tooltip;

  const RefreshButton({
    super.key,
    required this.onTap,
    this.loading = false,
    this.tooltip = 'Actualiser',
  });

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
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accent),
                  ),
                )
              : const Icon(CupertinoIcons.refresh,
                  size: 16, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

// ─── Bouton pagination ────────────────────────────────────────────────────────

class PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const PaginationButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 13,
          color:
              enabled ? AppColors.noir : AppColors.textMuted.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Avatar candidat ──────────────────────────────────────────────────────────

class CandidatAvatar extends StatelessWidget {
  final String initials;
  final String? sexe;
  final double size;

  const CandidatAvatar({
    super.key,
    required this.initials,
    this.sexe,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final isFeminin = sexe == 'feminin';
    final bg = isFeminin ? AppColors.tagPurple : AppColors.tagBlue;
    final fg = isFeminin ? AppColors.tagPurpleFg : AppColors.tagBlueFg;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ─── Badge fichier ────────────────────────────────────────────────────────────

class FichierBadge extends StatelessWidget {
  final FichierJustificatif fichier;

  const FichierBadge({super.key, required this.fichier});

  @override
  Widget build(BuildContext context) {
    final isImg = fichier.isImage;
    final isPdf = fichier.isPdf;
    final ext = fichier.typeFichier?.toUpperCase() ?? '?';

    final Color bg;
    final Color fg;
    final IconData icon;

    if (isImg) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
      icon = CupertinoIcons.photo;
    } else if (isPdf) {
      bg = AppColors.tagRed;
      fg = AppColors.tagRedFg;
      icon = CupertinoIcons.doc_richtext;
    } else {
      bg = AppColors.tagBlue;
      fg = AppColors.tagBlueFg;
      icon = CupertinoIcons.doc_text;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            ext,
            style:
                TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}

// ─── Stat chip ────────────────────────────────────────────────────────────────

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? bg;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.bg,
  });

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

// ─── Snackbar helper ──────────────────────────────────────────────────────────

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(CupertinoIcons.checkmark_circle,
          color: Colors.white, size: 15),
      const SizedBox(width: 8),
      Text(message, style: const TextStyle(fontSize: 13)),
    ]),
    backgroundColor: AppColors.accent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  ));
}

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 13)),
    backgroundColor: AppColors.tagRedFg,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}
