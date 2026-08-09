import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import '../Routes/routes.dart';

class ForgotPasswordController extends GetxController {
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString emailError = RxnString();

  void setEmail(String value) => email.value = value;

  Future<void> submitEmail() async {
    emailError.value = null;

    final trimmed = email.value.trim();
    if (trimmed.isEmpty) {
      emailError.value = "Email wajib diisi";
      return;
    }
    if (!GetUtils.isEmail(trimmed)) {
      emailError.value = "Format email tidak valid";
      return;
    }

    try {
      isLoading.value = true;

      final res = await AuthService.requestResetPassword(email: trimmed);

      Get.snackbar(
        "Terkirim",
        res["message"] ?? "Kode reset dikirim ke email Anda",
        backgroundColor: const Color(0xFFF0FDF4),
        colorText: const Color(0xFF15803D),
      );

      Get.toNamed(
        AppRoutes.otppage,
        arguments: {'email': trimmed, 'isForgotPassword': true},
      );
    } catch (e) {
      Get.snackbar(
        "Gagal",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF913632),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
