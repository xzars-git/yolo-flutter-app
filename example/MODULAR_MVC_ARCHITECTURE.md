# 🏗️ Modular MVC Architecture

Struktur aplikasi ini menggunakan **Feature-Based Modular MVC** pattern untuk scalability dan maintainability.

## 📁 Struktur Folder

```
lib/
├── app/                          # 🎨 App-level configuration
│   ├── app.dart                 # MaterialApp wrapper
│   ├── theme.dart               # Theme configuration (colors, styles)
│   └── routes.dart              # Named routes & route generator
│
├── core/                         # 🔧 Shared utilities (cross-feature)
│   ├── constants/
│   │   ├── api_constants.dart  # API endpoints, base URLs
│   │   └── app_constants.dart  # App-wide constants
│   └── utils/
│       ├── formatters.dart     # Currency, date, text formatting
│       └── validators.dart     # Input validation utilities
│
├── features/                     # 🎯 Feature modules (self-contained)
│   └── ocr_plat_nomor/         # Feature: OCR Plat Nomor
│       ├── models/             # Data models for this feature
│       │   ├── ocr_result.dart
│       │   └── pajak_info.dart
│       ├── views/              # UI screens & widgets
│       │   └── widgets/       # Feature-specific widgets
│       ├── controllers/        # Business logic & state management
│       │   └── ocr_controller.dart
│       ├── services/          # Data layer (API, OCR, etc)
│       │   ├── ocr_service.dart
│       │   └── pajak_service.dart
│       └── ocr_plat_nomor.dart # Barrel export file
│
├── services/                     # 🌐 Shared services (legacy/cross-feature)
│   ├── get_info_pajak_model.dart  # Shared API models
│   └── model_manager.dart         # YOLO model manager
│
├── presentation/                 # 📱 Legacy presentation layer
│   └── screens/                 # (will be migrated to features/)
│       └── simple_ocr_test_screen.dart
│
└── main.dart                     # 🚀 App entry point
```

## 🎯 Feature Module Pattern

Setiap feature adalah **self-contained module** dengan struktur MVC lengkap:

```
features/
└── [feature_name]/
    ├── models/          # Data structures
    ├── views/           # UI screens & widgets
    ├── controllers/     # Business logic
    ├── services/        # Data sources
    └── [feature].dart   # Public API (barrel export)
```

### Keuntungan:
✅ **Isolation**: Setiap feature berdiri sendiri
✅ **Scalability**: Mudah menambah feature baru
✅ **Testability**: Bisa test per-feature
✅ **Reusability**: Feature bisa di-share antar project
✅ **Team collaboration**: Developer bisa kerja di feature berbeda tanpa conflict

## 📦 Barrel Exports

Setiap feature module memiliki barrel file (`[feature].dart`) untuk clean imports:

```dart
// ❌ Tanpa barrel - messy imports
import 'package:app/features/ocr_plat_nomor/models/ocr_result.dart';
import 'package:app/features/ocr_plat_nomor/controllers/ocr_controller.dart';
import 'package:app/features/ocr_plat_nomor/services/ocr_service.dart';

// ✅ Dengan barrel - clean & simple
import 'package:app/features/ocr_plat_nomor/ocr_plat_nomor.dart';
```

## 🔄 Data Flow

```
User Action (View)
    ↓
Controller (Business Logic)
    ↓
Service (Data Layer)
    ↓
Model (Data Structure)
    ↓
Controller (Update State)
    ↓
View (UI Update)
```

## 📝 Contoh Penggunaan

### 1. Menambah Feature Baru

```bash
lib/features/
└── [new_feature]/
    ├── models/
    ├── views/
    ├── controllers/
    ├── services/
    └── [new_feature].dart
```

### 2. Import Feature

```dart
// In main.dart or routes.dart
import 'package:ultralytics_yolo_example/features/ocr_plat_nomor/ocr_plat_nomor.dart';

// Use exported classes
final controller = OCRController();
final result = OCRResult.success('B 1234 ABC');
```

### 3. Shared Utilities

```dart
// Import dari core/
import 'package:ultralytics_yolo_example/core/utils/formatters.dart';
import 'package:ultralytics_yolo_example/core/constants/api_constants.dart';

// Use utilities
final formatted = Formatters.formatCurrency(1000000); // "Rp 1.000.000"
final url = ApiConstants.getInfoPajakUrl;
```

## 🚀 Best Practices

1. **Feature Isolation**: Feature tidak boleh import feature lain directly
2. **Shared Logic**: Extract ke `core/` jika dipakai multiple features
3. **Barrel Exports**: Selalu gunakan barrel file untuk public API
4. **Single Responsibility**: Satu file = satu class/responsibility
5. **Naming Convention**:
   - Models: `[entity]_model.dart` or `[entity].dart`
   - Controllers: `[entity]_controller.dart`
   - Services: `[entity]_service.dart`
   - Screens: `[screen]_screen.dart`

## 🔄 Migration Path

**Current State**: Hybrid (modular + legacy)
- ✅ Feature module: `features/ocr_plat_nomor/`
- ⏳ Legacy: `presentation/screens/`

**Next Steps**:
1. Refactor `SimpleOCRTestScreen` to use `OCRController`
2. Move screen to `features/ocr_plat_nomor/views/`
3. Remove legacy `presentation/` folder
4. Add new features following modular pattern

## 📚 References

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
