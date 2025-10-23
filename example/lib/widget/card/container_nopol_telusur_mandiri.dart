import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/formater/formater.dart';

class ContainerNomorPolisiTelusurMandiri extends StatefulWidget {
  final String? initialValue;
  final bool? isAutoFocus2;
  final Color warnaPlat;
  final Color warnaBorder;
  final Color warnaFont;
  final Color warnaPlaceholder;
  final Function(String? value) onChangedTextfieldOne;
  final Function(String? value) onChangedTextfieldTwo;
  final Function(String? value) onChangedTextfieldThree;
  final FocusNode focusNode1;
  final FocusNode focusNode2;
  final FocusNode focusNode3;
  final Function()? onInitState;
  final Function()? onEditingComplete;
  const ContainerNomorPolisiTelusurMandiri({
    super.key,
    this.initialValue,
    this.isAutoFocus2,
    required this.warnaPlat,
    required this.warnaBorder,
    required this.warnaFont,
    required this.warnaPlaceholder,
    required this.onChangedTextfieldOne,
    required this.onChangedTextfieldTwo,
    required this.onChangedTextfieldThree,
    required this.focusNode1,
    required this.focusNode2,
    required this.focusNode3,
    this.onEditingComplete,
    this.onInitState,
  });

  @override
  State<ContainerNomorPolisiTelusurMandiri> createState() =>
      _ContainerNomorPolisiTelusurMandiriState();
}

class _ContainerNomorPolisiTelusurMandiriState extends State<ContainerNomorPolisiTelusurMandiri> {
  @override
  void initState() {
    super.initState();
    widget.onInitState;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.warnaPlat,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          border: Border.all(color: widget.warnaBorder),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: widget.initialValue,
                  focusNode: widget.focusNode1,
                  cursorColor: widget.warnaFont,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                  ],
                  textAlign: TextAlign.center,
                  style: largestBebasNeue.copyWith(color: widget.warnaFont),
                  maxLength: 1,
                  decoration: InputDecoration(
                    hintText: "X",
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    fillColor: widget.warnaPlat,
                    counterText: "",
                    hintStyle: largestBebasNeue.copyWith(color: widget.warnaFont),
                    labelStyle: TextStyle(color: widget.warnaFont),
                  ),
                  onChanged: widget.onChangedTextfieldOne,
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  focusNode: widget.focusNode2,
                  cursorColor: widget.warnaFont,
                  autofocus: widget.isAutoFocus2 ?? true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: largestBebasNeue.copyWith(color: widget.warnaFont),
                  maxLength: 4,
                  decoration: InputDecoration(
                    hintText: "XXXX",
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    fillColor: widget.warnaPlat,
                    counterText: "",
                    hintStyle: largestBebasNeue.copyWith(color: widget.warnaFont),
                    labelStyle: TextStyle(color: widget.warnaFont),
                  ),
                  onChanged: widget.onChangedTextfieldTwo,
                ),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  focusNode: widget.focusNode3,
                  cursorColor: widget.warnaFont,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z.]')),
                  ],
                  textAlign: TextAlign.center,
                  style: largestBebasNeue.copyWith(color: widget.warnaFont),
                  maxLength: 3,
                  onEditingComplete: widget.onEditingComplete,
                  decoration: InputDecoration(
                    hintText: "XXX",
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    fillColor: widget.warnaPlat,
                    counterText: "",
                    hintStyle: largestBebasNeue.copyWith(color: widget.warnaFont),
                    labelStyle: TextStyle(color: widget.warnaFont),
                  ),
                  onChanged: widget.onChangedTextfieldThree,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
