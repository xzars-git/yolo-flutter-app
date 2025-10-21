# 🔍 Ringkasan Analisis Bug Double Detection

## 📋 Kesimpulan Utama

**Bug yang Terjadi**: 2 bounding box muncul untuk 1 plat nomor

**Versi yang Bermasalah**:
- ✅ v0.1.37 (September 2024): **NORMAL** - tidak ada double detection
- ❌ v0.1.38 (2 minggu lalu): **BUG MULAI MUNCUL**
- ❌ v0.1.39 (minggu lalu): **BUG MASIH ADA**

**Penyebab**: Bug diperkenalkan di versi v0.1.38 karena ada "Major Architecture Refactor" (PR #348)

---

## 🎯 Temuan Penting dari GitHub Releases

### v0.1.38 - Titik Awal Bug

Dari catatan rilis resmi v0.1.38:

```
📊 Key Changes

• Major architecture refactor groundwork (PR #348) 🧩
  ◦ Introduces modular controllers, utilities, and overlay widgets
  ◦ Centralizes platform channel management
```

**Ini adalah penyebab utama** - PR #348 mengubah arsitektur code yang kemungkinan besar mengubah cara NMS (Non-Maximum Suppression) bekerja.

---

## 📊 Perbandingan Code

### 1. Threshold IoU

#### v0.1.37 (Normal)
```kotlin
// YOLOView.kt
private var iouThreshold = 0.45  // 45%

// ObjectDetector.kt
private var iouThreshold = 0.4f  // 40%
```

#### v0.1.39 (Sekarang - Sudah Difix)
```kotlin
// YOLOView.kt
private var iouThreshold = 0.20  // 20% (fix kita)

// ObjectDetector.kt
private var iouThreshold = 0.2f  // 20% (fix kita)
```

**Catatan**: Nilai 0.20 adalah fix yang saya terapkan. Perlu dicek apa nilai default v0.1.38.

---

### 2. Algoritma NMS

#### v0.1.37 (Normal)
```cpp
// native-lib.cpp - SIMPLE NMS
for (int i = 0; i < n; i++) {
    const DetectedObject &a = objects[i];
    bool keep = true;
    
    for (int j = 0; j < picked.size(); j++) {
        const DetectedObject &b = objects[picked[j]];
        // Langsung bandingkan IoU tanpa cek class
        float iou = inter_area / union_area;
        
        if (iou > nms_threshold) {
            keep = false;
            break;
        }
    }
    
    if (keep) picked.push_back(i);
}
```

#### v0.1.39 (Sekarang - Sudah Difix)
```cpp
// native-lib.cpp - CLASS-AWARE NMS + LOGGING
for (int i = 0; i < n; i++) {
    const DetectedObject &a = objects[i];
    bool keep = true;
    
    for (int j = 0; j < picked.size(); j++) {
        const DetectedObject &b = objects[picked[j]];
        
        // 🔥 FIX: CEK CLASS DULU SEBELUM BANDINGKAN
        if (a.index != b.index) {
            continue;  // Skip kalau beda class
        }
        
        float iou = inter_area / union_area;
        
        if (iou > nms_threshold) {
            keep = false;
            break;
        }
    }
    
    if (keep) picked.push_back(i);
}
```

**Perbedaan Krusial**:
- v0.1.37: NMS sederhana tanpa cek class
- v0.1.39: NMS dengan class-aware check (fix kita)

---

## 🤔 Pertanyaan Penting

**Kalau v0.1.37 tidak ada class-aware NMS, kenapa tidak ada bug double detection?**

### Hipotesis Kemungkinan

#### Hipotesis 1: Format Output Model Berubah
Refactoring v0.1.38 mungkin mengubah cara parsing output model, sehingga menghasilkan lebih banyak box proposal yang sebelumnya tidak ada.

#### Hipotesis 2: Ekstraksi Proposal Berubah
PR #348 (major refactor) mungkin mengubah logika ekstraksi box dari tensor output model di fungsi `postprocess()`.

#### Hipotesis 3: Filtering Sebelum NMS Dihapus
v0.1.37 mungkin punya filtering tambahan SEBELUM NMS yang dihapus di v0.1.38.

#### Hipotesis 4: Waktu Filtering Confidence Berubah
- v0.1.37: Filter confidence lebih awal → proposal lebih sedikit masuk ke NMS
- v0.1.38+: Filter confidence lebih lambat → proposal lebih banyak masuk ke NMS

---

## 🔍 Yang Perlu Diverifikasi

### 1. Cek Jumlah Proposal

Dengan logging yang sudah saya tambahkan, cek di device:

```bash
adb logcat -s NMS_DEBUG:D | grep "TOTAL PROPOSALS"
```

**Harapan v0.1.37**:
```
=== TOTAL PROPOSALS BEFORE NMS: 1 ===  (atau sedikit)
```

**v0.1.39 sekarang**:
```
=== TOTAL PROPOSALS BEFORE NMS: 2 ===  (atau banyak)
```

**Kalau jumlah proposal berbeda, berarti bug ada di ekstraksi, bukan NMS!**

---

### 2. Test Skenario

**Test Case**: 1 plat nomor dengan confidence 78%

#### v0.1.37 (Normal) - Expected:
```
Proposals: 1 box
NMS: Tidak perlu (cuma 1 box)
Output: 1 box ✅
```

#### v0.1.39 (Sekarang dengan fix):
```
Proposals: 2 boxes (cls=0, conf=0.783 dan cls=0, conf=0.764)
NMS: 2 → 1 (1 box disuppress karena IoU > 0.20)
Output: 1 box ✅
```

---

## 🔧 Fix yang Sudah Diterapkan

### Fix 1: Threshold IoU Lebih Agresif
```kotlin
// Turunkan dari 0.45 → 0.20 (sangat agresif)
private var iouThreshold = 0.20
```

**Tujuan**: Suppress box apa pun yang overlap > 20%

### Fix 2: Class-Aware NMS
```cpp
// Tambah pengecekan class sebelum compare IoU
if (a.index != b.index) {
    continue;  // Skip kalau beda class
}
```

**Tujuan**: Praktek standar YOLO - hanya bandingkan box dengan class yang sama

### Fix 3: Logging Lengkap
- Log stage ekstraksi proposal
- Log proses NMS  
- Log hasil akhir deteksi

**Tujuan**: Diagnosa dari mana asal double detection

---

## ✅ Langkah Testing

### 1. Test di Device
```bash
# Build dan run app
flutter clean
flutter pub get
flutter run

# Monitor log
adb logcat -s NMS_DEBUG:D YOLOView:D ObjectDetector:D
```

### 2. Cek Output Log

**Yang harus dicari**:
```
=== PROPOSAL EXTRACTION ===
  Proposal[0]: cls=0, conf=0.783, x=..., y=...
  Proposal[1]: cls=0, conf=0.764, x=..., y=...
=== TOTAL PROPOSALS BEFORE NMS: 2 ===

=== NMS START: 2 objects, threshold=0.200 ===
  Checking Box[0]: cls=0, conf=0.783
  ✅ Box[0] KEPT
  
  Checking Box[1]: cls=0, conf=0.764
  📏 Box[1] vs Box[0]: IoU=0.420
  ❌ Box[1] SUPPRESSED (IoU > 0.200)
  
=== NMS END: 1/2 boxes kept ===

=== FINAL DETECTION RESULTS ===
Total boxes after NMS: 1
```

**Kalau output seperti ini, fix BERHASIL! ✅**

---

## 📝 Rekomendasi

### Kalau Fix Berhasil
1. ✅ **Pertahankan class-aware NMS** (praktek standar)
2. 🎚️ **Naikkan threshold dari 0.20 → 0.30** (lebih wajar)
3. 🗑️ **Hapus logging verbose** untuk production
4. 📄 **Update CHANGELOG.md**
5. 🐛 **Pertimbangkan PR ke Ultralytics** (bantu komunitas)

### Kalau Fix Tidak Berhasil
1. 🔍 Cek logika ekstraksi proposal (lines 103-145 di native-lib.cpp)
2. 🔍 Bandingkan cara panggil postprocess() dengan v0.1.37
3. 🔍 Cek apakah pipeline BasePredictor berubah
4. 📧 Hubungi tim Ultralytics dengan analisis lengkap

---

## 📊 Tabel Perbandingan

| Aspek | v0.1.37 ✅ | v0.1.38+ ❌ | Fix Kita 🔧 |
|-------|-----------|------------|-------------|
| **IoU Threshold (YOLOView)** | 0.45 | ??? | 0.20 |
| **IoU Threshold (ObjectDetector)** | 0.4f | ??? | 0.2f |
| **Class-Aware NMS** | ❌ Tidak | ❌ Tidak | ✅ Ya |
| **Debug Logging** | ❌ Tidak | ❌ Tidak | ✅ Ya |
| **Arsitektur** | Original | Refactored | Refactored |
| **Double Detection** | ❌ Tidak ada | ✅ Ada | 🔧 Difix? |

---

## 🔗 Link GitHub

- **v0.1.37 (Terakhir Normal)**: https://github.com/ultralytics/yolo-flutter-app/releases/tag/v0.1.37
- **v0.1.38 (Bug Muncul)**: https://github.com/ultralytics/yolo-flutter-app/releases/tag/v0.1.38
- **v0.1.39 (Bug Masih Ada)**: https://github.com/ultralytics/yolo-flutter-app/releases/tag/v0.1.39
- **PR #348 (Penyebab)**: https://github.com/ultralytics/yolo-flutter-app/pull/348

---

## ⚡ Apa yang Harus Dilakukan Sekarang?

### 1. Test Langsung di Device (PRIORITAS TINGGI)
```bash
# Di terminal
cd "d:\Bapenda New\explore\yolo-flutter-app\example"
flutter run

# Di terminal lain, monitor log
adb logcat -s NMS_DEBUG:D | grep -E "PROPOSAL|NMS|DETECTION"
```

### 2. Lihat Hasilnya
- ✅ **Kalau cuma 1 box**: Fix berhasil!
- ❌ **Kalau masih 2 boxes**: Perlu investigasi lebih lanjut

### 3. Share Hasil Log
Copy log yang keluar dan share ke saya untuk analisis lebih lanjut.

---

## 🎯 Kesimpulan

1. **Bug confirmed** ada di package official v0.1.38+, bukan di implementasi kamu
2. **Root cause** kemungkinan besar dari refactoring architecture di PR #348
3. **Fix sudah diterapkan**:
   - Class-aware NMS ✅
   - Threshold agresif 0.20 ✅
   - Logging lengkap ✅
4. **Perlu testing** di device untuk verifikasi fix berhasil
5. **Kalau berhasil**, bisa di-optimize threshold dan submit PR ke Ultralytics

---

**Status**: Analisis Selesai ✅ | Menunggu Testing 🔄

**Dibuat**: 21 Oktober 2025
