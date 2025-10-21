# 🐛 Cropping Coordinate Mismatch Issue

## 📋 Status

**Current State:** 🟡 **INVESTIGATING**  
**Date:** October 21, 2025  
**Issue:** Cropped image orientation correct, but crop area doesn't match bounding box on screen

---

## 🔍 Symptoms

From user screenshot:
- ✅ **Rotation:** FIXED - Image is 474×124 pixels (landscape, correct!)  
- ❌ **Crop Area:** Doesn't match the bounding box shown on screen
- ❌ **Content:** Cropped region is different from what's inside the bounding box

**User Statement:**
> "secara hasil sudah benar cuma dia ngga sesuai dengan yang di box itu"

---

## 🎯 Potential Root Causes

### Theory 1: **Coordinate Scaling Issue**
```kotlin
Camera ImageProxy: 1920x1080 (sensor orientation)
        ↓
toBitmap(): 1920x1080 bitmap
        ↓
rotate 90°: 1080x1920 bitmap (portrait)
        ↓
ImageProcessor: Resize to 320x320 (model input)
        ↓
Inference: Bounding boxes in 320x320 space
        ↓
Scale back: Boxes mapped to origShape (1080x1920) ← Should be correct
        ↓
Cropping: Uses box.xywh on rotated bitmap
        ↓
Result: Crop area might be scaled incorrectly?
```

### Theory 2: **Overlay vs Crop Coordinate System Mismatch**
```
Overlay Drawing:
- Uses view coordinates (with scale/offset)
- Applies dx/dy translation for centering
- Shows bounding box at position (x, y) on screen

Cropping Logic:
- Uses result.boxes[].xywh directly
- No scale/offset applied
- Crops from position (x, y) on bitmap

→ If overlay has different coordinate transformation, 
   visual box ≠ actual crop area!
```

### Theory 3: **origShape vs Actual Bitmap Size**
```
result.origShape: Expected size from predictor (1080x1920)
rotatedBitmap: Actual bitmap size (could be different?)

If bitmap size ≠ origShape:
→ box.xywh coordinates won't match bitmap pixels!
```

---

## 🔬 Debug Information Needed

### From Logcat (Added Debug Logs):

```kotlin
=== BITMAP & RESULT DEBUG ===
ImageProxy size: ?x?
Bitmap size (from ImageUtils): ?x?
Result origShape: ?x?
Device orientation: PORTRAIT/LANDSCAPE
First box pixel coords: L=?, T=?, R=?, B=?
Rotated bitmap for cropping: ?x?
============================

=== CROPPING DEBUG ===
Original bitmap size: ?x?
First box coords: L=?, T=?, R=?, B=?
First box size: W=?, H=?
First box aspect ratio: ?
Cropped[0]: ?x?, aspect: ?
=====================
```

**What to Check:**
1. ✅ **origShape == rotatedBitmap size?** (Should match!)
2. ✅ **Box coordinates reasonable?** (Should be within 0 to bitmap size)
3. ✅ **Aspect ratio match?** (Box vs Crop should have same aspect ratio)

---

## 🛠️ Possible Solutions

### Solution A: **Scale Bounding Box to Match Overlay**

If overlay uses scaled coordinates:

```kotlin
// In processCroppingAsync()
val scale = maxOf(
    originalBitmap.width.toFloat() / result.origShape.width,
    originalBitmap.height.toFloat() / result.origShape.height
)

val scaledBoxes = result.boxes.map { box ->
    RectF(
        box.xywh.left * scale,
        box.xywh.top * scale,
        box.xywh.right * scale,
        box.xywh.bottom * scale
    )
}

// Use scaledBoxes for cropping
```

### Solution B: **Use Normalized Coordinates**

Convert to normalized (0-1) then back to bitmap pixels:

```kotlin
val normalizedBoxes = result.boxes.map { box ->
    RectF(
        box.xywh.left / result.origShape.width,
        box.xywh.top / result.origShape.height,
        box.xywh.right / result.origShape.width,
        box.xywh.bottom / result.origShape.height
    )
}

// Then scale to actual bitmap
val bitmapBoxes = normalizedBoxes.map { norm ->
    RectF(
        norm.left * originalBitmap.width,
        norm.top * originalBitmap.height,
        norm.right * originalBitmap.width,
        norm.bottom * originalBitmap.height
    )
}
```

### Solution C: **Use result.boxes[].xywhn (Normalized)**

`Box` class has both `xywh` (pixel) and `xywhn` (normalized):

```kotlin
// In processCroppingAsync()
val boundingBoxes = result.boxes.map { box -> 
    // Use normalized coordinates and scale to bitmap
    RectF(
        box.xywhn.left * originalBitmap.width,
        box.xywhn.top * originalBitmap.height,
        box.xywhn.right * originalBitmap.width,
        box.xywhn.bottom * originalBitmap.height
    )
}

// Crop with proper scaling
val croppedResults = ImageCropper.cropMultipleBoundingBoxes(
    originalBitmap,
    boundingBoxes,
    croppingPadding,
    useNormalizedCoords = false // Already converted to pixels
)
```

---

## 📊 Testing Plan

### Step 1: Check Debug Logs
```bash
adb logcat | grep "YOLOView"
```

Look for:
- Bitmap sizes at each stage
- Box coordinates
- origShape vs actual bitmap dimensions

### Step 2: Visual Verification

Compare on screen:
1. Bounding box position on camera preview
2. Cropped image content
3. Check if they match

### Step 3: Calculate Expected Crop

From screenshot metadata:
- **Box:** Should contain license plate "B 2156 78A"
- **Crop dimensions:** 474×124 pixels
- **Crop content:** Should show exactly what's in the box

If mismatch → coordinate transformation issue confirmed

---

## 🎯 Next Steps

1. ⏳ **Wait for app to run** and collect debug logs
2. ⏳ **Analyze coordinate values** from logs
3. ⏳ **Identify exact mismatch** (scale? offset? rotation?)
4. ⏳ **Implement appropriate fix** (Solution A, B, or C)
5. ⏳ **Test and verify** crop matches bounding box

---

## 📝 Notes

- Rotation fix (90°) already working ✅
- Issue is purely coordinate mapping
- Likely cause: origShape vs actual bitmap size mismatch
- OR: overlay coordinate transform not applied to cropping

---

**Status:** Awaiting debug logs from test run  
**Next:** Analyze logs → Apply fix → Test again
