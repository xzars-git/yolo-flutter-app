import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/detail_telusur_mandiri_ocr/view/detail_telusur_mandiri_ocr_view.dart';
import 'package:ultralytics_yolo_example/service/bluetooth_printer_service.dart';

class DetailTelusurMandiriOcrController extends State<DetailTelusurMandiriOcrView> {
  static late DetailTelusurMandiriOcrController instance;
  late DetailTelusurMandiriOcrView view;

  @override
  void initState() {
    super.initState();
    instance = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  void onReady() {}

  @override
  void dispose() {
    super.dispose();
  }

  final printerService = BluetoothPrinterService();

  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
