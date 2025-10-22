// Service untuk mengakses API Pajak Kendaraan
// https://atospamor-v2.bapenda.jabarprov.go.id/api/atos-pamor/v1/get-info-pajak

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'get_info_pajak_model.dart';

/// Response wrapper untuk API pajak - simplified
class PajakInfo {
  final bool success;
  final String code;
  final String message;
  final Data? data;  // Menggunakan Data dari GetInfoPajak model
  final String rawResponse;

  PajakInfo({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    required this.rawResponse,
  });

  factory PajakInfo.fromJson(Map<String, dynamic> json) {
    return PajakInfo(
      success: json['success'] ?? false,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      // ✅ HANDLE: API bisa return List atau Map di field 'data'
      data: (json['data'] != null && json['data'] is Map<String, dynamic>)
          ? Data.fromJson(json['data'])
          : null,
      rawResponse: jsonEncode(json),
    );
  }

  factory PajakInfo.error(String errorMessage, {String? rawResponse}) {
    return PajakInfo(
      success: false,
      code: 'ERROR',
      message: errorMessage,
      data: null,
      rawResponse: rawResponse ?? '',
    );
  }
}

/// Model untuk split nomor polisi Indonesia
class NomorPolisi {
  final String nomorPolisi1; // Kode wilayah: B, DK, AB
  final String nomorPolisi2; // Nomor kendaraan: 2156, 1234
  final String nomorPolisi3; // Seri plat: TOR, T8R, ABC
  final String kdPlat;       // Kode plat: default "1"

  NomorPolisi({
    required this.nomorPolisi1,
    required this.nomorPolisi2,
    required this.nomorPolisi3,
    this.kdPlat = "1",
  });

  /// Parse dari string plat nomor format: "B 2156 TOR"
  factory NomorPolisi.fromString(String platNomor) {
    // Remove extra spaces
    String cleaned = platNomor.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Split by space
    List<String> parts = cleaned.split(' ');
    
    if (parts.length != 3) {
      throw FormatException('Format plat nomor tidak valid: $platNomor (harus: HURUF ANGKA HURUF)');
    }

    return NomorPolisi(
      nomorPolisi1: parts[0], // B, DK, AB
      nomorPolisi2: parts[1], // 2156, 1234
      nomorPolisi3: parts[2], // TOR, T8R, ABC
    );
  }

  @override
  String toString() {
    return '$nomorPolisi1 $nomorPolisi2 $nomorPolisi3';
  }

  Map<String, dynamic> toJson() {
    return {
      'nomorPolisi1': nomorPolisi1,
      'nomorPolisi2': nomorPolisi2,
      'nomorPolisi3': nomorPolisi3,
      'kdPlat': kdPlat,
    };
  }
}

/// Service untuk mengakses API info pajak kendaraan
class PajakService {
  static const String baseUrl = 'https://atospamor-v2.bapenda.jabarprov.go.id';
  static const String endpoint = '/api/atos-pamor/v1/get-info-pajak';
  
  /// Get info pajak berdasarkan nomor polisi
  /// 
  /// [platNomor] format: "B 2156 TOR" atau "DK 6060 AIP"
  /// [bayarKedepan] default: "T" (tidak bayar ke depan)
  Future<PajakInfo> getInfoPajak({
    required String platNomor,
    String bayarKedepan = "T",
  }) async {
    try {
      debugPrint('🚗 API Request: Getting pajak info for $platNomor');
      
      // Parse nomor polisi
      NomorPolisi nomorPolisi = NomorPolisi.fromString(platNomor);
      debugPrint('   Split: ${nomorPolisi.nomorPolisi1} | ${nomorPolisi.nomorPolisi2} | ${nomorPolisi.nomorPolisi3}');

      // Build request body
      final Map<String, dynamic> requestBody = {
        "where": [
          ["objek_pajak_no_polisi1", "=", nomorPolisi.nomorPolisi1],
          ["objek_pajak_no_polisi2", "=", nomorPolisi.nomorPolisi2],
          ["objek_pajak_no_polisi3", "=", nomorPolisi.nomorPolisi3],
          ["objek_pajak_kd_plat", "=", nomorPolisi.kdPlat],
        ],
        "bayar_kedepan": bayarKedepan,
      };

      debugPrint('📤 Request Body:');
      debugPrint(jsonEncode(requestBody));

      // Make HTTP request
      final Uri url = Uri.parse('$baseUrl$endpoint');
      debugPrint('🌐 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout (>10 detik)');
        },
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final pajakInfo = PajakInfo.fromJson(jsonResponse);
        
        if (pajakInfo.success) {
          debugPrint('✅ API Success: ${pajakInfo.message}');
        } else {
          debugPrint('⚠️ API Response not success: ${pajakInfo.message}');
        }
        
        return pajakInfo;
      } else {
        // HTTP error
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        return PajakInfo.error(
          'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
          rawResponse: response.body,
        );
      }

    } on FormatException catch (e) {
      debugPrint('❌ Format Error: $e');
      return PajakInfo.error('Format plat nomor tidak valid: $e');
    } catch (e, stackTrace) {
      debugPrint('❌ API Error: $e');
      debugPrint('   Stack: $stackTrace');
      return PajakInfo.error('Error: $e');
    }
  }

  /// Get info pajak by components (untuk advanced usage)
  Future<PajakInfo> getInfoPajakByComponents({
    required String nomorPolisi1,
    required String nomorPolisi2,
    required String nomorPolisi3,
    String kdPlat = "1",
    String bayarKedepan = "T",
  }) async {
    final platNomor = '$nomorPolisi1 $nomorPolisi2 $nomorPolisi3';
    return getInfoPajak(platNomor: platNomor, bayarKedepan: bayarKedepan);
  }
}
