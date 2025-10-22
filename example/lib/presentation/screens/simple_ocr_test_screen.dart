// Simple OCR Test Screen - NO PAUSE LOGIC
// Untuk test apakah OCR bisa jalan atau tidak

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../../services/ocr_service.dart';
import '../../services/pajak_service.dart';

class SimpleOCRTestScreen extends StatefulWidget {
  const SimpleOCRTestScreen({super.key});

  @override
  State<SimpleOCRTestScreen> createState() => _SimpleOCRTestScreenState();
}

class _SimpleOCRTestScreenState extends State<SimpleOCRTestScreen> {
  final List<String> _ocrResults = [];
  int _totalCropped = 0;
  int _totalOCRSuccess = 0;
  int _totalOCRFailed = 0;
  late final OCRService _ocrService;
  late final PajakService _pajakService;
  bool _isCheckingAPI = false;
  
  // ✅ PAUSE LOGIC: Stop detection after success
  bool _isDetectionActive = true;
  bool _isProcessing = false;
  String? _lastProcessedPlate;  // Track last successful plate for debugging

  @override
  void initState() {
    super.initState();
    _ocrService = OCRService();
    _pajakService = PajakService();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// Hit API untuk cek info pajak berdasarkan nomor polisi
  void _checkPajakInfo(String platNomor) async {
    setState(() => _isCheckingAPI = true);

    try {
      debugPrint('');
      debugPrint('🚀 ========================================');
      debugPrint('🚀 CHECKING PAJAK INFO');
      debugPrint('🚀 Plat Nomor: $platNomor');
      debugPrint('🚀 ========================================');
      
      // Parse nomor polisi
      final nomorPolisi = NomorPolisi.fromString(platNomor);
      debugPrint('   📋 Split:');
      debugPrint('      nomorPolisi1 = ${nomorPolisi.nomorPolisi1}');
      debugPrint('      nomorPolisi2 = ${nomorPolisi.nomorPolisi2}');
      debugPrint('      nomorPolisi3 = ${nomorPolisi.nomorPolisi3}');
      debugPrint('      kdPlat = ${nomorPolisi.kdPlat}');

      // Hit API
      final pajakInfo = await _pajakService.getInfoPajak(platNomor: platNomor);

      setState(() => _isCheckingAPI = false);

      if (pajakInfo.success) {
        debugPrint('✅ API SUCCESS!');
        debugPrint('   Message: ${pajakInfo.message}');
        debugPrint('   Data: ${pajakInfo.data?.nmPemilik} - ${pajakInfo.data?.noPolisi1} ${pajakInfo.data?.noPolisi2} ${pajakInfo.data?.noPolisi3}');
        
        // 🔍 DEBUG: Print all data fields (excluding data_hitung_pajak)
        final data = pajakInfo.data;
        if (data != null) {
          debugPrint('📋 DATA FIELDS:');
          debugPrint('   ableBayarEsamsat: ${data.ableBayarEsamsat}');
          debugPrint('   ableBayarPajak: ${data.ableBayarPajak}');
          debugPrint('   alPemilik: ${data.alPemilik}');
          debugPrint('   bobot: ${data.bobot}');
          debugPrint('   email: ${data.email}');
          debugPrint('   jenisIdentitas: ${data.jenisIdentitas}');
          debugPrint('   kdBlockir: ${data.kdBlockir}');
          debugPrint('   kdFungsiKb: ${data.kdFungsiKb}');
          debugPrint('   kdMerekKb: ${data.kdMerekKb}');
          debugPrint('   kdProteksi: ${data.kdProteksi}');
          debugPrint('   kdWil: ${data.kdWil}');
          debugPrint('   milikKe: ${data.milikKe}');
          debugPrint('   nilaiJual: ${data.nilaiJual}');
          debugPrint('   nmFungsiKb: ${data.nmFungsiKb}');
          debugPrint('   nmJenisKb: ${data.nmJenisKb}');
          debugPrint('   nmMerekKb: ${data.nmMerekKb}');
          debugPrint('   nmModelKb: ${data.nmModelKb}');
          debugPrint('   nmPemilik: ${data.nmPemilik}');
          debugPrint('   nmWil: ${data.nmWil}');
          debugPrint('   noHp: ${data.noHp}');
          debugPrint('   noIdentitas: ${data.noIdentitas}');
          debugPrint('   noMesin: ${data.noMesin}');
          debugPrint('   noPolisi1: ${data.noPolisi1}');
          debugPrint('   noPolisi2: ${data.noPolisi2}');
          debugPrint('   noPolisi3: ${data.noPolisi3}');
          debugPrint('   noRangka: ${data.noRangka}');
          debugPrint('   noWa: ${data.noWa}');
          debugPrint('   tgAkhirPajak: ${data.tgAkhirPajak}');
          debugPrint('   tgAkhirStnk: ${data.tgAkhirStnk}');
          debugPrint('   tgKepemilikan: ${data.tgKepemilikan}');
          debugPrint('   tgProsesTetap: ${data.tgProsesTetap}');
          debugPrint('   thBuatan: ${data.thBuatan}');
          debugPrint('   warnaKb: ${data.warnaKb}');
          debugPrint('   dataHitungPajak: ${data.dataHitungPajak != null ? "EXISTS" : "NULL"}');
        }
        
        // Show dialog dengan info pajak LENGKAP
        if (mounted) {
          _showPajakResultDialog(platNomor, pajakInfo, isSuccess: true);
        }
      } else {
        debugPrint('❌ API FAILED: ${pajakInfo.message}');
        
        // Show dialog error tapi tetap kasih pilihan retry
        if (mounted) {
          _showPajakResultDialog(platNomor, pajakInfo, isSuccess: false);
        }
      }

    } catch (e) {
      debugPrint('❌ Exception during API call: $e');
      setState(() => _isCheckingAPI = false);
      
      if (mounted) {
        final errorInfo = PajakInfo.error('Exception: $e');
        _showPajakResultDialog(platNomor, errorInfo, isSuccess: false);
      }
    }
  }

  /// Show dialog dengan info pajak dan konfirmasi user
  void _showPajakResultDialog(String platNomor, PajakInfo pajakInfo, {required bool isSuccess}) {
    // Extract data jika berhasil menggunakan property access (bukan Map indexing)
    final data = pajakInfo.data;
    final String namaPemilik = data?.nmPemilik ?? '-';
    final String alamat = data?.alPemilik ?? '-';
    final String merkKB = data?.nmMerekKb ?? '-';
    final String modelKB = data?.nmModelKb ?? '-';
    final String warnaKB = data?.warnaKb ?? '-';
    final String noRangka = data?.noRangka ?? '-';
    final String noMesin = data?.noMesin ?? '-';
    final String tglAkhirPajak = data?.tgAkhirPajak ?? '-';
    final String tglAkhirSTNK = data?.tgAkhirStnk ?? '-';
    
    // Hitung pajak pokok menggunakan property access
    final dataHitung = data?.dataHitungPajak;
    final int pajakPokok = dataHitung?.beaPkbPok0 ?? 0;
    final int swdkllj = dataHitung?.beaSwdklljPok0 ?? 0;
    final int totalPajak = pajakPokok + swdkllj;

    showDialog(
      context: context,
      barrierDismissible: false,  // User HARUS pilih salah satu button
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSuccess ? 'Data Ditemukan!' : 'Data Tidak Ditemukan',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
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
              // Plat Nomor (SELALU TAMPIL)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Center(
                  child: Text(
                    platNomor,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Message dari API
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.info : Icons.warning,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pajakInfo.message,
                        style: TextStyle(
                          color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Data kendaraan (HANYA jika success)
              if (isSuccess && data != null) ...[
                const Divider(height: 24),
                const Text(
                  '📋 Informasi Kendaraan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Pemilik', namaPemilik),
                _buildInfoRow('Alamat', alamat, maxLines: 2),
                const SizedBox(height: 8),
                _buildInfoRow('Merk', merkKB),
                _buildInfoRow('Model', modelKB),
                _buildInfoRow('Warna', warnaKB),
                const SizedBox(height: 8),
                _buildInfoRow('No. Rangka', noRangka),
                _buildInfoRow('No. Mesin', noMesin),
                const SizedBox(height: 8),
                _buildInfoRow('Jatuh Tempo Pajak', tglAkhirPajak),
                _buildInfoRow('Jatuh Tempo STNK', tglAkhirSTNK),

                const Divider(height: 24),
                const Text(
                  '💰 Informasi Pajak',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('PKB Pokok', 'Rp ${_formatCurrency(pajakPokok)}'),
                _buildInfoRow('SWDKLLJ', 'Rp ${_formatCurrency(swdkllj)}'),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(totalPajak)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          // Button: Detect Ulang
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Resume detection
              setState(() {
                _isDetectionActive = true;
                _isProcessing = false;
                _lastProcessedPlate = null;
              });
              debugPrint('▶️ Detection RESUMED by user');
            },
            icon: const Icon(Icons.refresh, color: Colors.blue),
            label: const Text('🔄 Detect Ulang'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
          
          // Button: Simpan Data (jika success)
          if (isSuccess)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement save data logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Data berhasil disimpan!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reset detection
                setState(() {
                  _isDetectionActive = true;
                  _isProcessing = false;
                  _lastProcessedPlate = null;
                });
              },
              icon: const Icon(Icons.save),
              label: const Text('💾 Simpan Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Simple OCR Test'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Cropped', _totalCropped, Colors.blue),
                _buildStat('OCR ✅', _totalOCRSuccess, Colors.green),
                _buildStat('OCR ❌', _totalOCRFailed, Colors.red),
              ],
            ),
          ),

          // API Loading Indicator
          if (_isCheckingAPI)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '🚀 Checking pajak info via API...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Camera
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: YOLOView(
                  modelPath: 'plat_recognation.tflite',
                  task: YOLOTask.detect,
                  confidenceThreshold: 0.3,
                  streamingConfig: YOLOStreamingConfig(
                    enableCropping: true,  // Always ON
                    croppingPadding: 0.1,
                    croppingQuality: 90,
                    inferenceFrequency: 15,
                    includeDetections: true,
                    includeOriginalImage: true,
                  ),
                  onCroppedImages: (List<YOLOCroppedImage> images) async {
                    if (images.isEmpty) return;

                    // ✅ PAUSE LOGIC: Skip if detection inactive or already processing
                    if (!_isDetectionActive || _isProcessing) {
                      debugPrint('⏸️ Detection paused or processing, skipping...');
                      return;
                    }

                    debugPrint('📸 GOT ${images.length} CROPPED IMAGES!');

                    for (var img in images) {
                      _totalCropped++;

                      debugPrint('🔍 Testing OCR on plate #$_totalCropped...');
                      debugPrint('   Image bytes: ${img.imageBytes?.length ?? 0}');

                      if (img.imageBytes == null || img.imageBytes!.isEmpty) {
                        debugPrint('❌ No image bytes!');
                        continue;
                      }

                      try {
                        final ocrText = await _ocrService.extractLicensePlateText(img.imageBytes!);
                        
                        if (ocrText != null && ocrText.isNotEmpty) {
                          // ✅ VALIDASI: Harus sesuai format Indonesia (Huruf-Angka-Huruf)
                          final isValid = _ocrService.isValidIndonesianPlate(ocrText);
                          
                          if (isValid) {
                            // Format ke standard Indonesia
                            final formatted = _ocrService.formatLicensePlate(ocrText);
                            debugPrint('✅ OCR SUCCESS (VALID): "$formatted"');
                            
                            // ✅ PAUSE DETECTION
                            setState(() {
                              _isProcessing = true;
                              _isDetectionActive = false;
                              _lastProcessedPlate = formatted;
                              _totalOCRSuccess++;
                              _ocrResults.insert(0, '✅ $formatted');
                              if (_ocrResults.length > 20) _ocrResults.removeLast();
                            });

                            debugPrint('⏸️ Detection PAUSED - waiting for user confirmation');

                            // 🚀 HIT API untuk cek info pajak
                            _checkPajakInfo(formatted);
                            
                            // Break loop - only process first valid plate
                            break;
                            
                          } else {
                            // Invalid format - bukan plat nomor Indonesia
                            debugPrint('⚠️ OCR returned invalid format: "$ocrText" (must be: HURUF-ANGKA-HURUF)');
                            setState(() {
                              _totalOCRFailed++;
                              _ocrResults.insert(0, '❌ Invalid: $ocrText (bukan format Indonesia)');
                              if (_ocrResults.length > 20) _ocrResults.removeLast();
                            });
                          }
                        } else {
                          debugPrint('⚠️ OCR returned empty');
                          setState(() {
                            _totalOCRFailed++;
                            _ocrResults.insert(0, '⚠️ No text detected');
                            if (_ocrResults.length > 20) _ocrResults.removeLast();
                          });
                        }
                      } catch (e, stackTrace) {
                        debugPrint('❌ OCR EXCEPTION: $e');
                        debugPrint('Stack: $stackTrace');
                        setState(() {
                          _totalOCRFailed++;
                          _ocrResults.insert(0, '❌ Error: $e');
                          if (_ocrResults.length > 20) _ocrResults.removeLast();
                        });
                      }
                    }
                  },
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.purple,
                    child: const Row(
                      children: [
                        Icon(Icons.list, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'OCR Results (Latest First)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _ocrResults.isEmpty
                        ? const Center(
                            child: Text(
                              'Waiting for cropped plates...',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _ocrResults.length,
                            itemBuilder: (context, index) {
                              final result = _ocrResults[index];
                              final isSuccess = result.startsWith('✅');
                              return Card(
                                color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    result,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  trailing: Text(
                                    '#${_ocrResults.length - index}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
