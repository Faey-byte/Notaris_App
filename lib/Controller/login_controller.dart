// login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';
import 'package:notaris_app/data/services/foreground_task_handler.dart'; // ← tambah import ini
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // ← tambah import ini
import '../Routes/routes.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var obscure = true.obs;
  var emailError = RxnString();
  var passwordError = RxnString();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  void togglePassword() => obscure.value = !obscure.value;

  Future<void> login() async {
    emailError.value = null;
    passwordError.value = null;

    if (emailC.text.trim().isEmpty) {
      emailError.value = "Email wajib diisi";
      return;
    }
    if (!GetUtils.isEmail(emailC.text.trim())) {
      emailError.value = "Format email tidak valid";
      return;
    }
    if (passC.text.trim().isEmpty) {
      passwordError.value = "Password wajib diisi";
      return;
    }
    if (passC.text.trim().length < 8) {
      passwordError.value = "Password minimal 8 karakter";
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
      String? userId = data["id"]?.toString();

      if (token != null && token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (userId != null) {
          await prefs.setString('user_id', userId);
        }

        print("TOKEN BERHASIL DISIMPAN: $token");
      }

      // Mulai listening notif WS untuk saat app aktif (sudah ada)
      if (userId != null) {
        Get.find<NotificationController>().startListening(userId);

        // ✅ Nyalakan Foreground Service untuk notif saat app di background/closed
        await _startForegroundService();
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

  // ✅ Fungsi baru: nyalakan Foreground Service
  Future<void> _startForegroundService() async {
    // Minta izin notifikasi dulu (Android 13+)
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