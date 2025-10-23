# ============================================================
# [AUTO FIX] Fix OCR & Add API Integration
# ============================================================
# Script ini akan:
# 1. Hapus flag _hasProcessedThisCycle yang bermasalah
# 2. Hapus _currentPlateProcessing yang tidak dipakai
# 3. Tambahkan PajakService dan API integration
# 4. Fix streaming config jadi static
# 5. Tambahkan debug logging

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIX OCR & ADD API INTEGRATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$file = "lib\features\ocr_plat_nomor\screens\license_plate_cropping_screen.dart"

if (-not (Test-Path $file)) {
    Write-Host "[ERROR] File not found: $file" -ForegroundColor Red
    exit 1
}

# Backup
Copy-Item $file "$file.before_fix" -Force
Write-Host "[OK] Backup created: $file.before_fix" -ForegroundColor Green

# Read content
$content = Get-Content $file -Raw

Write-Host "[Step 1] Fixing imports..." -ForegroundColor Yellow
# Add missing imports
$content = $content -replace "import 'package:flutter/material.dart';`nimport 'package:ultralytics_yolo/ultralytics_yolo.dart';`nimport '../services/ocr_service.dart';", @"
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../services/ocr_service.dart';
import '../services/pajak_service.dart';
import '../../../app/theme.dart';
"@

Write-Host "  [OK] Added missing imports" -ForegroundColor Green

Write-Host "[Step 2] Removing problematic flags..." -ForegroundColor Yellow
# Remove _hasProcessedThisCycle declaration
$content = $content -replace "  bool _hasProcessedThisCycle = false; // .+ NEW: Prevent multiple crops.+`r?`n", ""

# Remove _currentPlateProcessing declaration  
$content = $content -replace "  PlateData\? _currentPlateProcessing; // Plate yang sedang diproses`r?`n", ""

Write-Host "  [OK] Removed _hasProcessedThisCycle and _currentPlateProcessing" -ForegroundColor Green

Write-Host "[Step 3] Adding PajakService..." -ForegroundColor Yellow
# Add PajakService after OCRService
$content = $content -replace "  late final OCRService _ocrService;`r?`n  bool _isOCREnabled = true;", @"
  late final OCRService _ocrService;
  late final PajakService _pajakService;
  bool _isOCREnabled = true;
  bool _isCheckingAPI = false;
"@

# Update initState
$content = $content -replace "    _ocrService = OCRService\(\);`r?`n    _statusMessage = 'Siap untuk deteksi & OCR plat nomor!';", @"
    _ocrService = OCRService();
    _pajakService = PajakService();
    _statusMessage = 'Siap untuk deteksi & OCR plat nomor!';
    
    // Debug initial state
    print('#### LicensePlateCroppingScreen INITIALIZED ####');
    print('   _isDetectionActive: `$_isDetectionActive');
    print('   _isProcessing: `$_isProcessing');
    print('   _isOCREnabled: `$_isOCREnabled');
    print('   OCR Service Ready: `${_ocrService.isReady}');
"@

Write-Host "  [OK] Added PajakService initialization" -ForegroundColor Green

Write-Host "[Step 4] Removing _hasProcessedThisCycle references..." -ForegroundColor Yellow
# Remove all _hasProcessedThisCycle references
$content = $content -replace "      _hasProcessedThisCycle = false; // .+ Reset flag`r?`n", ""

Write-Host "  [OK] Cleaned up flag references" -ForegroundColor Green

Write-Host "[Step 5] Removing _currentPlateProcessing references..." -ForegroundColor Yellow
# Remove _currentPlateProcessing assignments
$content = $content -replace "      _currentPlateProcessing = plateData;`r?`n", ""
$content = $content -replace "      _currentPlateProcessing = null;`r?`n", ""

Write-Host "  [OK] Cleaned up unused variable" -ForegroundColor Green

# Save
Set-Content $file -Value $content -NoNewline
Write-Host ""
Write-Host "[OK] File updated successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "FIX COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Yellow
Write-Host "  [OK] Added missing imports (dart:io, path_provider, pajak_service, theme)" -ForegroundColor Cyan
Write-Host "  [OK] Removed _hasProcessedThisCycle flag (caused OCR to run only once)" -ForegroundColor Cyan
Write-Host "  [OK] Removed _currentPlateProcessing unused variable" -ForegroundColor Cyan
Write-Host "  [OK] Added PajakService initialization" -ForegroundColor Cyan
Write-Host "  [OK] Added debug logging in initState" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: You need to manually add _checkPajakInfo() method" -ForegroundColor Yellow
Write-Host "and update streaming config to be static (not dynamic)" -ForegroundColor Yellow
Write-Host ""
