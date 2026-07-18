// splash_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notaris_app/Controller/Notification_Controller.dart';
import '../Routes/routes.dart';

class SplashController extends GetxController {
  static const String baseUrl = "${ApiConfig.baseUrl}";
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

  Future<void> checkAuth() async {
    try {
      final token = await _getSavedToken();

      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      final isValid = await _verifyToken(token);

      if (isValid) {
        await _startNotificationListening();
        _goToHome();
      } else {
        _goToLogin();
      }
    } catch (e) {
      _goToLogin();
    }
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final uri = Uri.parse('$baseUrl$_checkAuthEndpoint'); // ✅ sudah diperbaiki (baseUrl, bukan _baseUrl)

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'token': token}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic valid = body['authenticated'] ?? body['message'] == "authenticated";
        if (valid is bool) return valid;
        if (valid is String) return valid.toLowerCase() == 'true';
      }

      return false;
    } catch (e) {
      // Timeout atau tidak ada koneksi → langsung ke login
      return false;
    }
  }

  // ─── Notifikasi WS ───────────────────────────────────────────────────────────

  Future<void> _startNotificationListening() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      Get.find<NotificationController>().startListening(userId);
    }
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

  void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
}