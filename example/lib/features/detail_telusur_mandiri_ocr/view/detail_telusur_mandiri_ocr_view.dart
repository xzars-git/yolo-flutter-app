import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:printing/printing.dart';
import 'package:ultralytics_yolo_example/app/routes.dart';
import 'package:ultralytics_yolo_example/features/detail_telusur_mandiri_ocr/controller/detail_telusur_mandiri_ocr_controller.dart';
import 'package:ultralytics_yolo_example/features/detail_telusur_mandiri_ocr/utils/detail_telusur_mandiri_ocr_utils.dart';
import 'package:ultralytics_yolo_example/features/detail_telusur_mandiri_ocr/utils/pajak_pdf_generator.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';
import 'package:ultralytics_yolo_example/widget/button/primary_button.dart';
import 'package:ultralytics_yolo_example/widget/card/custom_expansion_tile.dart';

class DetailTelusurMandiriOcrView extends StatefulWidget {
  final DataKendaraan? dataKendaraan;
  final String? kodePlat;
  const DetailTelusurMandiriOcrView({super.key, this.dataKendaraan, this.kodePlat});

  Widget build(context, DetailTelusurMandiriOcrController controller) {
    controller.view = this;

    // Validasi format noWa dan email
    final isValidWa = _isValidWa(dataKendaraan?.noWa);
    final isValidEmail = _isValidEmail(dataKendaraan?.email);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Detail Data"),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                await controller.printerService.selectDeviceWithDialog(context);
                controller.update();
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          padding: const EdgeInsets.all(16.0),
          color: neutralWhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(onPressed: isValidWa ? () {} : null, text: "Kirim Via Wa"),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isValidEmail ? () {} : null,
                      text: "Kirim Via Email",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: controller.printerService,
                  builder: (context, child) {
                    return TextButton(
                      onPressed: controller.printerService.isConnected
                          ? () async {
                              try {
                                final pdfBytes = await PajakPdfGenerator.generate(
                                  dataKendaraan ?? DataKendaraan(),
                                  dataKendaraan?.dataHitungPajak,
                                );
                                final pages = Printing.raster(pdfBytes, dpi: 300);
                                final pageList = await pages.toList();
                                debugPrint('Rasterized into ${pageList.length} image(s)');
                                for (var i = 0; i < pageList.length; i++) {
                                  final page = pageList[i];
                                  final imageBytes = await page.toPng();

                                  await FlutterBluetoothPrinter.printImageSingle(
                                    address: controller.printerService.address ?? "",
                                    imageBytes: imageBytes,
                                    keepConnected: true,
                                    imageHeight: page.height,
                                    imageWidth: page.width,
                                    paperSize: PaperSize.mm58,
                                    addFeeds: 2,
                                  );

                                  debugPrint('Printed page ${i + 1}');
                                }

                                Navigator.pushNamed(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  AppRoutes.buktiTelusur,
                                  arguments: {"dataKendaraan": dataKendaraan, "kodePlat": kodePlat},
                                );
                              } catch (e) {
                                debugPrint('Failed to print PDF: $e');
                              }
                            }
                          : null,
                      child: Text(
                        "Cetak Info Pajak",
                        style: myTextTheme.titleMedium?.copyWith(
                          color: controller.printerService.isConnected ? blue900 : blueGray50,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Printer Status Widget with Real-time Updates
              ListenableBuilder(
                listenable: controller.printerService,
                builder: (context, child) {
                  final service = controller.printerService;
                  final hasDefault = service.hasDefaultPrinter;
                  final isConnected = service.isConnected;
                  final isConnecting = service.isAutoConnecting;

                  String title;
                  if (isConnected) {
                    title = "Terhubung ke printer";
                  } else if (isConnecting) {
                    title = "Menghubungkan ke printer...";
                  } else if (hasDefault) {
                    title = "Default printer (belum connect)";
                  } else {
                    title = "Tidak ada printer yang terhubung";
                  }

                  return _containerInfoPrinter(
                    isConnected,
                    icon: "assets/icons/info/info.svg",
                    title: title,
                    printerName: trimString(service.selectedDevice?.name),
                    hasDefault: hasDefault,
                    isConnecting: isConnecting,
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: neutralWhite,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(color: blueGray50, width: 1.0),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Informasi Objek Pajak", style: myTextTheme.titleMedium),
                    const SizedBox(height: 16.0),
                    StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: DetailTelusurMandiriOcrUtils.listInformasiObjekPajak(dataKendaraan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  CustomExpansionTile(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: const Border(
                      top: BorderSide(color: blueGray50, width: 1.0),
                      left: BorderSide(color: blueGray50, width: 1.0),
                      right: BorderSide(color: blueGray50, width: 1.0),
                    ),
                    title: "Informasi Besaran Pajak",
                    trailingIconOff: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Detail Biaya",
                          style: myTextTheme.titleSmall?.copyWith(color: blue900),
                        ),
                      ],
                    ),
                    trailingIconOn: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Tutup", style: myTextTheme.titleSmall?.copyWith(color: blue900)),
                      ],
                    ),
                    children: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            _headerBesaranPajak(),
                            const SizedBox(height: 8.0),
                            const Divider(),
                            const SizedBox(height: 8.0),
                            StaggeredGrid.count(
                              crossAxisCount: 1,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                              children: DetailTelusurMandiriOcrUtils.listBesaranPajak(
                                dataKendaraan?.dataHitungPajak,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(height: 1, width: double.infinity, color: blueGray50),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: neutralWhite,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(
                        left: BorderSide(color: blueGray50, width: 1.0),
                        right: BorderSide(color: blueGray50, width: 1.0),
                        bottom: BorderSide(color: blueGray50, width: 1.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text("TOTAL", style: myTextTheme.titleMedium)),
                        Text(":", style: myTextTheme.bodySmall),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rp", style: myTextTheme.titleMedium),
                              Text(
                                getNominalPkb(dataKendaraan?.dataHitungPajak).total,
                                style: myTextTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 130.0),
            ],
          ),
        ),
      ),
    );
  }

  // Validasi nomor WA sederhana (awalan 08 dan panjang minimal 10 digit)
  bool _isValidWa(String? wa) {
    if (wa == null) return false;
    final waClean = wa.replaceAll(RegExp(r'[^0-9]'), '');
    return waClean.startsWith('08') && waClean.length >= 10;
  }

  // Validasi email sederhana
  bool _isValidEmail(String? email) {
    if (email == null) return false;
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
    return emailRegex.hasMatch(email);
  }

  Widget _headerBesaranPajak() {
    return IntrinsicHeight(
      child: Row(
        children: [
          const Expanded(child: Text("")),
          const VerticalDivider(),
          Expanded(
            child: Text("Pokok", style: myTextTheme.labelLarge, textAlign: TextAlign.center),
          ),
          const VerticalDivider(),
          Expanded(
            child: Text("Denda", style: myTextTheme.labelLarge, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _containerInfoPrinter(
    bool isConnected, {
    String icon = "assets/icons/info/info.svg",
    String title = "Tidak ada printer yang terhubung",
    String printerName = "",
    bool hasDefault = false,
    bool isConnecting = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: blueGray50, width: 1.0),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Show loading indicator when connecting
          if (isConnecting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: blue600),
            )
          else
            // ignore: deprecated_member_use
            SvgPicture.asset(icon, color: isConnected ? blue800 : (hasDefault ? blue600 : red800)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: "$title ",
                    style: myTextTheme.bodyMedium,
                    children: <TextSpan>[
                      if (printerName.isNotEmpty)
                        TextSpan(text: printerName, style: myTextTheme.titleSmall),
                    ],
                  ),
                ),
                if (hasDefault && !isConnected && !isConnecting)
                  Text(
                    'Akan auto-connect saat printer ditemukan',
                    style: myTextTheme.bodySmall?.copyWith(color: blueGray400, fontSize: 11),
                  ),
                if (isConnecting)
                  Text(
                    'Sedang mencoba menghubungkan...',
                    style: myTextTheme.bodySmall?.copyWith(color: blue600, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<DetailTelusurMandiriOcrView> createState() => DetailTelusurMandiriOcrController();
}
