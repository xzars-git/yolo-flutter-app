import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_platform_interface/flutter_bluetooth_printer_platform_interface.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:printing/printing.dart';
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
  const DetailTelusurMandiriOcrView({super.key, this.dataKendaraan});

  Widget build(context, DetailTelusurMandiriOcrController controller) {
    controller.view = this;
    // Validasi format noWa dan email
    final isValidWa = _isValidWa(dataKendaraan?.noWa);
    final isValidEmail = _isValidEmail(dataKendaraan?.email);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Data"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final selected = await FlutterBluetoothPrinter.selectDevice(context);
              FlutterBluetoothPrinter.getState().then((state) {
                debugPrint('Printer State: $state');
              });

              controller.selectedDevice = selected;
              controller.address = selected?.address;
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
              child: TextButton(
                onPressed: () async {
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
                        address: controller.address ?? "",
                        imageBytes: imageBytes,
                        keepConnected: true,
                        imageHeight: page.height,
                        imageWidth: page.width,
                        paperSize: PaperSize.mm58,
                        addFeeds: 2,
                      );

                      debugPrint('Printed page ${i + 1}');
                    }
                  } catch (e) {
                    debugPrint('Failed to print PDF: $e');
                  }
                },
                child: Text(
                  "Cetak Info Pajak",
                  style: myTextTheme.titleMedium?.copyWith(color: blue900),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _containerInfoPrinter(
              (controller.selectedDevice?.name != null),
              icon: "assets/icons/info/info.svg",
              title: (controller.selectedDevice?.name != null)
                  ? "Terhubung ke printer"
                  : "Tidak ada printer yang terhubung",
              printerName: trimString(controller.selectedDevice?.name),
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
                      Text("Detail Biaya", style: myTextTheme.titleSmall?.copyWith(color: blue900)),
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
                  padding: const EdgeInsets.only(top: 10.0, bottom: 16.0, left: 16.0, right: 16.0),
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

            // StreamBuilder(
            //   stream: FlutterBluetoothPrinter.discovery,
            //   builder: (context, snapshot) {
            //     //TODO: handle snapshot states (loading, error, data)
            //     DiscoveryResult list = snapshot.data as DiscoveryResult;
            //     print("snapshot");
            //     List<BluetoothDevice> listDevices = list.devices;
            //     for (var i = 0; i < listDevices.length; i++) {
            //       print(
            //         'Discovered devices: ${listDevices[i].name} - ${listDevices[i].address} - ${listDevices[i].type}',
            //       );
            //     }

            //     return ListView(
            //       shrinkWrap: true,
            //       physics: const NeverScrollableScrollPhysics(),
            //       children: listDevices
            //           .map(
            //             (device) => InkWell(
            //               onTap: () async {
            //                 bool isConnect = await FlutterBluetoothPrinter.connect(device.address);
            //                 print('Connected: $isConnect to ${device.name}');
            //               },
            //               child: ListTile(
            //                 title: Text(device.name ?? "Unknown"),
            //                 subtitle: Text(device.address ?? "No Address"),
            //                 trailing: Text(device.type.toString().split('.').last),
            //               ),
            //             ),
            //           )
            //           .toList(),
            //     );
            //   },
            // ),
            const SizedBox(height: 130.0),
          ],
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
          // ignore: deprecated_member_use
          SvgPicture.asset(icon, color: isConnected ? blue800 : red800),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              text: "$title ",
              style: myTextTheme.bodyMedium,
              children: <TextSpan>[TextSpan(text: printerName, style: myTextTheme.titleSmall)],
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<DetailTelusurMandiriOcrView> createState() => DetailTelusurMandiriOcrController();
}
