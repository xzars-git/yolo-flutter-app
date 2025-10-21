// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

package com.ultralytics.yolo.utils

import android.graphics.Bitmap
import android.graphics.RectF
import android.util.Log
import java.io.ByteArrayOutputStream

/**
 * Utility class untuk cropping detected objects dari camera frames
 * Optimized untuk license plate detection dan OCR processing
 */
object ImageCropper {
    private const val TAG = "ImageCropper"
    
    /**
     * Crop bounding box area dari original bitmap
     * 
     * @param originalBitmap Source bitmap (camera frame)
     * @param boundingBox Detection bounding box (normalized atau pixel coordinates)
     * @param padding Padding percentage around box (0.0-1.0), default 0.1 = 10%
     * @param useNormalizedCoords True jika boundingBox menggunakan normalized coords (0-1)
     * @return Cropped bitmap atau null jika crop gagal
     */
    fun cropBoundingBox(
        originalBitmap: Bitmap,
        boundingBox: RectF,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false
    ): Bitmap? {
        return try {
            // Convert normalized coords to pixels jika perlu
            val pixelBox = if (useNormalizedCoords) {
                RectF(
                    boundingBox.left * originalBitmap.width,
                    boundingBox.top * originalBitmap.height,
                    boundingBox.right * originalBitmap.width,
                    boundingBox.bottom * originalBitmap.height
                )
            } else {
                boundingBox
            }
            
            // Calculate padded box
            val boxWidth = pixelBox.width()
            val boxHeight = pixelBox.height()
            val paddingX = boxWidth * padding
            val paddingY = boxHeight * padding
            
            // Calculate crop coordinates dengan boundary checking
            val cropLeft = (pixelBox.left - paddingX).coerceAtLeast(0f).toInt()
            val cropTop = (pixelBox.top - paddingY).coerceAtLeast(0f).toInt()
            val cropRight = (pixelBox.right + paddingX)
                .coerceAtMost(originalBitmap.width.toFloat()).toInt()
            val cropBottom = (pixelBox.bottom + paddingY)
                .coerceAtMost(originalBitmap.height.toFloat()).toInt()
            
            val cropWidth = cropRight - cropLeft
            val cropHeight = cropBottom - cropTop
            
            // Validate minimum crop size (untuk avoid tiny crops)
            if (cropWidth < 20 || cropHeight < 10) {
                Log.w(TAG, "Crop size too small: ${cropWidth}x${cropHeight}")
                return null
            }
            
            // Perform actual crop
            val croppedBitmap = Bitmap.createBitmap(
                originalBitmap,
                cropLeft, cropTop,
                cropWidth, cropHeight
            )
            
            Log.d(TAG, "Successfully cropped: ${cropWidth}x${cropHeight} from ${originalBitmap.width}x${originalBitmap.height}")
            croppedBitmap
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to crop bounding box", e)
            null
        }
    }
    
    /**
     * Crop multiple bounding boxes dari single frame
     * Efficient untuk multi-object detection
     */
    fun cropMultipleBoundingBoxes(
        originalBitmap: Bitmap,
        boundingBoxes: List<RectF>,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false
    ): List<Bitmap> {
        return boundingBoxes.mapNotNull { box ->
            cropBoundingBox(originalBitmap, box, padding, useNormalizedCoords)
        }
    }
    
    /**
     * Convert cropped bitmap to byte array untuk transfer ke Flutter
     * 
     * @param bitmap Cropped bitmap
     * @param quality JPEG quality (0-100), default 90 untuk balance size vs quality
     * @return ByteArray dalam format JPEG
     */
    fun bitmapToByteArray(bitmap: Bitmap, quality: Int = 90): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        return stream.toByteArray()
    }
    
    /**
     * Enhanced cropping dengan sharpening untuk better OCR results
     * Useful untuk license plates yang blur atau low quality
     */
    fun cropWithEnhancement(
        originalBitmap: Bitmap,
        boundingBox: RectF,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false,
        sharpen: Boolean = true
    ): Bitmap? {
        val croppedBitmap = cropBoundingBox(
            originalBitmap, 
            boundingBox, 
            padding, 
            useNormalizedCoords
        ) ?: return null
        
        return if (sharpen) {
            applySharpenFilter(croppedBitmap)
        } else {
            croppedBitmap
        }
    }
    
    /**
     * Apply sharpening filter untuk improve OCR accuracy
     */
    private fun applySharpenFilter(bitmap: Bitmap): Bitmap {
        // TODO: Implement sharpening jika diperlukan
        // For now, just return original
        return bitmap
    }
}
