import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';
import 'package:notaris_app/data/services/foreground_task_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../Routes/routes.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var obscure = true.obs;
  var emailError = RxnString();
  var passwordError = RxnString();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  void togglePassword() => obscure.value = !obscure.value;

  bool _validateFields() {
    emailError.value = null;
    passwordError.value = null;

    final email = emailC.text.trim();
    final pass = passC.text.trim();

    bool isValid = true;

    if (email.length < 1) {
      emailError.value = "Email wajib diisi";
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = "Format email tidak valid";
      isValid = false;
    }

    if (pass.length < 1) {
      passwordError.value = "Password wajib diisi";
      isValid = false;
    } else if (pass.length < 8) {
      passwordError.value = "Password minimal 8 karakter";
      isValid = false;
    }

    return isValid;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print(
          "⚠️ [Login] Token bukan format JWT valid (bagian: ${parts.length})",
        );
        return null;
      }

      String payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      print("🔓 [Login] JWT payload berhasil di-decode: $map");
      return map;
    } catch (e) {
      print("❌ [Login] Gagal decode JWT payload: $e");
      return null;
    }
  }

  Future<void> login() async {
    final isValid = _validateFields();
    if (!isValid) {
      return;
    }

    try {
      isLoading.value = true;

      final data = await AuthService.login(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      print("DATA LOGIN: $data");

      String? token = data["token"];
      String? teamKey = data["teamkey"];
      String? userId = data["id"]?.toString() ?? data["user_id"]?.toString();

      if (userId == null && token != null && token.isNotEmpty) {
        final payload = _decodeJwtPayload(token);
        if (payload != null && payload["userID"] != null) {
          userId = payload["userID"].toString();
        }
      }

      print("USER ID FINAL: $userId");
      print("TEAM KEY FINAL: $teamKey");

      if (token != null && token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (userId != null) {
          await prefs.setString('user_id', userId);
        }

        if (teamKey != null && teamKey.isNotEmpty) {
          await prefs.setString('teamkey', teamKey);
          print("TEAMKEY BERHASIL DISIMPAN: $teamKey");
        }

        print("TOKEN BERHASIL DISIMPAN: $token");
      }

      Get.snackbar("Success", data["message"] ?? "Login berhasil");
      Get.offAllNamed(AppRoutes.homepage);
    } catch (e) {
      print("ERROR LOGIN: $e");
      Get.snackbar("Error", e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startForegroundService() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Notaris App',
      notificationText: 'Menjaga notifikasi tetap aktif',
      callback: startForegroundTaskCallback,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
