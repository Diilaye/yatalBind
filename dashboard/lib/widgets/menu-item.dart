import 'package:flutter/material.dart';
import 'package:dashboard/utils/app_theme.dart';

class ItemMenu extends StatefulWidget {
  final String titre;
  final IconData icons;
  final double sizeIcon;
  final bool haveIcon;
  final bool isActive;
  final VoidCallback ontap;
  final String? badge; // optionnel : badge numérique

  const ItemMenu({
    super.key,
    required this.titre,
    required this.icons,
    required this.ontap,
    this.haveIcon = true,
    this.sizeIcon = 8,
    this.isActive = false,
    this.badge,
  });

  @override
  State<ItemMenu> createState() => _ItemMenuState();
}

class _ItemMenuState extends State<ItemMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isHighlighted = widget.isActive || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.ontap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.noir.withOpacity(0.06)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                width: isHighlighted ? 3 : 0,
                color: AppColors.accent,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: widget.haveIcon
                      ? widget.sizeIcon != 8
                          ? size.width * .025
                          : size.width * .035
                      : size.width * .025,
                ),
                if (widget.haveIcon) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? AppColors.accent.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      widget.icons,
                      color:
                          widget.isActive ? AppColors.accent : AppColors.noir,
                      size: widget.sizeIcon,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.titre,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isActive ? AppColors.accent : AppColors.noir,
                    fontWeight: widget.isActive || widget.haveIcon == false
                        ? FontWeight.bold
                        : _hovered
                            ? FontWeight.w600
                            : FontWeight.w400,
                  ),
                ),
                if (widget.badge != null) ...[
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
