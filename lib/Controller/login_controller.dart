import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routes/routes.dart';
import 'package:notaris_app/utils/logger.dart';

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

    if (email.isEmpty) {
      emailError.value = "Email wajib diisi";
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = "Format email tidak valid";
      isValid = false;
    }

    if (pass.isEmpty) {
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
        AppLogger.log(
          "⚠️ [Login] Token bukan format JWT valid (bagian: ${parts.length})",
        );
        return null;
      }

      String payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      AppLogger.log("🔓 [Login] JWT payload berhasil di-decode: $map");
      return map;
    } catch (e) {
      AppLogger.log("❌ [Login] Gagal decode JWT payload: $e");
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

      AppLogger.log("DATA LOGIN: $data");

      String? token = data["token"];
      String? teamKey = data["teamkey"];
      String? userId = data["id"]?.toString() ?? data["user_id"]?.toString();

      if (userId == null && token != null && token.isNotEmpty) {
        final payload = _decodeJwtPayload(token);
        if (payload != null && payload["userID"] != null) {
          userId = payload["userID"].toString();
        }
      }

      AppLogger.log("USER ID FINAL: $userId");
      AppLogger.log("TEAM KEY FINAL: $teamKey");

      if (token != null && token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (userId != null) {
          await prefs.setString('user_id', userId);
        }

        if (teamKey != null && teamKey.isNotEmpty) {
          await prefs.setString('teamkey', teamKey);
          AppLogger.log("TEAMKEY BERHASIL DISIMPAN: $teamKey");
        }

        AppLogger.log("TOKEN BERHASIL DISIMPAN: $token");
      }

      Get.snackbar("Success", data["message"] ?? "Login berhasil");
      Get.offAllNamed(AppRoutes.homepage);
    } catch (e) {
      AppLogger.log("ERROR LOGIN: $e");
      Get.snackbar("!!!!", e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }
}
