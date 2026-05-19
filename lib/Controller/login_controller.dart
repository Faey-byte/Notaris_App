import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
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

      // ✅ static method, tidak perlu instance
      final data = await AuthService.login(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      print("DATA LOGIN: $data");

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
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}