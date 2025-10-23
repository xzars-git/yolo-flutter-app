import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/formater/formater.dart';
import 'package:ultralytics_yolo_example/widget/form/base_form_nopol.dart';
import 'package:validatorless/validatorless.dart';

class TextFieldNomorPolisi extends StatefulWidget {
  final Color warnaFont;
  final Color warnaPlaceholder;
  final GlobalKey globalKey;
  final Function(String? value) onChangedTextfieldOne;
  final Function(String? value) onChangedTextfieldTwo;
  final Function(String? value) onChangedTextfieldThree;
  final FocusNode focusNode1;
  final FocusNode focusNode2;
  final FocusNode focusNode3;
  final TextEditingController textEditingController1;
  final TextEditingController textEditingController2;
  final TextEditingController textEditingController3;
  final String? title;
  const TextFieldNomorPolisi({
    super.key,
    required this.warnaFont,
    required this.warnaPlaceholder,
    required this.onChangedTextfieldOne,
    required this.onChangedTextfieldTwo,
    required this.onChangedTextfieldThree,
    required this.focusNode1,
    required this.focusNode2,
    required this.focusNode3,
    required this.textEditingController1,
    required this.textEditingController2,
    required this.textEditingController3,
    required this.globalKey,
    this.title,
  });

  @override
  State<TextFieldNomorPolisi> createState() => _TextFieldNomorPolisi();
}

class _TextFieldNomorPolisi extends State<TextFieldNomorPolisi> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.globalKey,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title ?? "Nomor Polisi",
              style: myTextTheme.labelLarge?.copyWith(color: gray900),
            ),
          ),
          const SizedBox(height: 2.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BaseFormNopol(
                  textEditingController: widget.textEditingController1,
                  focusNode: widget.focusNode1,
                  validator: Validatorless.required('TNKB Daerah harus diisi'),
                  textInputType: TextInputType.text,
                  textInputFormater: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                    UpperCaseTextFormatter(),
                  ],
                  maxLength: 2,
                  hintText: "XX",
                  onChanged: widget.onChangedTextfieldOne,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: BaseFormNopol(
                  textEditingController: widget.textEditingController2,
                  focusNode: widget.focusNode2,
                  textInputType: TextInputType.number,
                  textInputFormater: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validatorless.required('TNKB Nomor harus diisi'),
                  maxLength: 4,
                  hintText: "XXXX",
                  onChanged: widget.onChangedTextfieldTwo,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: BaseFormNopol(
                  textEditingController: widget.textEditingController3,
                  focusNode: widget.focusNode3,
                  textInputType: TextInputType.text,
                  textInputFormater: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                    UpperCaseTextFormatter(),
                  ],
                  validator: Validatorless.required('TNKB Sub Daerah harus diisi'),
                  maxLength: 3,
                  hintText: "XXX",
                  onChanged: widget.onChangedTextfieldThree,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
