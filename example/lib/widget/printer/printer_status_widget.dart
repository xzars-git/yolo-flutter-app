import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ultralytics_yolo_example/service/bluetooth_printer_service.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class PrinterStatusWidget extends StatelessWidget {
  final bool showDeviceList;
  final VoidCallback? onTapSelectPrinter;

  const PrinterStatusWidget({super.key, this.showDeviceList = false, this.onTapSelectPrinter});

  @override
  Widget build(BuildContext context) {
    final printerService = BluetoothPrinterService();

    return ListenableBuilder(
      listenable: printerService,
      builder: (context, child) {
        return Column(
          children: [
            // Printer Status Info
            Container(
              decoration: BoxDecoration(
                color: neutralWhite,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(color: blueGray50, width: 1.0),
              ),
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap:
                    onTapSelectPrinter ??
                    () async {
                      await printerService.selectDeviceWithDialog(context);
                    },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/info/info.svg",
                      // ignore: deprecated_member_use
                      color: printerService.isConnected ? blue800 : red800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: printerService.isConnected
                                  ? "Terhubung ke printer "
                                  : printerService.hasDefaultPrinter
                                  ? "Default printer: "
                                  : "Tidak ada printer yang terhubung ",
                              style: myTextTheme.bodyMedium,
                              children: <TextSpan>[
                                if (printerService.isConnected || printerService.hasDefaultPrinter)
                                  TextSpan(
                                    text: trimString(printerService.selectedDevice?.name),
                                    style: myTextTheme.titleSmall,
                                  ),
                              ],
                            ),
                          ),
                          if (printerService.hasDefaultPrinter && !printerService.isConnected)
                            Text(
                              'Akan auto-connect saat printer ditemukan',
                              style: myTextTheme.bodySmall?.copyWith(
                                color: blueGray400,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!printerService.isConnected && !printerService.hasDefaultPrinter)
                      const Icon(Icons.arrow_forward_ios, size: 16, color: blueGray400),
                    if (printerService.isConnected || printerService.hasDefaultPrinter)
                      IconButton(
                        icon: const Icon(Icons.close, color: red800, size: 20),
                        onPressed: () async {
                          await printerService.forgetDevice();
                        },
                        tooltip: 'Hapus default printer',
                      ),
                  ],
                ),
              ),
            ),

            // Device List (if enabled)
            if (showDeviceList && printerService.discoveredDevices.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: neutralWhite,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(color: blueGray50, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Printer Tersedia", style: myTextTheme.titleMedium),
                    ),
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: printerService.discoveredDevices.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final device = printerService.discoveredDevices[index];
                        final isSelected = printerService.selectedDevice?.address == device.address;

                        return InkWell(
                          onTap: () async {
                            await printerService.connectToDevice(device.address);
                          },
                          child: Container(
                            color: isSelected ? blue50 : null,
                            child: ListTile(
                              leading: Icon(Icons.print, color: isSelected ? blue900 : blueGray400),
                              title: Text(
                                device.name ?? "Unknown",
                                style: myTextTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? blue900 : null,
                                ),
                              ),
                              subtitle: Text(device.address, style: myTextTheme.bodySmall),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: blue900)
                                  : Text(
                                      device.type.toString().split('.').last,
                                      style: myTextTheme.bodySmall,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
