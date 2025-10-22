# 🔍 Debug Guide: Double Overlay Problem

## Problem
2 bounding boxes muncul di layar untuk 1 plat nomor yang terdeteksi.

## Enhanced Logging Added

Saya telah menambahkan logging yang sangat detail untuk melacak:

### 1. **Detection Level (ObjectDetector.kt)**
```
D/ObjectDetector: === DETECTION RESULTS (After Native NMS) ===
D/ObjectDetector: Total detections from native code: X
D/ObjectDetector:   Native[0]: conf=..., cls=..., x=..., y=...
```
- Ini menunjukkan berapa box yang dikembalikan oleh model SETELAH NMS
- **Expected**: 1 box untuk 1 plat nomor

### 2. **onDraw() Call Tracking (YOLOView.kt)**
```
🖼️ === onDraw() CALLED #X ===
🖼️ Time: [timestamp]
🖼️ inferenceResult has X box(es)
🖼️ showOverlays=true, proceeding to draw...
```
- **Counter #X**: Menunjukkan berapa kali `onDraw()` dipanggil
- **Expected**: 1 kali per frame

### 3. **Per-Box Drawing Details (YOLOView.kt)**
```
🎨 === OVERLAY DRAWING DEBUG ===
🎨 Total boxes to draw: X
🎨 isFrontCamera: true/false
🎨 Canvas size: W x H
🎨 View size: W x H
🎨 Scale: X, dx: X, dy: X

🎨 Drawing box[0]: plate_number conf=...
🎨   Original xywh: L=..., T=..., R=..., B=...
🎨   After scaling: L=..., T=..., R=..., B=...
🎨   After flip: L=..., T=..., R=..., B=...
🎨   Box dimensions: W=..., H=...
🎨   FINAL coords (after clamp): L=..., T=..., R=..., B=...
🎨   Drawing to canvas...

🎨 ✅ Finished drawing X box(es) for DETECT task
```

## How to Analyze

### Step 1: Check Detection Level
1. Tunggu app selesai build dan buka
2. Arahkan kamera ke plat nomor
3. Cari log `ObjectDetector: Total detections from native code:`
4. **Jika angkanya = 1**: Model sudah benar, masalah di rendering ✅
5. **Jika angkanya = 2 atau lebih**: Model masih double detect ❌

### Step 2: Check onDraw() Calls
1. Cari log `🖼️ === onDraw() CALLED #`
2. Lihat counter number
3. **Jika counter naik 1 per detection**: Normal ✅
4. **Jika counter naik 2+ kali untuk 1 detection**: onDraw() dipanggil multiple times ❌

### Step 3: Check Box Coordinates
1. Lihat log `🎨 Drawing box[0]` dan `🎨 Drawing box[1]` (jika ada 2)
2. Bandingkan koordinat FINAL:
   - **Jika koordinat SAMA**: Bug di drawing (menggambar 2x di lokasi sama) ❌
   - **Jika koordinat BEDA**: Model mendeteksi 2 box berbeda ❌

## Expected Log Pattern (CORRECT)
```
D/ObjectDetector: Total detections from native code: 1
D/ObjectDetector:   Native[0]: conf=0.736, cls=0, x=..., y=...

🖼️ === onDraw() CALLED #123 ===
🖼️ inferenceResult has 1 box(es)

🎨 === OVERLAY DRAWING DEBUG ===
🎨 Total boxes to draw: 1

🎨 Drawing box[0]: plate_number conf=0.736
🎨   FINAL coords (after clamp): L=373.05, T=160.89, R=847.05, B=323.89

🎨 ✅ Finished drawing 1 box(es) for DETECT task
```
**Result**: Hanya 1 box muncul di layar ✅

## Possible Scenarios

### Scenario A: Model Double Detection (Native NMS Gagal)
```
D/ObjectDetector: Total detections from native code: 2  ❌
D/ObjectDetector:   Native[0]: conf=0.783, cls=0, x=...
D/ObjectDetector:   Native[1]: conf=0.764, cls=0, x=...
```
**Solution**: Turunkan IoU threshold di native NMS atau confidence threshold

### Scenario B: onDraw() Called Multiple Times
```
🖼️ === onDraw() CALLED #123 ===
🖼️ inferenceResult has 1 box(es)
🖼️ === onDraw() CALLED #124 ===  ❌ Called again immediately!
🖼️ inferenceResult has 1 box(es)
```
**Solution**: Ada bug di invalidate logic atau multiple OverlayView instances

### Scenario C: Same Box Drawn Twice (Our Current Suspicion)
```
D/ObjectDetector: Total detections from native code: 1  ✅

🎨 Total boxes to draw: 1  ✅

🎨 Drawing box[0]: plate_number conf=0.736
🎨   FINAL coords: L=373.05, T=160.89, R=847.05, B=323.89
```
But you see 2 boxes on screen ❌

**Possible Causes**:
1. `onDraw()` called twice rapidly (check counter jumps)
2. Old frame data not cleared (check timestamps)
3. Hardware acceleration issue (multiple framebuffers)

## What to Send Me

Setelah test dengan plat nomor terlihat, kirim log yang berisi:

1. **Detection log** (`ObjectDetector: Total detections`)
2. **onDraw counter** (setidaknya 3-5 calls untuk melihat pattern)
3. **Box coordinates** (untuk melihat apakah koordinatnya sama atau beda)

Format:
```
<paste full log dari "ObjectDetector: ===" sampai "🎨 ✅ Finished drawing">
```

## Next Steps Based on Results

| Observation | Root Cause | Next Action |
|------------|-----------|-------------|
| Native detections = 1, onDraw called 1x, 1 box logged, but 2 boxes visible | Hardware/Canvas issue | Check hardware acceleration, try software rendering |
| Native detections = 1, onDraw called 2x for same frame | Multiple invalidate calls | Check invalidate logic, overlayView instance count |
| Native detections = 2 | Model/NMS issue | Lower IoU threshold, check model training data |
| Different FINAL coords for 2 boxes | Coordinate transformation bug | Review flip/clamp logic again |

## Quick Test Commands

```bash
# Monitor only relevant logs (if you have adb)
adb logcat -s ObjectDetector:D YOLOView:D | grep -E "(Total detections|onDraw\(\) CALLED|Drawing box|FINAL coords)"

# Clear logs before test
adb logcat -c

# Start monitoring
adb logcat ObjectDetector:D YOLOView:D *:S
```

## Files Modified
1. `android/src/main/kotlin/com/ultralytics/yolo/YOLOView.kt`
   - Added `drawCallCounter` to track onDraw() calls
   - Added detailed logging for each drawing stage
   - Added coordinate transformation logging

2. `android/src/main/kotlin/com/ultralytics/yolo/ObjectDetector.kt`
   - Already has comprehensive detection logging
   - Shows native NMS results

---

**Status**: Waiting for log output from device when 2 boxes appear on screen.
