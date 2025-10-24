import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo_example/app/routes.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/view/input_nomor_polisi_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/service/api_service.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/check_connection/check_connection.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';
import 'package:ultralytics_yolo_example/util/request_permmision.dart';

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

  void onReady() async {
    // ✅ CEK permission dulu sebelum request
    try {
      debugPrint('🔐 Checking permissions...');
      setState(() {
        isRequestingPermissions = true;
        ocrStatusMessage = '🔐 Mengecek izin akses...';
      });
      
      // CEK status permission saat ini
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.location.status;
      
      debugPrint('📊 Permission status: camera=$cameraStatus, location=$locationStatus');
      
      // Hanya request jika BELUM granted
      if (!cameraStatus.isGranted || !locationStatus.isGranted) {
        debugPrint('⚠️ Some permissions not granted, requesting...');
        await requestPermissions();
      } else {
        debugPrint('✅ All permissions already granted, skip request');
      }
      
      // ✅ CRITICAL: Set flag dan force rebuild untuk initialize camera
      setState(() {
        isPermissionsGranted = true;
        isRequestingPermissions = false;
        ocrStatusMessage = 'Terhubung ke printer COMSON 77';
      });
      
      // ✅ Delay kecil untuk ensure camera widget rebuild
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted && !isInputNopol) {
        debugPrint('🎥 Camera initialized');
      }
    } catch (e) {
      debugPrint('⚠️ Permission error: $e');
      setState(() {
        isPermissionsGranted = false;
        isRequestingPermissions = false;
        ocrStatusMessage = '❌ Izin akses ditolak';
      });
    }
  }

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
  
  // ✅ Flag untuk track permission status
  bool isPermissionsGranted = false;
  bool isRequestingPermissions = true;
  
  DateTime lastCallbackTime = DateTime.now();
  static const callbackDebounceMs = 300;

  
  /// Update UI
  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Resume detection setelah OCR selesai
  void resumeDetection() {
    setState(() {
      isDetectionActive = true;
      isProcessing = false;
      ocrStatusMessage = 'Terhubung ke printer COMSON 77';
    });
  }

  /// Stop detection permanently
  void stopDetection() {
    setState(() {
      isDetectionActive = false;
      isProcessing = false;
      ocrStatusMessage = '⏹️ Detection stopped - Input manual atau beralih ke scan';
    });
  }

  /// Start detection manually
  void startDetection() {
    setState(() {
      isDetectionActive = true;
      isProcessing = false;
      ocrStatusMessage = 'Terhubung ke printer COMSON 77';
    });
  }

  /// ✅ Helper: Normalisasi karakter menjadi HURUF (untuk nopol1 & nopol3)
  /// Konversi angka yang mirip huruf:
  /// - 0 → O, 1 → I, 4 → A, 5 → S, 8 → B, 3 → E
  String _normalizeToLetters(String text) {
    return text
        .replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('4', 'A')
        .replaceAll('5', 'S')
        .replaceAll('8', 'B')
        .replaceAll('3', 'E')
        .toUpperCase();
  }

  /// ✅ Helper: Normalisasi karakter menjadi ANGKA (untuk nopol2)
  /// Konversi huruf yang mirip angka:
  /// - O → 0, I → 1, A → 4, S → 5, B → 8, E → 3
  String _normalizeToDigits(String text) {
    return text
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('A', '4')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('E', '3')
        .toUpperCase();
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
            debugPrint('📄 OCR Raw Result: "$ocrText"');
            
            // ✅ TIDAK LAGI VALIDASI REGEX DI SINI - Biarkan OCR berhasil
            // Validasi akan dilakukan saat parsing untuk hit API
            
            final formatted = ocrService.formatLicensePlate(ocrText);
            plateData.ocrText = formatted.isNotEmpty ? formatted : ocrText; // Use original if format fails
            plateData.ocrError = null;
            totalOCRSuccess++;
            
            ocrStatusMessage = '� OCR: "$ocrText" - Checking pajak...';
            debugPrint('✅ OCR Success: "$ocrText" (formatted: "${plateData.ocrText}")');
          } else {
            plateData.ocrError = 'Tidak ada text terdeteksi';
            ocrStatusMessage = '⚠️ OCR tidak menemukan text';
            debugPrint('⚠️ OCR returned empty text');
          }
        });
        
        // ✅ Hit API langsung jika OCR berhasil ekstrak text (apapun textnya)
        if (plateData.ocrText != null && plateData.ocrText!.isNotEmpty) {
          // TETAP PAUSE DETECTION - akan di-resume setelah user konfirmasi dari dialog API result
          checkPajakInfo(plateData.ocrText!);
        } else {
          // OCR gagal ekstrak text, resume detection untuk coba lagi
          ocrStatusMessage = '❌ OCR gagal ekstrak text - Mencoba lagi...';
          resumeDetection();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          plateData.ocrError = 'OCR Error: $e';
          ocrStatusMessage = '❌ OCR Error - Mencoba lagi...';
        });
        
        // OCR error, langsung resume detection tanpa dialog
        resumeDetection();
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

  /// Show dialog untuk kendaraan TAAT PAJAK
  void _showPajakTaatDialogWithData(String platNomor, DataBesaranPajakResult pajakInfo) {
    final data = pajakInfo.data;
    final String namaPemilik = data?.nmPemilik ?? '-';
    final String merkKB = data?.nmMerekKb ?? '-';
    final String modelKB = data?.nmModelKb ?? '-';
    final String warnaKB = data?.warnaKb ?? '-';
    final String tglAkhirPajak = data?.tgAkhirPajak ?? '-';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Taat Pajak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
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
                  color: AppTheme.green50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.green600, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: AppTheme.green700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kendaraan ini TAAT PAJAK ✅',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.green900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24, color: AppTheme.gray300),
              const Text(
                '📋 Informasi Kendaraan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
              ),
              const SizedBox(height: 12),
              buildInfoRowPajakInformation('Pemilik', namaPemilik),
              buildInfoRowPajakInformation('Merk', merkKB),
              buildInfoRowPajakInformation('Model', modelKB),
              buildInfoRowPajakInformation('Warna', warnaKB),
              const SizedBox(height: 8),
              
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.green50, AppTheme.green100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.green600, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status Pajak',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AKTIF',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.green900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berlaku s/d $tglAkhirPajak',
                          style: const TextStyle(fontSize: 11, color: AppTheme.gray600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
            label: const Text('Deteksi Lagi', style: TextStyle(color: AppTheme.blue600)),
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
      ocrStatusMessage = '🚀 OCR: "$platNomor" - Checking API...';
    });

    try {
      await checkConnection();
      
      // Parse plat nomor dari format "AB 1234 CD" ke noPolisi1, noPolisi2, noPolisi3
      final parts = platNomor.trim().split(RegExp(r'\s+'));
      
      debugPrint('📊 Parsing plate number: "$platNomor"');
      debugPrint('   Parts: ${parts.join(", ")} (total: ${parts.length})');
      
      // ✅ VALIDASI SEDERHANA: Cek ada 3 part saja
      if (parts.length != 3) {
        debugPrint('⚠️ Invalid plate format: need exactly 3 parts, got ${parts.length}');
        setState(() {
          isCheckingAPI = false;
          ocrStatusMessage = '⚠️ Format tidak lengkap - Mencoba lagi...';
        });
        
        // Format tidak valid, langsung resume detection tanpa dialog
        resumeDetection();
        return;
      }
      
      // ✅ NORMALISASI HANYA 1 KALI - Di sini sebelum hit API
      // nopol1 & nopol3: Angka yang mirip huruf → Huruf (0→O, 1→I, 4→A, 5→S, 8→B)
      // nopol2: Huruf yang mirip angka → Angka (O→0, I→1, A→4, S→5, B→8)
      String nopol1Raw = parts[0].toUpperCase();
      String nopol2Raw = parts[1].toUpperCase();
      String nopol3Raw = parts[2].toUpperCase();
      
      noPolisi1 = _normalizeToLetters(nopol1Raw);
      noPolisi2 = _normalizeToDigits(nopol2Raw);
      noPolisi3 = _normalizeToLetters(nopol3Raw);
      
      debugPrint('🔄 Normalization:');
      debugPrint('   nopol1: "$nopol1Raw" → "$noPolisi1"');
      debugPrint('   nopol2: "$nopol2Raw" → "$noPolisi2"');
      debugPrint('   nopol3: "$nopol3Raw" → "$noPolisi3"');
      
      final normalizedPlate = '$noPolisi1 $noPolisi2 $noPolisi3';
      debugPrint('✅ Final normalized plate: "$normalizedPlate"');
      
      setState(() {
        ocrStatusMessage = '🚀 Checking: "$normalizedPlate"';
      });

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
        ocrStatusMessage = '✅ Data ditemukan!';
        
        // Check tgl akhir pajak
        DateTime now = await NTP.now();
        DateTime tgAkhirPajakDate = DateTime.parse(result.data?.tgAkhirPajak ?? "");

        if (tgAkhirPajakDate.isBefore(now)) {
          // Pajak sudah lewat - navigate ke detail
          debugPrint('❌ Pajak EXPIRED - Navigate to detail');
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.detailNopol,
              arguments: {"dataKendaraan": result.data, "kodePlat": kodePlat},
            );
          }
        } else {
          // Pajak masih aktif (taat pajak) - show dialog
          debugPrint('✅ Pajak ACTIVE - Show taat pajak dialog');
          if (mounted) {
            _showPajakTaatDialogWithData(platNomor, result);
          }
        }
      } else {
        // Data tidak ditemukan
        debugPrint('⚠️ Data not found: ${result.message}');
        setState(() {
          ocrStatusMessage = '❌ Data tidak ditemukan';
        });
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
