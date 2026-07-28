// // splash_controller.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:notaris_app/config/base_url.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:notaris_app/Controller/Notification_Controller.dart';
// import 'package:notaris_app/data/services/foreground_task_handler.dart'; // ← tambah import ini
// import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // ← tambah import ini
// import '../Routes/routes.dart';

// class SplashController extends GetxController {
//   static const String baseUrl = "${ApiConfig.baseUrl}";
//   static const String _checkAuthEndpoint = '/api/v1/checkAuth/token';

//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.delayed(const Duration(milliseconds: 1000));
//       await checkAuth();
//     });
//   }

//   Future<void> checkAuth() async {
//     try {
//       final token = await _getSavedToken();

//       if (token == null || token.isEmpty) {
//         _goToLogin();
//         return;
//       }

//       final isValid = await _verifyToken(token);

//       if (isValid) {
//         await _startNotificationListening();
//         await _startForegroundService(); // ← tambah ini
//         _goToHome();
//       } else {
//         _goToLogin();
//       }
//     } catch (e) {
//       _goToLogin();
//     }
//   }

//   Future<bool> _verifyToken(String token) async {
//     try {
//       final uri = Uri.parse('$baseUrl$_checkAuthEndpoint');

//       final response = await http.post(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({'token': token}),
//       ).timeout(const Duration(seconds: 5));

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body) as Map<String, dynamic>;
//         final dynamic valid = body['authenticated'] ?? body['message'] == "authenticated";
//         if (valid is bool) return valid;
//         if (valid is String) return valid.toLowerCase() == 'true';
//       }

//       return false;
//     } catch (e) {
//       // Timeout atau tidak ada koneksi → langsung ke login
//       return false;
//     }
//   }

//   // ─── Notifikasi WS (dalam app) ────────────────────────────────────────────────

//   Future<void> _startNotificationListening() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('user_id');

//     if (userId != null && userId.isNotEmpty) {
//       Get.find<NotificationController>().startListening(userId);
//     }
//   }

//   // ✅ Tambahan: Notifikasi background (Foreground Service)
//   Future<void> _startForegroundService() async {
//     print("🟡 [Splash] _startForegroundService() dipanggil");

//     try {
//       final NotificationPermission notificationPermission =
//           await FlutterForegroundTask.checkNotificationPermission();
//       print("🟡 [Splash] Status izin notifikasi: $notificationPermission");

//       if (notificationPermission != NotificationPermission.granted) {
//         print("🟡 [Splash] Meminta izin notifikasi...");
//         await FlutterForegroundTask.requestNotificationPermission();
//       }

//       print("🟡 [Splash] Memanggil FlutterForegroundTask.startService()...");

//       final result = await FlutterForegroundTask.startService(
//         notificationTitle: 'Notaris App',
//         notificationText: 'Menjaga notifikasi tetap aktif',
//         callback: startForegroundTaskCallback,
//       );

//       print("✅ [Splash] startService() selesai, result: $result");
//     } catch (e) {
//       print("❌ [Splash] ERROR saat startForegroundService: $e");
//     }
//   }

//   Future<String?> _getSavedToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }

//   void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

//   void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
// }
// splash_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notaris_app/Controller/Notification_Controller.dart';
import 'package:notaris_app/data/services/foreground_task_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../Routes/routes.dart';

class SplashController extends GetxController {
  static const String baseUrl = "${ApiConfig.baseUrl}";
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
      return false;
    }
  }

  // ─── Notifikasi WS (dalam app) ────────────────────────────────────────────────

  Future<void> _startNotificationListening() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    print("🟣 [Splash] _startNotificationListening() dipanggil, userId dari prefs: $userId");

    if (userId != null && userId.isNotEmpty) {
      print("🟣 [Splash] Memanggil NotificationController.startListening($userId)");
      Get.find<NotificationController>().startListening(userId);
    } else {
      print("⚠️ [Splash] userId NULL/kosong — startListening() TIDAK dipanggil!");
    }
  }

  // ✅ Tambahan: Notifikasi background (Foreground Service)
  Future<void> _startForegroundService() async {
    print("🟡 [Splash] _startForegroundService() dipanggil");

    try {
      final NotificationPermission notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      print("🟡 [Splash] Status izin notifikasi: $notificationPermission");

      if (notificationPermission != NotificationPermission.granted) {
        print("🟡 [Splash] Meminta izin notifikasi...");
        await FlutterForegroundTask.requestNotificationPermission();
      }

      print("🟡 [Splash] Memanggil FlutterForegroundTask.startService()...");

      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'Notaris App',
        notificationText: 'Menjaga notifikasi tetap aktif',
        callback: startForegroundTaskCallback,
      );

      print("✅ [Splash] startService() selesai, result: $result");
    } catch (e) {
      print("❌ [Splash] ERROR saat startForegroundService: $e");
    }
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

  void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
}