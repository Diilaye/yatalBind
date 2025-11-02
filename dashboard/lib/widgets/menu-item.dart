import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemMenu extends StatefulWidget {
  final String titre;
  final IconData icons;
  final double sizeIcon;
  final bool haveIcon;
  final bool isActive;
  final Function ontap;
  const ItemMenu(
      {super.key,
      required this.titre,
      required this.icons,
      required this.ontap,
      this.haveIcon = true,
      this.sizeIcon = 8,
      this.isActive = false});

  @override
  State<ItemMenu> createState() => _ItemMenuState();
}

class _ItemMenuState extends State<ItemMenu> {
  bool ishover = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() {
        ishover = true;
      }),
      onExit: (event) => setState(() {
        ishover = false;
      }),
      child: GestureDetector(
        onTap: () => widget.ontap(),
        child: Container(
          decoration: BoxDecoration(
              color: widget.isActive
                  ? noir.withOpacity(.3)
                  : ishover
                      ? noir.withOpacity(.3)
                      : blanc,
              border: Border(
                  left: BorderSide(
                      width: widget.isActive
                          ? 3
                          : ishover
                              ? 3
                              : 0,
                      color: vert))),
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: widget.haveIcon
                        ? widget.sizeIcon != 8
                            ? size.width * .025
                            : size.width * .035
                        : size.width * .025,
                  ),
                  if (widget.haveIcon)
                    Icon(
                      widget.icons,
                      color: noir,
                      size: widget.sizeIcon,
                    ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    widget.titre,
                    style: widget.haveIcon
                        ? ishover
                            ? fontFammilyDii(context, 14, noir, FontWeight.bold,
                                FontStyle.normal)
                            : fontFammilyDii(context, 14, noir, FontWeight.w400,
                                FontStyle.normal)
                        : fontFammilyDii(context, 14, noir, FontWeight.bold,
                            FontStyle.normal),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
