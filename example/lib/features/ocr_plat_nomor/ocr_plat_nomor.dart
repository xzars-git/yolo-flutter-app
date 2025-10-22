/// Feature module export untuk OCR Plat Nomor
/// Barrel file untuk clean imports
library ocr_plat_nomor;

// Models
export 'models/ocr_result.dart';
export 'models/pajak_info.dart';

// Controllers
export 'controllers/ocr_controller.dart';

// Services
export 'services/ocr_service.dart' hide OCRResult; // Hide internal OCRResult class (for confidence scores)
export 'services/pajak_service.dart';

// Views - temporary wrapper, nanti akan di-refactor
export 'package:ultralytics_yolo_example/presentation/screens/simple_ocr_test_screen.dart';
