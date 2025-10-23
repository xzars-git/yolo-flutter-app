import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class CustomExpansionTile extends StatefulWidget {
  final String? leadingIcon;
  final Widget? trailingIconOn;
  final Widget? trailingIconOff;
  final String title;
  final Widget children;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool? initiallyExpanded;
  final BoxBorder? border;

  const CustomExpansionTile({
    super.key,
    this.leadingIcon,
    this.trailingIconOn,
    this.trailingIconOff,
    required this.title,
    required this.children,
    this.borderRadius,
    this.padding,
    this.initiallyExpanded,
    this.border,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: neutralWhite,
        border: widget.border ?? Border.all(color: blueGray50, width: 1.0),
      ),
      child: ListTileTheme(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          onExpansionChanged: (bool expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          trailing: isExpanded
              ? widget.trailingIconOn ?? const Icon(Icons.expand_less)
              : widget.trailingIconOff ?? const Icon(Icons.expand_more),
          iconColor: primaryGreen,
          initiallyExpanded: widget.initiallyExpanded ?? false,
          shape: Border.all(color: Colors.transparent),
          collapsedIconColor: primaryGreen,
          leading: widget.leadingIcon == null ? null : SvgPicture.asset(widget.leadingIcon ?? ""),
          title: Text(widget.title, style: myTextTheme.titleMedium),
          children: [
            Padding(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
              child: widget.children,
            ),
          ],
        ),
      ),
    );
  }
}
