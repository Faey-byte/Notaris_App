import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../Routes/routes.dart';
import 'package:notaris_app/utils/logger.dart';

class SplashController extends GetxController {
  static const String baseUrl = ApiConfig.baseUrl;
  static const String _checkAuthEndpoint = '/api/v1/checkAuth/token';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
        await _startForegroundService();
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
      final uri = Uri.parse('$baseUrl$_checkAuthEndpoint');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic valid =
            body['authenticated'] ?? body['message'] == "authenticated";
        if (valid is bool) return valid;
        if (valid is String) return valid.toLowerCase() == 'true';
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _startNotificationListening() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    AppLogger.log(
      "🟣 [Splash] _startNotificationListening() dipanggil, userId dari prefs: $userId",
    );

    if (userId != null && userId.isNotEmpty) {
      AppLogger.log(
        "🟣 [Splash] userId ditemukan, notifikasi background akan dijalankan jika diperlukan",
      );
    } else {
      AppLogger.log(
        "⚠️ [Splash] userId NULL/kosong — tidak ada listener notifikasi yang dipanggil",
      );
    }
  }

  Future<void> _startForegroundService() async {
    AppLogger.log("🟡 [Splash] _startForegroundService() dipanggil");

    try {
      final NotificationPermission notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      AppLogger.log(
        "🟡 [Splash] Status izin notifikasi: $notificationPermission",
      );

      if (notificationPermission != NotificationPermission.granted) {
        AppLogger.log("🟡 [Splash] Meminta izin notifikasi...");
        await FlutterForegroundTask.requestNotificationPermission();
      }

      AppLogger.log(
        "🟡 [Splash] Memanggil FlutterForegroundTask.startService()...",
      );
    } catch (e) {
      AppLogger.log("❌ [Splash] ERROR saat startForegroundService: $e");
    }
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

  void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
}
