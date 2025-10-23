/// Re-export dari services untuk feature module
/// Model hanya perlu tahu tentang struktur data
library;

export 'get_info_pajak_model.dart';
export '../services/pajak_service.dart' show PajakInfo, NomorPolisi;
