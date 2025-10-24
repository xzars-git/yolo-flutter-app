import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo_example/app/routes.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/view/input_nomor_polisi_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/service/api_service.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/check_connection/check_connection.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';

import '../../../app/theme.dart';
import '../../../service/ocr_service.dart';
import '../../../util/string_util/string_util.dart';
import '../models/plate_data.dart';

class InputNomorPolisiOcrController extends State<InputNomorPolisiOcrView> {
  static late InputNomorPolisiOcrController instance;
  late InputNomorPolisiOcrView view;

  @override
  void initState() {
    ocrService = OCRService();
    ocrStatusMessage = 'Siap untuk deteksi & OCR plat nomor!';
    super.initState();
    instance = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  void onReady() {}

  @override
  void dispose() {
    ocrService.dispose();
    super.dispose();
  }

  bool isInputNopol = false;

  DataKendaraan? dataKendaraan;

  Color warnaPlat = gray900;
  Color warnaBorder = gray100;
  Color warnaFont = gray100;
  Color warnaPlaceholder = gray100;

  FocusNode nopol1FocusNode = FocusNode();
  FocusNode nopol2FocusNode = FocusNode();
  FocusNode nopol3FocusNode = FocusNode();

  String noPolisi1 = '';
  String noPolisi2 = '';
  String noPolisi3 = '';
  String kodePlat = '1';

  String kdBayarParkir = '';
  String idUser = '';
  String tgProsesTetap = '';
  String tgAkhirPajak = '';

  UpdateNopol dataNopol = const UpdateNopol();

  String pathPhoto = '';

  bool isLoading = false;

  getDataBesaranPajak() async {
    DataBesaranPajakResult? result;

    try {
      isLoading = true;
      update();
      await checkConnection();
      try {
        result = await ApiService.getBesaranPajak(
          noPolisi1: noPolisi1,
          noPolisi2: noPolisi2,
          noPolisi3: noPolisi3,
          kdPlat: kodePlat,
          bayarKeDepan: "T",
        ).timeout(const Duration(seconds: 90));
        dataKendaraan = result.data;
        pathPhoto = "";

        isLoading = false;
        update();

        DateTime now = await NTP.now();
        DateTime tgAkhirPajak = DateTime.parse(result.data?.tgAkhirPajak ?? "");

        if (tgAkhirPajak.isBefore(now)) {
          // Get.to(DetailTelusurMandiriOcrView(dataKendaraan: result.data));
          Navigator.pushNamed(
            // ignore: use_build_context_synchronously
            context,
            AppRoutes.detailNopol,
            arguments: {"dataKendaraan": result.data, "kodePlat": kodePlat},
          );
        } else {
          await showInfoDialog("Nomor polisi yang Anda masukkan Taat pajak.");
        }
      } catch (e) {
        isLoading = false;
        update();
        await ApiService.sendLog(
          logString: e.toString(),
          isAvailableNoPol: true,
          noPolisi1: noPolisi1.toUpperCase(),
          noPolisi2: noPolisi2,
          noPolisi3: noPolisi3.toUpperCase(),
          processName: "Get List History Verifikasi - Riwayat Verifikasi",
        ).timeout(const Duration(seconds: 30));
        if (e.toString().contains("TimeoutException")) {
          await showInfoDialog(
            "Mohon maaf, koneksi ke server gagal tersambung setelah 90 detik. Periksa kembali koneksi Anda.",
          );
        } else {
          await showInfoDialog("Terjadi Kesalahan, ${e.toString()}");
        }
      }
    } on DioException {
      isLoading = false;
      update();
      showInfoDialog(
        "Mohon maaf, koneksi ke server gagal tersambung setelah 90 detik. Periksa kembali koneksi Anda.",
      );
    }
  }

  //OCR Section Variables
  List<PlateData> croppedPlates = [];
  int totalDetected = 0;
  int totalCropped = 0;
  int totalOCRSuccess = 0;
  String ocrStatusMessage = 'Memuat model plat nomor...';
  late final OCRService ocrService;
  bool isOCREnabled = true;
  bool isCheckingAPI = false;
  
  bool isDetectionActive = true;
  bool isProcessing = false;
  
  DateTime lastCallbackTime = DateTime.now();
  static const callbackDebounceMs = 300;

  
  /// Resume detection setelah OCR selesai
  void resumeDetection() {
    setState(() {
      isDetectionActive = true;
      isProcessing = false;
      ocrStatusMessage = '🔍 Detection resumed - Arahkan kamera ke plat nomor...';
    });
  }

  /// Stop detection permanently
  void stopDetection() {
    setState(() {
      isDetectionActive = false;
      isProcessing = false;
      ocrStatusMessage = '⏹️ Detection stopped - Tekan tombol untuk mulai lagi';
    });
  }

  /// Start detection manually
  void startDetection() {
    setState(() {
      isDetectionActive = true;
      isProcessing = false;
      ocrStatusMessage = '🔍 Detection started - Arahkan kamera ke plat nomor...';
    });
  }

  Future<void> processOCR(PlateData plateData, int index) async {
    if (!isOCREnabled || !ocrService.isReady) {
      plateData.ocrError = 'OCR service not ready';
      showOCRResultDialog(plateData);
      return;
    }

    setState(() {
      isProcessing = true;
      plateData.isProcessingOCR = true;
      ocrStatusMessage = '⏳ Processing OCR... (Detection paused)';
    });

    // Save debug crop
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/debug_crop_$timestamp.jpg');
      await tempFile.writeAsBytes(plateData.croppedImage.imageBytes!);
      debugPrint('💾 Saved debug crop: ${tempFile.path}');
    } catch (e) {
      debugPrint('⚠️ Failed to save debug crop: $e');
    }

    try {
      final ocrText = await ocrService.extractLicensePlateText(
        plateData.croppedImage.imageBytes!,
      );

      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          
          if (ocrText != null && ocrText.isNotEmpty) {
            final formatted = ocrService.formatLicensePlate(ocrText);
            plateData.ocrText = formatted;
            plateData.ocrError = null;
            totalOCRSuccess++;
            
            ocrStatusMessage = '🚀 Checking pajak info via API...';
          } else {
            plateData.ocrError = 'Tidak ada text terdeteksi';
            ocrStatusMessage = '⚠️ OCR tidak menemukan text';
          }
        });
        
        // Hit API jika OCR berhasil
        if (plateData.ocrText != null && plateData.ocrText!.isNotEmpty) {
          checkPajakInfo(plateData.ocrText!);
        } else {
          showOCRResultDialog(plateData);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          plateData.ocrError = 'OCR Error: $e';
          ocrStatusMessage = '❌ OCR Error';
        });
        
        showOCRResultDialog(plateData);
      }
    }
  }

  void showOCRResultDialog(PlateData plateData) {
    final bool hasError = plateData.ocrText == null || plateData.ocrText!.isEmpty;
    final String displayText = plateData.ocrText ?? 'Error: Tidak ada teks terdeteksi';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasError ? Icons.error : Icons.check_circle, 
              color: hasError ? Colors.red.shade600 : Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(hasError ? 'OCR Error!' : 'OCR Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (plateData.croppedImage.hasImageData)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    plateData.croppedImage.imageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? Colors.red.shade300 : Colors.green.shade300, 
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    hasError ? 'Error OCR:' : 'Hasil OCR Plat Nomor:',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: hasError ? 14 : 24,
                      fontWeight: FontWeight.bold,
                      color: hasError ? Colors.red.shade900 : Colors.green.shade900,
                      letterSpacing: hasError ? 0 : 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            if (!hasError) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.help_outline, color: Colors.blue.shade700, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Apakah hasil OCR sudah benar?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: hasError
            ? [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    resumeDetection();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: const Text('Coba Lagi', style: TextStyle(color: Colors.orange)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    stopDetection();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ]
            : [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    resumeDetection();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: const Text('Tidak Benar\nDetect Lagi', style: TextStyle(color: Colors.orange), textAlign: TextAlign.center),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    stopDetection();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data tersimpan: ${plateData.ocrText}'),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Sudah Benar\nSimpan Data', textAlign: TextAlign.center),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
      ),
    );
  }

  /// Show dialog dengan info pajak
  void showPajakResultDialog(String platNomor, DataBesaranPajakResult pajakInfo, {required bool isSuccess}) {
    final data = pajakInfo.data;
    final String namaPemilik = data?.nmPemilik ?? '-';
    final String alamat = data?.alPemilik ?? '-';
    final String merkKB = data?.nmMerekKb ?? '-';
    final String modelKB = data?.nmModelKb ?? '-';
    final String tglAkhirPajak = data?.tgAkhirPajak ?? '-';
    
    final dataHitung = data?.dataHitungPajak;
    final int pajakPokok = int.parse( dataHitung?.beaPkbPok0 ?? "0");
    final int swdkllj = int.parse( dataHitung?.beaSwdklljPok0 ?? "0");
    final int totalPajak = pajakPokok + swdkllj;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSuccess ? 'Data Ditemukan!' : 'Data Tidak Ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.blue50, AppTheme.blue100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.blue600, width: 2),
                ),
                child: Center(
                  child: Text(
                    platNomor,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppTheme.blue900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? AppTheme.green50 : AppTheme.red50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSuccess ? AppTheme.green600 : AppTheme.red600,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.info_outline : Icons.warning_amber_outlined,
                      color: isSuccess ? AppTheme.green700 : AppTheme.red700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pajakInfo.message ?? "-",
                        style: TextStyle(
                          fontSize: 13,
                          color: isSuccess ? AppTheme.green900 : AppTheme.red900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isSuccess && data != null) ...[
                const Divider(height: 24, color: AppTheme.gray300),
                const Text(
                  '📋 Informasi Kendaraan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
                const SizedBox(height: 12),
                buildInfoRowPajakInformation('Pemilik', namaPemilik),
                buildInfoRowPajakInformation('Alamat', alamat, maxLines: 2),
                const SizedBox(height: 8),
                buildInfoRowPajakInformation('Merk', merkKB),
                buildInfoRowPajakInformation('Model', modelKB),
                const SizedBox(height: 8),
                buildInfoRowPajakInformation('Jatuh Tempo Pajak', tglAkhirPajak),

                const Divider(height: 24, color: AppTheme.gray300),
                const Text(
                  '💰 Informasi Pajak',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
                const SizedBox(height: 12),
                buildInfoRowPajakInformation('PKB Pokok', 'Rp ${formatCurrency(pajakPokok)}'),
                buildInfoRowPajakInformation('SWDKLLJ', 'Rp ${formatCurrency(swdkllj)}'),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.yellow50, AppTheme.yellow100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.yellow600, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                      ),
                      Text(
                        'Rp ${formatCurrency(totalPajak)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.yellow900),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              resumeDetection();
            },
            icon: const Icon(Icons.refresh, color: AppTheme.blue600),
            label: const Text('Diteksi Ulang', style: TextStyle(color: AppTheme.blue600)),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRowPajakInformation(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.gray600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Hit API untuk cek info pajak
  void checkPajakInfo(String platNomor) async {
    setState(() {
      isCheckingAPI = true;
      ocrStatusMessage = '🚀 Checking pajak info via API...';
    });

    try {
      await checkConnection();
      
      // Parse plat nomor dari format "AB 1234 CD" ke noPolisi1, noPolisi2, noPolisi3
      final parts = platNomor.split(' ');
      if (parts.length >= 3) {
        noPolisi1 = parts[0]; // AB
        noPolisi2 = parts[1]; // 1234
        noPolisi3 = parts[2]; // CD
      }

      final result = await ApiService.getBesaranPajak(
        noPolisi1: noPolisi1,
        noPolisi2: noPolisi2,
        noPolisi3: noPolisi3,
        kdPlat: kodePlat,
        bayarKeDepan: "T",
      ).timeout(const Duration(seconds: 90));

      setState(() {
        isCheckingAPI = false;
        dataKendaraan = result.data;
      });

      if (result.success == true && result.data != null) {
        DateTime now = await NTP.now();
        DateTime tgAkhirPajakDate = DateTime.parse(result.data?.tgAkhirPajak ?? "");

        if (mounted) {
          showPajakResultDialog(platNomor, result, isSuccess: true);
        }
      } else {
        if (mounted) {
          showPajakResultDialog(platNomor, result, isSuccess: false);
        }
      }

    } on DioException catch (e) {
      setState(() {
        isCheckingAPI = false;
        ocrStatusMessage = '❌ API Error: Connection timeout';
      });

      await ApiService.sendLog(
        logString: e.toString(),
        isAvailableNoPol: true,
        noPolisi1: noPolisi1.toUpperCase(),
        noPolisi2: noPolisi2,
        noPolisi3: noPolisi3.toUpperCase(),
        processName: "OCR Check Pajak - Input Nomor Polisi OCR",
      ).timeout(const Duration(seconds: 30));

      if (mounted) {
        final errorResult = DataBesaranPajakResult(
          success: false,
          message: "Koneksi ke server gagal tersambung setelah 90 detik. Periksa kembali koneksi Anda.",
        );
        showPajakResultDialog(platNomor, errorResult, isSuccess: false);
      }

    } catch (e) {
      setState(() {
        isCheckingAPI = false;
        ocrStatusMessage = '❌ API Error';
      });

      await ApiService.sendLog(
        logString: e.toString(),
        isAvailableNoPol: true,
        noPolisi1: noPolisi1.toUpperCase(),
        noPolisi2: noPolisi2,
        noPolisi3: noPolisi3.toUpperCase(),
        processName: "OCR Check Pajak - Input Nomor Polisi OCR",
      ).timeout(const Duration(seconds: 30));

      if (mounted) {
        final errorResult = DataBesaranPajakResult(
          success: false,
          message: "Terjadi Kesalahan: ${e.toString()}",
        );
        showPajakResultDialog(platNomor, errorResult, isSuccess: false);
      }
    }
  }


  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
