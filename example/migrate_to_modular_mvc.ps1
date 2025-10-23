# ============================================================
# [AUTO FIX] Migrate to Modular MVC Architecture
# ============================================================
# Script ini akan:
# 1. Pindahkan semua file ke features/ocr_plat_nomor/
# 2. Update imports di semua file
# 3. Hapus struktur lama (presentation/, services/, models/)
# 4. Clean build dan test

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MODULAR MVC MIGRATION" -ForegroundColor Cyan
Write-Host "Move everything to features/ocr_plat_nomor/" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Step 1: Create clean modular MVC structure
# ============================================================
Write-Host "[Step 1] Creating modular MVC structure..." -ForegroundColor Yellow

$folders = @(
    "lib\features\ocr_plat_nomor\screens",
    "lib\features\ocr_plat_nomor\services",
    "lib\features\ocr_plat_nomor\models",
    "lib\features\ocr_plat_nomor\controllers"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  [OK] Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  [OK] Exists: $folder" -ForegroundColor Green
    }
}

# ============================================================
# Step 2: Move license_plate_cropping_screen.dart to feature
# ============================================================
Write-Host ""
Write-Host "[Step 2] Moving license_plate_cropping_screen.dart..." -ForegroundColor Yellow

$oldScreen = "lib\presentation\screens\license_plate_cropping_screen.dart"
$newScreen = "lib\features\ocr_plat_nomor\screens\license_plate_cropping_screen.dart"

if (Test-Path $oldScreen) {
    # Backup
    Copy-Item $oldScreen "$oldScreen.backup" -Force
    Write-Host "  [OK] Backup created: $oldScreen.backup" -ForegroundColor Green
    
    # Read content
    $content = Get-Content $oldScreen -Raw
    
    # Fix imports - change from old structure to modular
    Write-Host "  [OK] Fixing imports..." -ForegroundColor Cyan
    
    # Change: import '../../services/ocr_service.dart' 
    # To: import '../services/ocr_service.dart'
    $content = $content -replace "import '../../services/", "import '../services/"
    $content = $content -replace "import '../../features/ocr_plat_nomor/services/", "import '../services/"
    $content = $content -replace "import '../../features/ocr_plat_nomor/models/", "import '../models/"
    
    # Keep app imports correct
    # Change: import '../../app/theme.dart'
    # To: import '../../../app/theme.dart' (go up 3 levels dari features/ocr_plat_nomor/screens/)
    $content = $content -replace "import '../../app/", "import '../../../app/"
    
    # Save to new location
    Set-Content $newScreen -Value $content -NoNewline
    Write-Host "  [OK] Moved to: $newScreen" -ForegroundColor Green
    
    # Delete old file
    Remove-Item $oldScreen -Force
    Write-Host "  [OK] Deleted old file" -ForegroundColor Green
    
} elseif (Test-Path $newScreen) {
    Write-Host "  [OK] Already in correct location!" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] File not found!" -ForegroundColor Red
}

# ============================================================
# Step 3: Move get_info_pajak_model.dart to models
# ============================================================
Write-Host ""
Write-Host "[Step 3] Moving get_info_pajak_model.dart..." -ForegroundColor Yellow

$oldModel = "lib\services\get_info_pajak_model.dart"
$newModel = "lib\features\ocr_plat_nomor\models\get_info_pajak_model.dart"

if (Test-Path $oldModel) {
    # Backup
    Copy-Item $oldModel "$oldModel.backup" -Force
    Write-Host "  [OK] Backup created: $oldModel.backup" -ForegroundColor Green
    
    # Move to new location
    Copy-Item $oldModel $newModel -Force
    Write-Host "  [OK] Moved to: $newModel" -ForegroundColor Green
    
    # Delete old file
    Remove-Item $oldModel -Force
    Write-Host "  [OK] Deleted old file" -ForegroundColor Green
    
} elseif (Test-Path $newModel) {
    Write-Host "  [OK] Already in correct location!" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] File not found (might be already moved)" -ForegroundColor Yellow
}

# ============================================================
# Step 4: Update imports in pajak_service.dart
# ============================================================
Write-Host ""
Write-Host "[Step 4] Updating imports in pajak_service.dart..." -ForegroundColor Yellow

$pajakService = "lib\features\ocr_plat_nomor\services\pajak_service.dart"

if (Test-Path $pajakService) {
    $content = Get-Content $pajakService -Raw
    
    # Fix import path for get_info_pajak_model
    # Change: import '../../services/get_info_pajak_model.dart'
    # To: import '../models/get_info_pajak_model.dart'
    $content = $content -replace "import '../../services/get_info_pajak_model.dart'", "import '../models/get_info_pajak_model.dart'"
    $content = $content -replace "import 'package:ultralytics_yolo_example/services/get_info_pajak_model.dart'", "import '../models/get_info_pajak_model.dart'"
    
    Set-Content $pajakService -Value $content -NoNewline
    Write-Host "  [OK] Updated imports" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] File not found" -ForegroundColor Yellow
}

# ============================================================
# Step 5: Update main.dart routing
# ============================================================
Write-Host ""
Write-Host "[Step 5] Updating main.dart routing..." -ForegroundColor Yellow

$mainFile = "lib\main.dart"

if (Test-Path $mainFile) {
    $content = Get-Content $mainFile -Raw
    
    # Fix import path for license_plate_cropping_screen
    # Change: import 'presentation/screens/license_plate_cropping_screen.dart'
    # To: import 'features/ocr_plat_nomor/screens/license_plate_cropping_screen.dart'
    $content = $content -replace "import 'presentation/screens/license_plate_cropping_screen.dart'", "import 'features/ocr_plat_nomor/screens/license_plate_cropping_screen.dart'"
    
    Set-Content $mainFile -Value $content -NoNewline
    Write-Host "  [OK] Updated imports in main.dart" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] main.dart not found!" -ForegroundColor Red
}

# ============================================================
# Step 6: Check if old folders are empty and delete
# ============================================================
Write-Host ""
Write-Host "[Step 6] Checking old MVC folders..." -ForegroundColor Yellow

$oldFolders = @(
    "lib\presentation\screens",
    "lib\presentation\controllers",
    "lib\presentation\widgets",
    "lib\presentation",
    "lib\services",
    "lib\models"
)

foreach ($folder in $oldFolders) {
    if (Test-Path $folder) {
        $items = Get-ChildItem -Path $folder -Recurse -File | Where-Object { $_.Extension -ne '.backup' }
        
        if ($items.Count -eq 0) {
            Write-Host "  [CLEAN] Deleting empty folder: $folder" -ForegroundColor Gray
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "  [KEEP] Folder not empty: $folder ($($items.Count) files)" -ForegroundColor Yellow
            Write-Host "         Files:" -ForegroundColor Gray
            $items | ForEach-Object { Write-Host "         - $($_.Name)" -ForegroundColor Gray }
        }
    }
}

# ============================================================
# Step 7: Show final structure
# ============================================================
Write-Host ""
Write-Host "[Step 7] Final Modular MVC Structure:" -ForegroundColor Yellow
Write-Host ""

$featureRoot = "lib\features\ocr_plat_nomor"
if (Test-Path $featureRoot) {
    Write-Host "  [OK] features/ocr_plat_nomor/" -ForegroundColor Green
    
    $subFolders = @("screens", "services", "models", "controllers")
    foreach ($sub in $subFolders) {
        $path = "$featureRoot\$sub"
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -File
            Write-Host "    [OK] $sub/ ($($files.Count) files)" -ForegroundColor Green
            $files | ForEach-Object { Write-Host "        - $($_.Name)" -ForegroundColor Cyan }
        } else {
            Write-Host "    [EMPTY] $sub/" -ForegroundColor Gray
        }
    }
}

# ============================================================
# Step 8: Clean build
# ============================================================
Write-Host ""
Write-Host "[Step 8] Clean build cache..." -ForegroundColor Yellow

flutter clean | Out-Null
Write-Host "  [OK] Cache cleaned" -ForegroundColor Green

# ============================================================
# Done!
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "MIGRATION COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: flutter pub get" -ForegroundColor Cyan
Write-Host "  2. Run: flutter run --release" -ForegroundColor Cyan
Write-Host "  3. Test OCR functionality" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you see any import errors, check:" -ForegroundColor Yellow
Write-Host "  - lib/main.dart (routing)" -ForegroundColor Cyan
Write-Host "  - lib/features/ocr_plat_nomor/screens/license_plate_cropping_screen.dart (imports)" -ForegroundColor Cyan
Write-Host "  - lib/features/ocr_plat_nomor/services/pajak_service.dart (imports)" -ForegroundColor Cyan
Write-Host ""
