import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class FilterButtonBase extends StatefulWidget {
  final int jumlahFilter;
  final Function() onPressed;
  final double height;
  const FilterButtonBase({
    super.key,
    required this.jumlahFilter,
    required this.onPressed,
    required this.height,
  });

  @override
  State<FilterButtonBase> createState() => _FilterButtonBaseState();
}

class _FilterButtonBaseState extends State<FilterButtonBase> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.jumlahFilter == 0
            ? SizedBox(
                height: widget.height,
                child: OutlinedButton(
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const WidgetStatePropertyAll(neutralWhite),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    side: const WidgetStatePropertyAll(BorderSide(color: blue800)),
                    overlayColor: WidgetStateProperty.all<Color>(blue200),
                  ),
                  onPressed: widget.onPressed,
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icons/misc/filter_alt.svg"),
                      const SizedBox(width: 8.0),
                      Text("Filter :", style: myTextTheme.labelMedium?.copyWith(color: blue800)),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: widget.height,
                child: OutlinedButton(
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const WidgetStatePropertyAll(neutralWhite),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    side: const WidgetStatePropertyAll(BorderSide(color: blue800)),
                    overlayColor: WidgetStateProperty.all<Color>(blue200),
                  ),
                  onPressed: widget.onPressed,
                  child: Row(
                    children: [
                      Text("Diterapkan", style: myTextTheme.bodySmall?.copyWith(color: blue800)),
                      const SizedBox(width: 8.0),
                      widget.jumlahFilter == 0
                          ? Container()
                          : CircleAvatar(
                              radius: 12,
                              backgroundColor: blue800,
                              child: Text(
                                widget.jumlahFilter.toString(),
                                style: myTextTheme.bodySmall?.copyWith(color: neutralWhite),
                              ),
                            ),
                      widget.jumlahFilter == 0 ? Container() : const SizedBox(width: 8.0),
                      SvgPicture.asset(
                        "assets/icons/input/chevron-kanan.svg",
                        // ignore: deprecated_member_use
                        color: blue800,
                        height: 12,
                        width: 12,
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}
