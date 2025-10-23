/// Re-export dari services untuk feature module
/// Model hanya perlu tahu tentang struktur data
library;

export 'package:ultralytics_yolo_example/services/get_info_pajak_model.dart';
export '../services/pajak_service.dart' show PajakInfo, NomorPolisi;
