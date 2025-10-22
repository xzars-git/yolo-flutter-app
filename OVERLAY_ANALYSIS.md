# 📊 Analisis Code Overlay & Masalah Double Overlay

## 🎯 Ringkasan Masalah

**Masalah Utama**: Double detection (2 bounding box untuk 1 objek yang sama)
- Box 1: 78.3% confidence
- Box 2: 76.4% confidence
- **Bukan masalah double overlay**, tapi **double detection dari model**

---

## 🔍 Struktur Overlay di YOLOView.kt

### 1. **Inisialisasi Overlay View**

```kotlin
// Line 196 - Pembuatan OverlayView
private val overlayView: OverlayView = OverlayView(context)
```

**Lokasi dalam struktur view**:
```kotlin
// Line 240-257 - Hierarki View
init {
    removeAllViews()

    // 1) Container untuk camera preview
    val previewContainer = FrameLayout(context)
    previewContainer.addView(previewView)  // Camera view
    addView(previewContainer)              // Add container ke YOLOView

    // 2) Overlay di atas camera
    addView(overlayView, LayoutParams(
        MATCH_PARENT,
        MATCH_PARENT
    ))

    // 3) Z-order setup untuk memastikan overlay di atas
    overlayView.elevation = 100f        // ✅ Elevation tinggi
    overlayView.translationZ = 100f     // ✅ Translation Z tinggi
    previewContainer.elevation = 1f     // Camera di bawah
}
```

**Kesimpulan**: Hanya ada **SATU overlay view** yang dibuat.

---

### 2. **Inner Class OverlayView**

```kotlin
// Line 903-920 - Definisi OverlayView
private inner class OverlayView(context: Context) : View(context) {
    private val paint = Paint().apply { isAntiAlias = true }

    init {
        // Background transparan
        setBackgroundColor(Color.TRANSPARENT)
        
        // Hardware layer untuk performa
        setLayerType(LAYER_TYPE_HARDWARE, null)

        // Z-order tinggi
        elevation = 1000f      // ✅ Sangat tinggi
        translationZ = 1000f   // ✅ Sangat tinggi

        setWillNotDraw(false)

        // Tidak intercept touch events
        isClickable = false
        isFocusable = false
    }
}
```

**Kesimpulan**: Overlay setup dengan benar, tidak ada duplikasi.

---

### 3. **Method onDraw() - Menggambar Overlay**

```kotlin
// Line 917-1050+ - onDraw() untuk rendering
override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)
    val result = inferenceResult ?: return
    
    // 🔥 PENTING: Hanya gambar jika showOverlays = true
    if (!showOverlays) {
        return
    }

    // Kalkulasi scaling
    val iw = result.origShape.width.toFloat()   // Image width
    val ih = result.origShape.height.toFloat()  // Image height
    val vw = width.toFloat()   // View width
    val vh = height.toFloat()  // View height

    val scaleX = vw / iw
    val scaleY = vh / ih
    val scale = max(scaleX, scaleY)  // Uniform scaling

    val scaledW = iw * scale
    val scaledH = ih * scale
    val dx = (vw - scaledW) / 2f  // Offset X (centering)
    val dy = (vh - scaledH) / 2f  // Offset Y (centering)

    // Gambar boxes
    when (task) {
        YOLOTask.DETECT -> {
            // 🔥 Loop melalui SEMUA boxes yang ada di result.boxes
            for (box in result.boxes) {  // ⚠️ INI MASALAHNYA!
                // Kalkulasi posisi box
                var left = box.xywh.left * scale + dx
                var top = box.xywh.top * scale + dy
                var right = box.xywh.right * scale + dx
                var bottom = box.xywh.bottom * scale + dy
                
                // Gambar rectangle
                canvas.drawRoundRect(left, top, right, bottom, ...)
                
                // Gambar label
                canvas.drawText("${box.cls} ${box.conf*100}%", ...)
            }
        }
        // ... task lainnya
    }
}
```

**Kesimpulan**: Method `onDraw()` menggambar **SEMUA** boxes yang ada di `result.boxes`. Jika ada 2 boxes (double detection), maka akan digambar 2 boxes.

---

### 4. **Trigger Redraw - invalidate()**

```kotlin
// Line 897-899 - Di dalam onFrame()
post {
    overlayView.invalidate()  // ✅ Trigger redraw overlay
}
```

**Frekuensi**: Dipanggil setiap kali ada inference result baru (setiap frame).

---

## 🐛 Root Cause Analysis: Bukan Double Overlay

### ❌ Bukan Masalah Overlay

1. **Hanya ada 1 OverlayView instance** (line 196)
2. **Hanya ada 1 onDraw() call** per invalidate()
3. **Tidak ada duplikasi canvas drawing**

### ✅ Masalah Sebenarnya: Double Detection

```kotlin
// Di onFrame() - Line 772-780
val result = p.predict(bitmap, ...)  // ⚠️ Result dari model inference

inferenceResult = resultWithOriginalImage  // ⚠️ Simpan result

// Line 855-866 - Debug log
Log.d(TAG, "Total boxes after NMS: ${result.boxes.size}")
if (result.boxes.size > 1) {
    Log.w(TAG, "⚠️ WARNING: Multiple boxes detected")
    for ((idx, box) in result.boxes.withIndex()) {
        Log.w(TAG, "Box[$idx]: cls=${box.cls}, conf=${box.conf}")
    }
}
```

**Output log yang menunjukkan masalah**:
```
Total boxes after NMS: 2
⚠️ WARNING: Multiple boxes detected
  Box[0]: cls=plat_nomor, conf=0.783
  Box[1]: cls=plat_nomor, conf=0.764
```

**Kesimpulan**: Model mendeteksi **2 objek berbeda** untuk 1 plat nomor yang sama.

---

## 🔬 Dimana Double Detection Terjadi?

### 1. **ObjectDetector.kt - Inference & NMS**

```kotlin
// ObjectDetector.kt - predict() method
fun predict(bitmap: Bitmap, ...): YOLOResult {
    // 1. Run model inference
    interpreter.run(inputBuffer, outputBuffer)
    
    // 2. Parse output tensor
    val boxes = parseDetections(outputBuffer)  // Raw detections
    
    // 3. Apply NMS (Non-Maximum Suppression)
    val filteredIndices = nonMaxSuppression(
        boxes.map { it.rect },
        boxes.map { it.conf },
        iouThreshold = IOU_THRESHOLD  // ⚠️ Default 0.45, diturunkan ke 0.20
    )
    
    // 4. Build final result
    val finalBoxes = filteredIndices.map { boxes[it] }
    return YOLOResult(boxes = finalBoxes, ...)
}
```

**NMS (Non-Maximum Suppression)** seharusnya menghapus duplikasi, tapi tidak bekerja dengan baik.

---

### 2. **GeometryUtils.kt - NMS Implementation**

```kotlin
// GeometryUtils.kt - nonMaxSuppression()
fun nonMaxSuppression(
    boxes: List<RectF>, 
    scores: List<Float>, 
    iouThreshold: Float
): List<Int> {
    val sortedIndices = scores.indices.sortedByDescending { scores[it] }
    val keep = mutableListOf<Int>()
    
    for (i in sortedIndices) {
        var shouldKeep = true
        for (j in keep) {
            val iou = computeIoU(boxes[i], boxes[j])  // ⚠️ Kalkulasi IoU
            if (iou > iouThreshold) {  // ⚠️ Jika overlap > threshold
                shouldKeep = false     // Buang box ini
                break
            }
        }
        if (shouldKeep) keep.add(i)
    }
    return keep
}
```

**Masalah**: Jika 2 boxes memiliki IoU ≤ threshold (0.20), keduanya akan **dipertahankan**.

---

### 3. **Threshold Settings di YOLOView.kt**

```kotlin
// Line 228-229 - Threshold defaults
private var confidenceThreshold = 0.25  // Confidence filter
private var iouThreshold = 0.20         // 🔥 Aggressive NMS (lowered from 0.45)
```

**Fix yang sudah dicoba**:
- ✅ IoU threshold diturunkan dari 0.45 → 0.20
- ✅ Confidence threshold tetap 0.25
- ❌ **Masih ada double detection**

---

## 📈 Flow Diagram: Dari Inference ke Overlay

```
┌─────────────────────────────────────────────────────────────┐
│ 1. CAMERA FRAME CAPTURE                                     │
│    ImageProxy → Bitmap (ImageUtils.toBitmap())              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. MODEL INFERENCE (ObjectDetector.kt)                      │
│    predictor.predict(bitmap, w, h, ...)                     │
│    ├─ TFLite model execution                                │
│    ├─ Parse output tensor                                   │
│    ├─ Apply confidence filter (≥ 0.25)                      │
│    └─ Apply NMS (IoU threshold 0.20)  ⚠️ MASALAH DI SINI   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. RESULT OBJECT (YOLOResult)                               │
│    result.boxes = [Box1, Box2]  ⚠️ 2 BOXES!                │
│    - Box1: conf=0.783, xywh=[...]                           │
│    - Box2: conf=0.764, xywh=[...]                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. STORE RESULT                                             │
│    inferenceResult = result  (Line 852)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. TRIGGER OVERLAY REDRAW                                   │
│    post { overlayView.invalidate() }  (Line 897)            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. DRAW OVERLAY (OverlayView.onDraw())                      │
│    for (box in result.boxes) {  ⚠️ LOOP 2x                 │
│        canvas.drawRoundRect(...)  // Box 1                  │
│        canvas.drawText(...)       // Label 1                │
│        canvas.drawRoundRect(...)  // Box 2  ⚠️ DUPLIKASI   │
│        canvas.drawText(...)       // Label 2 ⚠️ DUPLIKASI   │
│    }                                                         │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. USER SEES 2 BOUNDING BOXES                               │
│    📦 Box 1: plat_nomor 78.3%                               │
│    📦 Box 2: plat_nomor 76.4%                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Code Overlay Components

### Components yang Menggambar di Layar:

1. **Paint Object** (Line 904)
   ```kotlin
   private val paint = Paint().apply { isAntiAlias = true }
   ```
   - Digunakan untuk semua drawing operations
   - Style: STROKE untuk outline, FILL untuk background

2. **Bounding Box Drawing** (Line 991-1003)
   ```kotlin
   paint.color = newColor
   paint.style = Paint.Style.STROKE
   paint.strokeWidth = BOX_LINE_WIDTH  // 8f
   canvas.drawRoundRect(
       left, top, right, bottom,
       BOX_CORNER_RADIUS,  // 12f
       BOX_CORNER_RADIUS,
       paint
   )
   ```

3. **Label Background** (Line 1062-1067)
   ```kotlin
   paint.style = Paint.Style.FILL
   paint.color = newColor
   canvas.drawRoundRect(
       bgRect, 
       BOX_CORNER_RADIUS, 
       BOX_CORNER_RADIUS, 
       paint
   )
   ```

4. **Label Text** (Line 1069-1073)
   ```kotlin
   paint.color = Color.WHITE
   val labelText = "${box.cls} ${box.conf*100}%"
   canvas.drawText(labelText, x, baseline, paint)
   ```

---

## 🔧 Koordinat Calculation untuk Overlay

### Scaling Logic (Line 923-942):

```kotlin
// 1. Dimensi image dari inference result
val iw = result.origShape.width.toFloat()   // e.g., 720
val ih = result.origShape.height.toFloat()  // e.g., 1280

// 2. Dimensi view (screen)
val vw = width.toFloat()   // e.g., 1080
val vh = height.toFloat()  // e.g., 2400

// 3. Kalkulasi scale factor
val scaleX = vw / iw  // 1080 / 720 = 1.5
val scaleY = vh / ih  // 2400 / 1280 = 1.875
val scale = max(scaleX, scaleY)  // 1.875 (use larger to fill)

// 4. Dimensi scaled image
val scaledW = iw * scale  // 720 * 1.875 = 1350
val scaledH = ih * scale  // 1280 * 1.875 = 2400

// 5. Centering offset
val dx = (vw - scaledW) / 2f  // (1080 - 1350) / 2 = -135
val dy = (vh - scaledH) / 2f  // (2400 - 2400) / 2 = 0
```

### Box Position Calculation (Line 973-976):

```kotlin
// Bounding box dari inference (dalam pixel koordinat image)
// box.xywh = RectF(left, top, right, bottom)

// Transform ke screen coordinates
var left = box.xywh.left * scale + dx
var top = box.xywh.top * scale + dy
var right = box.xywh.right * scale + dx
var bottom = box.xywh.bottom * scale + dy
```

**Contoh**:
```
Inference box: (100, 200, 300, 400) di image 720x1280
Scale: 1.875
Offset: dx=-135, dy=0

Screen coordinates:
  left   = 100 * 1.875 + (-135) = 187.5 - 135 = 52.5
  top    = 200 * 1.875 + 0 = 375
  right  = 300 * 1.875 + (-135) = 562.5 - 135 = 427.5
  bottom = 400 * 1.875 + 0 = 750
```

---

## 📊 Debugging Logs untuk Overlay

### Logs yang Relevan:

```kotlin
// Line 950 - Drawing detection
Log.d(TAG, "Drawing DETECT boxes: ${result.boxes.size}")

// Line 953-958 - First box debug
if (result.boxes.isNotEmpty()) {
    val firstBox = result.boxes[0]
    Log.d(TAG, "=== First Box Debug ===")
    Log.d(TAG, "Box normalized coords: (${firstBox.xywhn})")
    Log.d(TAG, "Box pixel coords: (${firstBox.xywh})")
}

// Line 1009 - Per box drawing
Log.d(TAG, "Drawing box for ${box.cls}: L=$left, T=$top, R=$right, B=$bottom, conf=${box.conf}")
```

**Output log normal** (1 box):
```
Drawing DETECT boxes: 1
=== First Box Debug ===
Box normalized coords: (0.1, 0.2, 0.3, 0.4)
Box pixel coords: (100, 200, 300, 400)
Drawing box for plat_nomor: L=52.5, T=375, R=427.5, B=750, conf=0.783
```

**Output log dengan double detection** (2 boxes):
```
Drawing DETECT boxes: 2
=== First Box Debug ===
Box normalized coords: (0.1, 0.2, 0.3, 0.4)
Box pixel coords: (100, 200, 300, 400)
Drawing box for plat_nomor: L=52.5, T=375, R=427.5, B=750, conf=0.783
Drawing box for plat_nomor: L=55.0, T=378, R=430.0, B=753, conf=0.764
```

---

## ✅ Kesimpulan Final

### 1. **Overlay Code: ✅ CORRECT**
- Hanya 1 OverlayView instance
- Hanya 1 onDraw() call per frame
- Koordinat calculation benar
- Z-order setup benar
- Tidak ada duplikasi overlay

### 2. **Masalah Sebenarnya: ❌ DOUBLE DETECTION**
- Model mendeteksi 2 boxes untuk 1 objek
- NMS tidak cukup agresif (IoU 0.20 masih tidak cukup)
- Problem di ObjectDetector.kt atau model itu sendiri

### 3. **Lokasi Code yang Perlu Diperiksa**:

| File | Line | Fungsi | Masalah |
|------|------|--------|---------|
| `ObjectDetector.kt` | ~150-250 | `predict()` | Inference & NMS logic |
| `GeometryUtils.kt` | ~120-150 | `nonMaxSuppression()` | NMS algorithm |
| `YOLOView.kt` | 228-229 | Thresholds | IoU & confidence settings |
| `native-lib.cpp` | ? | C++ NMS | Native NMS implementation (jika ada) |

### 4. **Yang BUKAN Masalah**:
- ❌ Double overlay rendering
- ❌ Multiple OverlayView instances
- ❌ Multiple onDraw() calls
- ❌ Canvas drawing logic
- ❌ Coordinate transformation

---

## 🚀 Solusi yang Sudah Dicoba

### ✅ Yang Sudah Dilakukan:

1. **Class-Aware NMS** (CROPPING_ROTATION_BUG.md)
   ```kotlin
   // Modifikasi NMS untuk filter per class
   val boxesByClass = boxes.groupBy { it.cls }
   for ((cls, classBoxes) in boxesByClass) {
       val filteredIndices = nonMaxSuppression(classBoxes, 0.20)
       // ...
   }
   ```
   **Status**: ❌ Tidak berhasil

2. **IoU Threshold Reduction** (0.45 → 0.20)
   ```kotlin
   private var iouThreshold = 0.20  // Very aggressive
   ```
   **Status**: ❌ Masih ada double detection

3. **Enhanced Logging**
   ```kotlin
   Log.w(TAG, "⚠️ WARNING: Multiple boxes detected (${boxes.size})")
   ```
   **Status**: ✅ Membantu debugging

---

## 📝 Rekomendasi Selanjutnya

### Option 1: Backport ke v0.1.37 (RECOMMENDED)
- v0.1.37 tidak memiliki bug double detection
- Backport cropping feature dari v0.1.39
- Lebih cepat daripada debug regression bug

### Option 2: Debug v0.1.39 NMS (COMPLEX)
- Periksa perubahan di PR #348
- Compare NMS implementation v0.1.37 vs v0.1.39
- Identifikasi regression

### Option 3: Post-Processing Filter (WORKAROUND)
- Tambah filter tambahan setelah NMS
- Deteksi boxes yang sangat overlap
- Hapus box dengan confidence lebih rendah

---

**Created**: October 22, 2025  
**Analyzed**: YOLOView.kt overlay rendering & double detection issue  
**Conclusion**: Overlay code correct, issue is in model inference/NMS
