// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

enum LoadingPosition { start, end, center }

class PrimaryButton extends StatefulWidget {
  final Function()? onPressed;
  final String? text;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool? isDense;
  final bool? isLoading;
  final String? loadingText;
  final LoadingPosition? loadingPosition;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.isDense,
    this.isLoading,
    this.loadingText,
    this.loadingPosition = LoadingPosition.center,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isDense ?? false ? null : MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          backgroundColor: (widget.onPressed == null)
              ? const WidgetStatePropertyAll(gray300)
              : WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          overlayColor: WidgetStateProperty.all<Color>(
            (widget.onPressed == null)
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        onPressed: (widget.isLoading ?? false) ? null : widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show loading indicator when isLoading is true
                if (widget.isLoading ?? false) ...[
                  // Start position: indicator before text
                  if (widget.loadingPosition == LoadingPosition.start) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (trimString(widget.loadingText).isNotEmpty) const SizedBox(width: 16.0),
                    if (trimString(widget.loadingText).isNotEmpty)
                      Text(
                        trimString(widget.loadingText),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: (widget.onPressed == null || widget.isLoading == true)
                              ? Theme.of(context).colorScheme.onTertiary
                              : Theme.of(context).colorScheme.onPrimary,
                          height: 1.75,
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                  ]
                  // End position: text before indicator
                  else if (widget.loadingPosition == LoadingPosition.end) ...[
                    if (trimString(widget.loadingText).isNotEmpty)
                      Text(
                        trimString(widget.loadingText),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: (widget.onPressed == null || widget.isLoading == true)
                              ? Theme.of(context).colorScheme.onTertiary
                              : Theme.of(context).colorScheme.onPrimary,
                          height: 1.75,
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    if (trimString(widget.loadingText).isNotEmpty) const SizedBox(width: 16.0),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ]
                  // Center position: only indicator (no text)
                  else ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ]
                // Show normal content when not loading
                else ...[
                  if (trimString(widget.prefixIcon).isNotEmpty)
                    SvgPicture.asset(
                      trimString(widget.prefixIcon),
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        (widget.onPressed == null || widget.isLoading == true)
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  if (trimString(widget.prefixIcon).isNotEmpty &&
                      trimString(widget.text).isNotEmpty)
                    const SizedBox(width: 8.0),
                  if (trimString(widget.text).isNotEmpty)
                    Text(
                      trimString(widget.text),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: (widget.onPressed == null || widget.isLoading == true)
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context).colorScheme.onPrimary,
                        height: 1.75,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  if (trimString(widget.suffixIcon).isNotEmpty &&
                      trimString(widget.text).isNotEmpty)
                    const SizedBox(width: 8.0),
                  if (trimString(widget.suffixIcon).isNotEmpty)
                    SvgPicture.asset(
                      trimString(widget.suffixIcon),
                      colorFilter: ColorFilter.mode(
                        (widget.onPressed == null || widget.isLoading == true)
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
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
