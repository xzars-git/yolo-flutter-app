# 🏗️ MVC Architecture - OCR Plat Nomor

## 📁 Struktur Folder

```
lib/
├── main.dart                      # Entry point aplikasi
│
├── models/                        # 📦 MODEL - Data structures
│   ├── ocr_result.dart           # Model untuk hasil OCR
│   └── pajak_info.dart           # Re-export model pajak dari services
│
├── views/                         # 👁️ VIEW - UI Components
│   └── ocr_screen.dart           # Screen utama OCR (sementara wrapper)
│
├── controllers/                   # 🎮 CONTROLLER - Business Logic
│   └── ocr_controller.dart       # Controller untuk OCR operations
│
├── services/                      # 🔧 SERVICES - External operations
│   ├── ocr_service.dart          # OCR processing dengan ML Kit
│   ├── pajak_service.dart        # API calls ke server pajak
│   └── get_info_pajak_model.dart # API response models
│
└── presentation/                  # 🎨 LEGACY - Will be migrated
    └── screens/
        └── simple_ocr_test_screen.dart  # Original screen (akan dipindah ke views/)
```

## 🎯 MVC Pattern Explanation

### 1. **MODEL** (`models/`)
- **Tanggung Jawab**: Representasi data dan struktur
- **Tidak boleh**: Berisi business logic atau UI code
- **Contoh**: 
  ```dart
  class OCRResult {
    final String text;
    final bool isValid;
    final String? errorMessage;
  }
  ```

### 2. **VIEW** (`views/`)
- **Tanggung Jawab**: Menampilkan UI dan handle user input
- **Tidak boleh**: Berisi business logic atau direct API calls
- **Harus**: Menggunakan Controller untuk semua operasi
- **Contoh**:
  ```dart
  class OCRScreen extends StatelessWidget {
    // UI components only
    // Delegates to Controller for actions
  }
  ```

### 3. **CONTROLLER** (`controllers/`)
- **Tanggung Jawab**: Business logic, state management, koordinasi antara Model dan View
- **Tidak boleh**: Berisi UI code atau direct HTTP implementation
- **Harus**: Menggunakan Services untuk operations
- **Contoh**:
  ```dart
  class OCRController extends ChangeNotifier {
    Future<OCRResult?> processCroppedImages(...) { }
    Future<PajakInfo> checkPajakInfo(...) { }
    void resumeDetection() { }
  }
  ```

### 4. **SERVICES** (`services/`)
- **Tanggung Jawab**: External operations (API, OCR, Database)
- **Tidak boleh**: Manage UI state atau business rules
- **Harus**: Reusable dan testable
- **Contoh**:
  ```dart
  class OCRService {
    Future<String?> extractLicensePlateText(Uint8List bytes) { }
  }
  
  class PajakService {
    Future<PajakInfo> getInfoPajak(String platNomor) { }
  }
  ```

## 🔄 Data Flow

```
User Input (View)
    ↓
Controller (Business Logic)
    ↓
Services (External Operations)
    ↓
Model (Data Structure)
    ↓
Controller (Update State)
    ↓
View (Re-render UI)
```

## 📝 Current Status

### ✅ Completed
- [x] Folder structure created
- [x] Model layer defined (`OCRResult`, `PajakInfo`)
- [x] Controller layer created (`OCRController`)
- [x] Services layer exists (`OCRService`, `PajakService`)
- [x] View layer wrapper created

### 🚧 In Progress
- [ ] Migrate `SimpleOCRTestScreen` ke pure View component
- [ ] Integrate `OCRController` dengan View
- [ ] Remove business logic dari View
- [ ] Add unit tests untuk Controller

### 📋 TODO
- [ ] Create ViewModel layer (optional, for complex state)
- [ ] Add dependency injection
- [ ] Add state management solution (Provider/Riverpod)
- [ ] Create widget tests
- [ ] Add documentation comments

## 🎨 Benefits of MVC

1. **Separation of Concerns** - Setiap layer punya tanggung jawab jelas
2. **Testability** - Controller dan Services mudah di-unit test
3. **Maintainability** - Perubahan di satu layer tidak affect yang lain
4. **Reusability** - Services dan Models bisa dipakai ulang
5. **Scalability** - Mudah add fitur baru tanpa破坏 existing code

## 🔧 How to Use

### Using Controller in View:

```dart
import 'package:ultralytics_yolo_example/controllers/ocr_controller.dart';

class OCRScreen extends StatefulWidget {
  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  late final OCRController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OCRController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCroppedImages(List<String> paths) async {
    final result = await _controller.processCroppedImages(paths);
    if (result != null && result.isValid) {
      final pajakInfo = await _controller.checkPajakInfo(result.text);
      // Show dialog dengan pajakInfo
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          // UI components
          // Display _controller.totalOCRSuccess, etc
        );
      },
    );
  }
}
```

## 📚 Resources

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [MVC vs MVVM vs BLoC](https://www.youtube.com/watch?v=RS36gBEp8OI)

---

**Last Updated**: 2025-10-22  
**Author**: GitHub Copilot  
**Status**: 🚧 Migration in Progress
