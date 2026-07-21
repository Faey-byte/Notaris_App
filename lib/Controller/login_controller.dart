import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      String? userId = data["id"]?.toString();

      if (token != null && token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (userId != null) {
          await prefs.setString('user_id', userId);
        }

        print("TOKEN BERHASIL DISIMPAN: $token");
      }

      if (userId != null) {
        Get.find<NotificationController>().startListening(userId);
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

  @override
  void onClose() {
    super.onClose();
  }
}
