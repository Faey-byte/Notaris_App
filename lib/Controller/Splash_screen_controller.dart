import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Sesuaikan import routes kamu
import '../Routes/routes.dart';

class SplashController extends GetxController {
  static const String _baseUrl = 'https://ought-drug-includes-yen.trycloudflare.com';
  static const String _checkAuthEndpoint = '/api/v1/checkAuth/token';

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Jalankan cek auth setelah frame pertama selesai render
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Beri jeda minimal agar splash animation sempat tampil
      await Future.delayed(const Duration(milliseconds: 1000));
      await checkAuth();
    });
  }

  // ─── Public ──────────────────────────────────────────────────────────────────

  /// Ambil token tersimpan → validasi ke API → navigate sesuai hasil.
  Future<void> checkAuth() async {
    try {
      final token = await _getSavedToken();

      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      final isValid = await _verifyToken(token);
      isValid ? _goToHome() : _goToLogin();
    } catch (e) {
      _goToLogin();
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────────

  /// POST /api/v1/checkAuth/token — kirim token, cek response valid/tidak.
  Future<bool> _verifyToken(String token) async {
    final uri = Uri.parse('$_baseUrl$_checkAuthEndpoint');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'token': token}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      Get.snackbar('Debugging', 'Response API: $body');

      // ⚠️  Sesuaikan key ini dengan response API kamu.
      // Contoh: { "valid": true } atau { "success": true } atau { "status": "valid" }
      final dynamic valid = body['valid'] ?? body['success'];
      if (valid is bool) return valid;
      if (valid is String) return valid.toLowerCase() == 'true';
    }

    return false;
  }

  /// Ambil token yang sudah disimpan saat login sebelumnya.
  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Navigasi ke Home — hapus semua route sebelumnya (tidak bisa back ke splash).
  void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

  /// Navigasi ke Login — hapus semua route sebelumnya.
  void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
}