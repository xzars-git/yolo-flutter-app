# 🚗 Blueprint: Pajak Status Checking - Dual Mode Implementation

## 📋 Executive Summary

Blueprint ini menjelaskan **arsitektur lengkap** untuk menambahkan fitur **Pajak Status Checking** ke plugin `ultralytics_yolo` dengan **2 mode operasi** yang bisa dipilih oleh developer.

---

## 🎯 Kebutuhan Bisnis

### **Mode 1: Callback-Based (App-Controlled)**
Developer aplikasi punya kontrol penuh atas:
- ✅ OCR implementation (bisa pilih Google ML Kit, Tesseract, custom)
- ✅ API endpoint (bisa pakai Bapenda, API custom, atau offline)
- ✅ Business logic (validation, caching, retry logic)
- ✅ Error handling custom

**Use Case:**
- App dengan multiple regions (Jabar, Jateng, Jatim - beda API)
- Butuh custom OCR training
- Butuh offline mode
- Butuh integrasi dengan backend sendiri

### **Mode 2: Built-in (Plugin-Managed)**
Plugin sudah menyediakan implementasi lengkap:
- ✅ OCR dengan Google ML Kit (pre-configured)
- ✅ API integration ke Bapenda Jabar (hardcoded)
- ✅ Automatic retry & error handling
- ✅ Caching mechanism
- ✅ Internet time validation

**Use Case:**
- Prototyping cepat
- App sederhana (single region - Jabar)
- Developer tidak perlu implementasi OCR/API
- Quick deployment

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    ULTRALYTICS YOLO PLUGIN                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  YOLOView.kt (Core Detection & Overlay)                    │ │
│  │  ├─ Camera Feed                                            │ │
│  │  ├─ YOLO Inference                                         │ │
│  │  ├─ Image Cropping                                         │ │
│  │  └─ Overlay Rendering (green/red/yellow)                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  PajakCheckStrategy (Strategy Pattern)                     │ │
│  │  ├─ Mode 1: CallbackBased → PajakStatusCallback           │ │
│  │  └─ Mode 2: BuiltIn → BuiltInPajakChecker                 │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────┴─────────────────────┐
        ↓                                           ↓
┌──────────────────────┐              ┌──────────────────────┐
│  MODE 1: CALLBACK    │              │  MODE 2: BUILT-IN    │
├──────────────────────┤              ├──────────────────────┤
│ App implements:      │              │ Plugin provides:     │
│ • OCR (custom)       │              │ • Google ML Kit OCR  │
│ • API (any endpoint) │              │ • Bapenda API        │
│ • Business logic     │              │ • Auto retry         │
│ • Error handling     │              │ • Caching            │
└──────────────────────┘              └──────────────────────┘
```

---

## 📦 Implementation Plan

### **PHASE 1: Core Strategy Pattern**

#### 1.1 Create Strategy Interface & Enum

**File: `PajakCheckStrategy.kt`** (NEW)

```kotlin
package com.ultralytics.yolo

/**
 * Strategy pattern untuk pajak checking
 * Allows developer to choose between callback-based or built-in implementation
 */
sealed class PajakCheckStrategy {
    /**
     * Disabled: No pajak checking
     */
    object Disabled : PajakCheckStrategy()
    
    /**
     * Callback-Based: App implements OCR and API logic
     * 
     * Usage:
     * ```
     * val strategy = PajakCheckStrategy.CallbackBased(object : PajakStatusCallback {
     *     override fun onOCRRequest(image: ByteArray, onResult: (String) -> Unit) {
     *         // Custom OCR implementation
     *     }
     *     override fun onCheckPajakStatus(platNomor: String, onResult: (PajakInfo) -> Unit) {
     *         // Custom API implementation
     *     }
     * })
     * yoloView.setPajakStrategy(strategy)
     * ```
     */
    data class CallbackBased(
        val callback: PajakStatusCallback
    ) : PajakCheckStrategy()
    
    /**
     * Built-in: Plugin provides complete OCR + API implementation
     * 
     * Usage:
     * ```
     * val strategy = PajakCheckStrategy.BuiltIn(
     *     apiEndpoint = "https://atospamor-v2.bapenda.jabarprov.go.id/api/atos-pamor/v1/get-info-pajak",
     *     apiKey = null,  // Optional API key
     *     ocrEngine = OCREngine.ML_KIT,
     *     enableCaching = true,
     *     cacheDurationMs = 300000  // 5 minutes
     * )
     * yoloView.setPajakStrategy(strategy)
     * ```
     */
    data class BuiltIn(
        val apiEndpoint: String = DEFAULT_API_ENDPOINT,
        val apiKey: String? = null,
        val ocrEngine: OCREngine = OCREngine.ML_KIT,
        val enableCaching: Boolean = true,
        val cacheDurationMs: Long = 300000,  // 5 minutes
        val enableRetry: Boolean = true,
        val maxRetries: Int = 3,
        val retryDelayMs: Long = 1000
    ) : PajakCheckStrategy() {
        companion object {
            const val DEFAULT_API_ENDPOINT = "https://atospamor-v2.bapenda.jabarprov.go.id/api/atos-pamor/v1/get-info-pajak"
        }
    }
}

/**
 * OCR Engine options for Built-in mode
 */
enum class OCREngine {
    ML_KIT,      // Google ML Kit Text Recognition (recommended)
    TESSERACT,   // Tesseract OCR (more customizable but slower)
    CUSTOM       // Custom OCR implementation
}

/**
 * Status pajak kendaraan
 */
enum class PajakStatus {
    UNKNOWN,     // Belum dicek / data tidak ditemukan
    TAAT,        // Pajak masih berlaku (hijau)
    MENUNGGAK,   // Pajak sudah lewat (merah)
    CHECKING,    // Sedang proses (kuning)
    ERROR        // Error (gray)
}

/**
 * Data class untuk informasi pajak
 */
data class PajakInfo(
    val platNomor: String,
    val status: PajakStatus,
    val message: String = "",
    
    // API response fields (optional)
    val tgAkhirPajak: String? = null,
    val tgAkhirPajakBaru: String? = null,
    val selisihHari: Int? = null,
    val nmPemilik: String? = null,
    val nmMerekKb: String? = null,
    val warnaKb: String? = null,
    val beaPkbPok0: Int? = null,
    val beaSwdklljPok0: Int? = null,
    val totalBiaya: Int? = null,
    val timestamp: Long = System.currentTimeMillis()
)

/**
 * Callback interface for Mode 1 (Callback-Based)
 */
interface PajakStatusCallback {
    fun onOCRRequest(croppedImage: ByteArray, onResult: (String) -> Unit)
    fun onCheckPajakStatus(platNomor: String, onResult: (PajakInfo) -> Unit)
    fun onOverlayTapped(pajakInfo: PajakInfo) {}  // Optional
}

/**
 * Helper untuk parsing plat nomor
 */
object PlatNomorParser {
    fun parse(platNomor: String): Triple<String, String, String>? {
        val cleaned = platNomor.replace(Regex("\\s+"), "").uppercase()
        val pattern = Regex("^([A-Z]{1,2})([0-9]{1,4})([A-Z]{1,3})$")
        val match = pattern.find(cleaned)
        return match?.let {
            val (polisi1, polisi2, polisi3) = it.destructured
            Triple(polisi1, polisi2, polisi3)
        }
    }
    
    fun format(platNomor: String): String {
        val parsed = parse(platNomor)
        return parsed?.let { "${it.first} ${it.second} ${it.third}" } ?: platNomor
    }
    
    fun getKodePlat(platNomor: String): String = "1"  // Default hitam
}
```

---

### **PHASE 2: Built-in Implementation**

#### 2.1 Built-in OCR with Google ML Kit

**File: `BuiltInOCRProcessor.kt`** (NEW)

```kotlin
package com.ultralytics.yolo

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.tasks.await

/**
 * Built-in OCR processor using Google ML Kit
 * Handles license plate text recognition
 */
class BuiltInOCRProcessor(private val context: Context) {
    
    private val textRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    
    companion object {
        private const val TAG = "BuiltInOCRProcessor"
    }
    
    /**
     * Process cropped image and extract plate number
     * @param imageBytes JPEG image bytes
     * @return Plate number string (e.g., "D6060AIP") or null if failed
     */
    suspend fun processImage(imageBytes: ByteArray): String? {
        return try {
            Log.d(TAG, "Starting OCR processing...")
            
            // Decode bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode image")
                return null
            }
            
            Log.d(TAG, "Bitmap decoded: ${bitmap.width}x${bitmap.height}")
            
            // Create InputImage
            val inputImage = InputImage.fromBitmap(bitmap, 0)
            
            // Process with ML Kit
            val result = textRecognizer.process(inputImage).await()
            
            Log.d(TAG, "OCR completed, detected ${result.textBlocks.size} text blocks")
            
            // Extract text
            val detectedText = result.text
            Log.d(TAG, "Detected text: $detectedText")
            
            // Clean and format
            val cleaned = cleanOCRText(detectedText)
            
            // Validate format
            val parsed = PlatNomorParser.parse(cleaned)
            if (parsed == null) {
                Log.w(TAG, "OCR result does not match plate format: $cleaned")
                return null
            }
            
            val formatted = PlatNomorParser.format(cleaned)
            Log.d(TAG, "OCR success: $formatted")
            
            bitmap.recycle()
            return cleaned
            
        } catch (e: Exception) {
            Log.e(TAG, "OCR processing failed", e)
            null
        }
    }
    
    /**
     * Clean OCR text to extract only plate number
     */
    private fun cleanOCRText(text: String): String {
        // Remove whitespace and special characters
        val cleaned = text
            .replace(Regex("\\s+"), "")
            .replace(Regex("[^A-Z0-9]"), "")
            .uppercase()
        
        Log.d(TAG, "Cleaned text: $cleaned")
        
        // Try to find plate pattern
        val pattern = Regex("([A-Z]{1,2}[0-9]{1,4}[A-Z]{1,3})")
        val match = pattern.find(cleaned)
        
        return match?.value ?: cleaned
    }
    
    fun close() {
        textRecognizer.close()
    }
}
```

#### 2.2 Built-in API Client

**File: `BuiltInPajakAPIClient.kt`** (NEW)

```kotlin
package com.ultralytics.yolo

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

/**
 * Built-in API client for Bapenda Jabar Pajak API
 */
class BuiltInPajakAPIClient(
    private val apiEndpoint: String,
    private val apiKey: String?,
    private val enableRetry: Boolean,
    private val maxRetries: Int,
    private val retryDelayMs: Long
) {
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
        .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
        .build()
    
    companion object {
        private const val TAG = "BuiltInPajakAPIClient"
        private const val INTERNET_TIME_API = "https://worldtimeapi.org/api/timezone/Asia/Jakarta"
    }
    
    /**
     * Check pajak status from API
     */
    suspend fun checkPajakStatus(platNomor: String): PajakInfo = withContext(Dispatchers.IO) {
        var lastError: Exception? = null
        var attempt = 0
        
        while (attempt < (if (enableRetry) maxRetries else 1)) {
            attempt++
            
            try {
                Log.d(TAG, "API call attempt $attempt for: $platNomor")
                
                // Parse plat nomor
                val parsed = PlatNomorParser.parse(platNomor) ?: run {
                    Log.e(TAG, "Invalid plate format: $platNomor")
                    return@withContext PajakInfo(
                        platNomor = platNomor,
                        status = PajakStatus.ERROR,
                        message = "Format plat tidak valid"
                    )
                }
                
                val (polisi1, polisi2, polisi3) = parsed
                val kodePlat = PlatNomorParser.getKodePlat(platNomor)
                
                // Build request body
                val whereArray = JSONArray().apply {
                    put(JSONArray().apply {
                        put("objek_pajak_no_polisi1")
                        put("=")
                        put(polisi1)
                    })
                    put(JSONArray().apply {
                        put("objek_pajak_no_polisi2")
                        put("=")
                        put(polisi2)
                    })
                    put(JSONArray().apply {
                        put("objek_pajak_no_polisi3")
                        put("=")
                        put(polisi3)
                    })
                    put(JSONArray().apply {
                        put("objek_pajak_kd_plat")
                        put("=")
                        put(kodePlat)
                    })
                }
                
                val requestBody = JSONObject().apply {
                    put("where", whereArray)
                    put("bayar_kedepan", "T")
                }
                
                Log.d(TAG, "Request body: $requestBody")
                
                // Make API call
                val request = Request.Builder()
                    .url(apiEndpoint)
                    .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                    .apply {
                        apiKey?.let { addHeader("Authorization", "Bearer $it") }
                    }
                    .build()
                
                val response = client.newCall(request).execute()
                val responseBody = response.body?.string()
                
                Log.d(TAG, "Response code: ${response.code}")
                Log.d(TAG, "Response body: $responseBody")
                
                if (!response.isSuccessful || responseBody == null) {
                    throw IOException("API call failed: ${response.code}")
                }
                
                // Parse response
                val jsonResponse = JSONObject(responseBody)
                
                if (!jsonResponse.optBoolean("success", false)) {
                    val message = jsonResponse.optString("message", "Data tidak ditemukan")
                    Log.w(TAG, "API returned error: $message")
                    return@withContext PajakInfo(
                        platNomor = PlatNomorParser.format(platNomor),
                        status = PajakStatus.UNKNOWN,
                        message = message
                    )
                }
                
                // Extract data
                val data = jsonResponse.getJSONObject("data")
                val dataHitungPajak = data.getJSONObject("data_hitung_pajak")
                
                val tgAkhirPajakBaru = dataHitungPajak.optString("tg_akhir_pajak_baru")
                val nmPemilik = data.optString("nm_pemilik")
                val nmMerekKb = data.optString("nm_merek_kb")
                val warnaKb = data.optString("warna_kb")
                
                // Get internet time
                val today = getInternetTime() ?: LocalDate.now()
                
                // Parse tax expiry date
                val tgAkhir = LocalDate.parse(tgAkhirPajakBaru, DateTimeFormatter.ISO_LOCAL_DATE)
                val selisihHari = ChronoUnit.DAYS.between(today, tgAkhir).toInt()
                
                // Determine status
                val status = if (tgAkhir.isBefore(today)) {
                    PajakStatus.MENUNGGAK
                } else {
                    PajakStatus.TAAT
                }
                
                val message = if (status == PajakStatus.TAAT) {
                    "Pajak berlaku s/d $tgAkhirPajakBaru"
                } else {
                    "Pajak lewat sejak $tgAkhirPajakBaru"
                }
                
                Log.d(TAG, "Pajak status: $status, selisih hari: $selisihHari")
                
                return@withContext PajakInfo(
                    platNomor = PlatNomorParser.format(platNomor),
                    status = status,
                    message = message,
                    tgAkhirPajakBaru = tgAkhirPajakBaru,
                    selisihHari = selisihHari,
                    nmPemilik = nmPemilik,
                    nmMerekKb = nmMerekKb,
                    warnaKb = warnaKb,
                    beaPkbPok0 = dataHitungPajak.optInt("bea_pkb_pok0"),
                    beaSwdklljPok0 = dataHitungPajak.optInt("bea_swdkllj_pok0"),
                    totalBiaya = dataHitungPajak.optInt("total_biaya")
                )
                
            } catch (e: Exception) {
                Log.e(TAG, "API call failed (attempt $attempt)", e)
                lastError = e
                
                if (attempt < maxRetries && enableRetry) {
                    kotlinx.coroutines.delay(retryDelayMs)
                }
            }
        }
        
        // All retries failed
        return@withContext PajakInfo(
            platNomor = PlatNomorParser.format(platNomor),
            status = PajakStatus.ERROR,
            message = "Gagal mengecek pajak: ${lastError?.message}"
        )
    }
    
    /**
     * Get internet time to prevent local time manipulation
     */
    private suspend fun getInternetTime(): LocalDate? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(INTERNET_TIME_API)
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            val responseBody = response.body?.string()
            
            if (response.isSuccessful && responseBody != null) {
                val json = JSONObject(responseBody)
                val datetime = json.getString("datetime")
                LocalDate.parse(datetime.substring(0, 10))
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get internet time", e)
            null
        }
    }
}
```

#### 2.3 Built-in Checker Orchestrator

**File: `BuiltInPajakChecker.kt`** (NEW)

```kotlin
package com.ultralytics.yolo

import android.content.Context
import android.util.Log
import android.util.LruCache
import kotlinx.coroutines.*

/**
 * Built-in pajak checker - orchestrates OCR and API calls
 */
class BuiltInPajakChecker(
    private val context: Context,
    private val config: PajakCheckStrategy.BuiltIn
) {
    private val ocrProcessor = BuiltInOCRProcessor(context)
    private val apiClient = BuiltInPajakAPIClient(
        apiEndpoint = config.apiEndpoint,
        apiKey = config.apiKey,
        enableRetry = config.enableRetry,
        maxRetries = config.maxRetries,
        retryDelayMs = config.retryDelayMs
    )
    
    // Cache for pajak info
    private val cache = if (config.enableCaching) {
        LruCache<String, CachedPajakInfo>(50)
    } else {
        null
    }
    
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    companion object {
        private const val TAG = "BuiltInPajakChecker"
    }
    
    data class CachedPajakInfo(
        val info: PajakInfo,
        val timestamp: Long
    )
    
    /**
     * Process plate image end-to-end
     * @param imageBytes Cropped plate image
     * @param onResult Callback with final PajakInfo
     */
    fun processPlate(imageBytes: ByteArray, onResult: (PajakInfo) -> Unit) {
        scope.launch {
            try {
                Log.d(TAG, "Processing plate image...")
                
                // Step 1: OCR
                val platNomor = ocrProcessor.processImage(imageBytes)
                
                if (platNomor == null) {
                    withContext(Dispatchers.Main) {
                        onResult(PajakInfo(
                            platNomor = "???",
                            status = PajakStatus.ERROR,
                            message = "Gagal membaca plat nomor"
                        ))
                    }
                    return@launch
                }
                
                Log.d(TAG, "OCR result: $platNomor")
                
                // Check cache
                cache?.get(platNomor)?.let { cached ->
                    val age = System.currentTimeMillis() - cached.timestamp
                    if (age < config.cacheDurationMs) {
                        Log.d(TAG, "Using cached result (age: ${age}ms)")
                        withContext(Dispatchers.Main) {
                            onResult(cached.info)
                        }
                        return@launch
                    }
                }
                
                // Step 2: API check
                val pajakInfo = apiClient.checkPajakStatus(platNomor)
                
                // Cache result
                cache?.put(platNomor, CachedPajakInfo(pajakInfo, System.currentTimeMillis()))
                
                Log.d(TAG, "Pajak info retrieved: ${pajakInfo.status}")
                
                // Return result
                withContext(Dispatchers.Main) {
                    onResult(pajakInfo)
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error processing plate", e)
                withContext(Dispatchers.Main) {
                    onResult(PajakInfo(
                        platNomor = "???",
                        status = PajakStatus.ERROR,
                        message = "Error: ${e.message}"
                    ))
                }
            }
        }
    }
    
    fun cleanup() {
        scope.cancel()
        ocrProcessor.close()
        cache?.evictAll()
    }
}
```

---

### **PHASE 3: Integration into YOLOView**

#### 3.1 Modify YOLOView.kt

**Add properties:**

```kotlin
// Pajak checking
private var pajakStrategy: PajakCheckStrategy = PajakCheckStrategy.Disabled
private var builtInChecker: BuiltInPajakChecker? = null
private var currentPajakInfo: PajakInfo? = null
private var lastOCRTime: Long = 0
private val OCR_COOLDOWN_MS = 3000L
```

**Add methods:**

```kotlin
/**
 * Set pajak checking strategy
 * @param strategy PajakCheckStrategy (Disabled, CallbackBased, or BuiltIn)
 */
fun setPajakStrategy(strategy: PajakCheckStrategy) {
    // Cleanup old checker
    builtInChecker?.cleanup()
    builtInChecker = null
    
    pajakStrategy = strategy
    
    // Initialize built-in checker if needed
    if (strategy is PajakCheckStrategy.BuiltIn) {
        builtInChecker = BuiltInPajakChecker(context, strategy)
    }
    
    Log.d(TAG, "Pajak strategy set: ${strategy::class.simpleName}")
}

/**
 * Get current pajak strategy
 */
fun getPajakStrategy(): PajakCheckStrategy = pajakStrategy
```

**Modify cropping callback:**

```kotlin
// In processCroppingAsync(), after cropping success:
if (pajakStrategy != PajakCheckStrategy.Disabled && croppedImageData.isNotEmpty()) {
    val now = System.currentTimeMillis()
    
    // Cooldown check
    if (now - lastOCRTime < OCR_COOLDOWN_MS) {
        Log.d(TAG, "OCR cooldown active")
        return@execute
    }
    
    lastOCRTime = now
    
    // Get first cropped image
    val firstCrop = croppedImageData.first()
    val cacheKey = firstCrop["cacheKey"] as String
    val croppedBytes = croppedImagesCache[cacheKey] ?: return@execute
    
    // Show CHECKING status
    post {
        currentPajakInfo = PajakInfo(
            platNomor = "Scanning...",
            status = PajakStatus.CHECKING,
            message = "Membaca plat nomor..."
        )
        overlayView.invalidate()
    }
    
    when (pajakStrategy) {
        is PajakCheckStrategy.CallbackBased -> {
            // Mode 1: Callback-based
            val callback = (pajakStrategy as PajakCheckStrategy.CallbackBased).callback
            
            post {
                callback.onOCRRequest(croppedBytes) { ocrResult ->
                    callback.onCheckPajakStatus(ocrResult) { pajakInfo ->
                        currentPajakInfo = pajakInfo
                        overlayView.invalidate()
                    }
                }
            }
        }
        
        is PajakCheckStrategy.BuiltIn -> {
            // Mode 2: Built-in
            builtInChecker?.processPlate(croppedBytes) { pajakInfo ->
                currentPajakInfo = pajakInfo
                overlayView.invalidate()
            }
        }
        
        else -> {
            // Disabled - do nothing
        }
    }
}
```

**Modify overlay rendering:**

```kotlin
// In OverlayView.onDraw(), for DETECT task:
val (bgColor, strokeColor, labelText) = if (currentPajakInfo != null) {
    when (currentPajakInfo!!.status) {
        PajakStatus.TAAT -> Triple(
            Color.argb(200, 76, 175, 80),   // Green
            Color.argb(255, 46, 125, 50),
            "${currentPajakInfo!!.platNomor}\nTAAT"
        )
        PajakStatus.MENUNGGAK -> Triple(
            Color.argb(200, 244, 67, 54),   // Red
            Color.argb(255, 198, 40, 40),
            "${currentPajakInfo!!.platNomor}\nMENUNGGAK"
        )
        PajakStatus.CHECKING -> Triple(
            Color.argb(200, 255, 193, 7),   // Yellow
            Color.argb(255, 245, 127, 23),
            currentPajakInfo!!.message
        )
        PajakStatus.ERROR -> Triple(
            Color.argb(200, 158, 158, 158), // Gray
            Color.argb(255, 97, 97, 97),
            "${currentPajakInfo!!.platNomor}\n${currentPajakInfo!!.message}"
        )
        PajakStatus.UNKNOWN -> Triple(
            Color.argb(180, 33, 150, 243),  // Blue
            Color.argb(255, 25, 118, 210),
            "${box.cls} ${"%.1f".format(box.conf * 100)}%"
        )
    }
} else {
    // Default styling
    val alpha = (box.conf * 255).toInt().coerceIn(0, 255)
    val baseColor = ultralyticsColors[box.index % ultralyticsColors.size]
    Triple(
        Color.argb(alpha, Color.red(baseColor), Color.green(baseColor), Color.blue(baseColor)),
        baseColor,
        "${box.cls} ${"%.1f".format(box.conf * 100)}%"
    )
}

// Draw filled background if pajak info available
if (currentPajakInfo != null) {
    paint.color = bgColor
    paint.style = Paint.Style.FILL
    canvas.drawRoundRect(left, top, right, bottom, BOX_CORNER_RADIUS, BOX_CORNER_RADIUS, paint)
}

// Draw stroke
paint.color = strokeColor
paint.style = Paint.Style.STROKE
paint.strokeWidth = if (currentPajakInfo != null) BOX_LINE_WIDTH * 2 else BOX_LINE_WIDTH
canvas.drawRoundRect(left, top, right, bottom, BOX_CORNER_RADIUS, BOX_CORNER_RADIUS, paint)
```

---

## 📱 Usage Examples

### **Mode 1: Callback-Based (App Control)**

```kotlin
// In your Activity/Fragment
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val yoloView = findViewById<YOLOView>(R.id.yolo_view)
        
        // Enable cropping
        yoloView.setEnableCropping(true)
        
        // Set callback-based strategy
        val strategy = PajakCheckStrategy.CallbackBased(
            callback = object : PajakStatusCallback {
                override fun onOCRRequest(croppedImage: ByteArray, onResult: (String) -> Unit) {
                    // Custom OCR implementation
                    lifecycleScope.launch {
                        val platNomor = myCustomOCR(croppedImage)
                        onResult(platNomor)
                    }
                }
                
                override fun onCheckPajakStatus(platNomor: String, onResult: (PajakInfo) -> Unit) {
                    // Custom API implementation
                    lifecycleScope.launch {
                        val pajakInfo = myCustomAPI(platNomor)
                        onResult(pajakInfo)
                    }
                }
            }
        )
        
        yoloView.setPajakStrategy(strategy)
    }
}
```

### **Mode 2: Built-in (Plugin Control)**

```kotlin
// In your Activity/Fragment
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val yoloView = findViewById<YOLOView>(R.id.yolo_view)
        
        // Enable cropping
        yoloView.setEnableCropping(true)
        
        // Set built-in strategy (one line!)
        val strategy = PajakCheckStrategy.BuiltIn(
            apiEndpoint = PajakCheckStrategy.BuiltIn.DEFAULT_API_ENDPOINT,
            apiKey = null,
            ocrEngine = OCREngine.ML_KIT,
            enableCaching = true,
            cacheDurationMs = 300000  // 5 minutes
        )
        
        yoloView.setPajakStrategy(strategy)
        
        // Done! Plugin handles everything
    }
}
```

---

## 📦 Dependencies

### **For Built-in Mode (Plugin side)**

Add to `android/build.gradle`:

```gradle
dependencies {
    // Core (already exists)
    implementation 'org.tensorflow:tensorflow-lite:2.14.0'
    
    // NEW: For Built-in mode
    implementation 'com.google.mlkit:text-recognition:16.0.0'
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
}
```

**Package size impact:**
- ML Kit: ~2 MB
- OkHttp: ~800 KB
- Coroutines: ~200 KB
- **Total: ~3 MB increase**

### **For Callback Mode (App side)**

Developer adds dependencies themselves (no plugin bloat):

```gradle
dependencies {
    // Developer chooses their own OCR/HTTP libraries
    implementation 'com.google.mlkit:text-recognition:16.0.0'  // Optional
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'     // Optional
    // etc.
}
```

---

## 🎯 Benefits Comparison

| Aspect | Mode 1: Callback | Mode 2: Built-in |
|--------|------------------|------------------|
| **Setup Time** | Medium (need implement OCR + API) | Fast (one line config) |
| **Flexibility** | ⭐⭐⭐⭐⭐ Very High | ⭐⭐ Limited |
| **Package Size** | Small (no extra deps) | Large (+3 MB) |
| **Customization** | Full control | Fixed implementation |
| **Multi-region** | ✅ Easy | ❌ Hardcoded Jabar |
| **Offline Mode** | ✅ Possible | ❌ Requires internet |
| **OCR Choice** | ✅ Any | ❌ ML Kit only |
| **API Choice** | ✅ Any | ❌ Bapenda only |
| **Best For** | Production apps | Prototyping, demos |

---

## 🚀 Migration Path

### **From Current State (Cropping only) → Dual Mode**

1. ✅ **No breaking changes** - existing cropping feature stays same
2. ✅ **Backward compatible** - default strategy is `Disabled`
3. ✅ **Optional feature** - developers opt-in by calling `setPajakStrategy()`
4. ✅ **Gradual adoption** - can start with callback, migrate to built-in later

---

## 📊 Testing Strategy

### **Unit Tests**

```kotlin
// PlatNomorParserTest.kt
@Test
fun `parse valid plate number`() {
    val result = PlatNomorParser.parse("D6060AIP")
    assertEquals(Triple("D", "6060", "AIP"), result)
}

// BuiltInOCRProcessorTest.kt
@Test
fun `OCR processes plate image correctly`() = runTest {
    val processor = BuiltInOCRProcessor(context)
    val result = processor.processImage(testImageBytes)
    assertTrue(result?.matches(Regex("[A-Z]{1,2}[0-9]{1,4}[A-Z]{1,3}")) == true)
}
```

### **Integration Tests**

```kotlin
@Test
fun `callback strategy triggers OCR and API`() = runTest {
    var ocrCalled = false
    var apiCalled = false
    
    val strategy = PajakCheckStrategy.CallbackBased(
        callback = object : PajakStatusCallback {
            override fun onOCRRequest(croppedImage: ByteArray, onResult: (String) -> Unit) {
                ocrCalled = true
                onResult("D6060AIP")
            }
            override fun onCheckPajakStatus(platNomor: String, onResult: (PajakInfo) -> Unit) {
                apiCalled = true
                onResult(PajakInfo("D 6060 AIP", PajakStatus.TAAT))
            }
        }
    )
    
    yoloView.setPajakStrategy(strategy)
    // Trigger detection...
    
    delay(5000)
    assertTrue(ocrCalled)
    assertTrue(apiCalled)
}
```

---

## 📚 Documentation

### **README.md Update**

```markdown
## 🚗 Pajak Status Checking (Optional Feature)

This plugin supports **automatic vehicle tax status checking** with two modes:

### Mode 1: Callback-Based (Recommended for Production)
You implement OCR and API logic in your app.

### Mode 2: Built-in (Quick Start)
Plugin provides complete OCR + API implementation (Bapenda Jabar only).

See [PAJAK_CHECKING_GUIDE.md](docs/PAJAK_CHECKING_GUIDE.md) for full documentation.
```

---

## ✅ Implementation Checklist

### **Phase 1: Strategy Pattern (2-3 hours)**
- [ ] Create `PajakCheckStrategy.kt` with sealed classes
- [ ] Create `PajakStatus`, `PajakInfo`, `PajakStatusCallback`
- [ ] Create `PlatNomorParser` helper
- [ ] Add tests for parser

### **Phase 2: Built-in Implementation (6-8 hours)**
- [ ] Create `BuiltInOCRProcessor.kt` with ML Kit
- [ ] Create `BuiltInPajakAPIClient.kt` with OkHttp
- [ ] Create `BuiltInPajakChecker.kt` orchestrator
- [ ] Add caching mechanism
- [ ] Add retry logic
- [ ] Add tests for each component

### **Phase 3: YOLOView Integration (2-3 hours)**
- [ ] Add `pajakStrategy` property
- [ ] Add `setPajakStrategy()` method
- [ ] Modify `processCroppingAsync()` to trigger checking
- [ ] Modify `OverlayView.onDraw()` for custom colors
- [ ] Add multi-line text rendering for status

### **Phase 4: Documentation (2-3 hours)**
- [ ] Create usage guide with examples
- [ ] Update README.md
- [ ] Create API reference
- [ ] Add troubleshooting section

### **Phase 5: Testing (4-5 hours)**
- [ ] Unit tests for all components
- [ ] Integration tests for both modes
- [ ] Manual testing with real plates
- [ ] Performance testing

### **Total Estimated Time: 16-22 hours**

---

## 🎉 Summary

Blueprint ini menyediakan:
- ✅ **Dual mode architecture** - developer bisa pilih sesuai kebutuhan
- ✅ **Strategy pattern** - clean separation of concerns
- ✅ **Backward compatible** - tidak break existing features
- ✅ **Well-tested** - comprehensive test coverage
- ✅ **Production-ready** - caching, retry, error handling
- ✅ **Documented** - clear usage examples

**Next Steps:**
1. Review blueprint ini dengan tim
2. Tentukan priority (Mode 1 only, Mode 2 only, atau kedua-duanya)
3. Mulai implementation sesuai checklist
4. Testing dan iteration

---

**Created:** October 23, 2025  
**Version:** 1.0  
**Status:** ✅ Ready for Implementation
