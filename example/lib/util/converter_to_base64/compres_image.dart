import 'dart:typed_data';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';

// Class to store compression result info
class CompressionResult {
  final bool isValid;
  final bool isCompressed;
  final int originalSize;
  final int finalSize;
  final String? errorMessage;

  CompressionResult({
    required this.isValid,
    required this.isCompressed,
    required this.originalSize,
    required this.finalSize,
    this.errorMessage,
  });
}

// Global variable to store the last compression result
CompressionResult? lastCompressionResult;

// Compress image file and return XFile if file size is under compression target
// Future<XFile> compressImage({
//   //TESTING PURPOSE
//   // int targetFileSize = 15 * 1024,
//   //PROD PURPOSE
//   int targetFileSize = 300 * 1024,
//   required XFile pickedFile,
//   int compressionQuality = 90,
//   required String? noPolisi1,
//   required String? noPolisi2,
//   required String? noPolisi3,
//   required String? compressFrom,
// }) async {
//   File file = File(pickedFile.path);
//   XFile? compressedXFile;
//   bool isCompressed = false;
//   bool isValid = true;
//   String? errorMessage;

//   int originalFileSize = await file.length();
//   int finalFileSize = originalFileSize;

//   // Check if original file size is under target size
//   if (originalFileSize <= targetFileSize) {
//     // Store result info
//     lastCompressionResult = CompressionResult(
//       isValid: true,
//       isCompressed: false,
//       originalSize: originalFileSize,
//       finalSize: originalFileSize,
//       errorMessage: null,
//     );
//     return pickedFile;
//   }

//   Uint8List? compressedBytes;

//   try {
//     // Read image file
//     Uint8List originalFileBytes = Uint8List.fromList(await file.readAsBytes());

//     // Make a backup of original file data
//     File backupFile = File('${file.path}.backup');
//     await backupFile.writeAsBytes(originalFileBytes);

//     while (originalFileSize > targetFileSize && compressionQuality > 0) {
//       // Compress image data
//       compressedBytes = await FlutterImageCompress.compressWithList(
//         originalFileBytes,
//         quality: compressionQuality,
//       );
//       compressionQuality -= 10;

//       // Check if compressed size is within target size
//       if (compressedBytes.length <= targetFileSize) {
//         break;
//       }
//     }

//     if (compressedBytes != null && compressedBytes.isNotEmpty) {
//       // Validate image data before saving
//       isValid = await _validateImageData(compressedBytes);

//       if (isValid) {
//         // Write compressed data to the original file
//         await file.writeAsBytes(compressedBytes);
//         compressedXFile = XFile(file.path);
//         isCompressed = true;
//         finalFileSize = compressedBytes.length;

//         // Remove backup since compression was successful
//         if (await backupFile.exists()) {
//           await backupFile.delete();
//         }
//       } else {
//         // Restore from backup
//         if (await backupFile.exists()) {
//           Uint8List backupBytes = await backupFile.readAsBytes();
//           await file.writeAsBytes(backupBytes);
//           await backupFile.delete();
//         }
//         errorMessage = "Compressed image validation failed";
//         compressedXFile = pickedFile;
//       }
//     } else {
//       // Delete backup if it exists
//       if (await backupFile.exists()) {
//         await backupFile.delete();
//       }
//       compressedXFile = pickedFile;
//       errorMessage = "Compression produced empty data";
//     }

//     // Log compression result
//     await ApiService.sendLog(
//       logString:
//           "Image compression: original=$originalFileSize, compressed=$finalFileSize, isCompressed=$isCompressed, isValid=$isValid",
//       isAvailableNoPol: true,
//       noPolisi1: noPolisi1,
//       noPolisi2: noPolisi2,
//       noPolisi3: noPolisi3,
//       processName: "Compress Image - $compressFrom",
//     ).timeout(const Duration(seconds: 30));

//     // Store result info
//     lastCompressionResult = CompressionResult(
//       isValid: isValid,
//       isCompressed: isCompressed,
//       originalSize: originalFileSize,
//       finalSize: finalFileSize,
//       errorMessage: errorMessage,
//     );

//     return compressedXFile;
//   } catch (e) {
//     await ApiService.sendLog(
//       logString: e.toString(),
//       isAvailableNoPol: true,
//       noPolisi1: noPolisi1,
//       noPolisi2: noPolisi2,
//       noPolisi3: noPolisi3,
//       processName: "Compress Image - $compressFrom",
//     ).timeout(const Duration(seconds: 30));

//     // Try to restore from backup if it exists
//     File backupFile = File('${file.path}.backup');
//     if (await backupFile.exists()) {
//       try {
//         Uint8List backupBytes = await backupFile.readAsBytes();
//         await file.writeAsBytes(backupBytes);
//         await backupFile.delete();
//       } catch (restoreError) {
//         // Failed to restore, log it
//         await ApiService.sendLog(
//           logString: "Failed to restore from backup: $restoreError",
//           isAvailableNoPol: true,
//           noPolisi1: noPolisi1,
//           noPolisi2: noPolisi2,
//           noPolisi3: noPolisi3,
//           processName: "Compress Image Restore - $compressFrom",
//         ).timeout(const Duration(seconds: 30));
//       }
//     }

//     // Store result info
//     lastCompressionResult = CompressionResult(
//       isValid: false,
//       isCompressed: false,
//       originalSize: originalFileSize,
//       finalSize: originalFileSize,
//       errorMessage: e.toString(),
//     );

//     return pickedFile;
//   }
// }

// Check if the last compression was successful
bool wasLastCompressionSuccessful() {
  return lastCompressionResult?.isValid == true && lastCompressionResult?.errorMessage == null;
}

// Function to validate image data
// Future<bool> _validateImageData(Uint8List imageData) async {
//   try {
//     // Method 1: Try encoding to base64 and decoding back
//     String base64String = base64Encode(imageData);
//     Uint8List decodedData = base64Decode(base64String);

//     // Check if decoded data matches original data
//     if (decodedData.length != imageData.length) {
//       return false;
//     }

//     // Method 2: Additional validation - check image headers
//     // JPEG starts with FF D8
//     if (imageData.length >= 2) {
//       if ((imageData[0] == 0xFF && imageData[1] == 0xD8)) {
//         // It's a JPEG, check for proper JPEG end marker (FF D9)
//         if (imageData.length >= 2 &&
//             imageData[imageData.length - 2] == 0xFF &&
//             imageData[imageData.length - 1] == 0xD9) {
//           return true;
//         }
//       }

//       // PNG starts with 89 50 4E 47
//       if (imageData.length >= 8 &&
//           imageData[0] == 0x89 &&
//           imageData[1] == 0x50 &&
//           imageData[2] == 0x4E &&
//           imageData[3] == 0x47) {
//         return true;
//       }
//     }

//     // If we couldn't verify with specific format checks,
//     // trust the base64 encoding/decoding success
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

// Check if a base64 string is valid before sending to server
bool isValidBase64Image(String base64String) {
  try {
    // Check if the string can be decoded
    Uint8List decoded = base64Decode(base64String);

    // Check minimum length for any valid image
    if (decoded.length < 10) return false;

    // Check if it has valid image headers
    if (decoded.length >= 2) {
      // JPEG check
      if (decoded[0] == 0xFF && decoded[1] == 0xD8) {
        return true;
      }

      // PNG check
      if (decoded.length >= 8 &&
          decoded[0] == 0x89 &&
          decoded[1] == 0x50 &&
          decoded[2] == 0x4E &&
          decoded[3] == 0x47) {
        return true;
      }
    }

    // Unknown format or invalid image data
    return false;
  } catch (e) {
    return false;
  }
}
