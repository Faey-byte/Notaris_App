import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import '../Routes/routes.dart';

class ResetPasswordController extends GetxController {
  final RxString code = ''.obs;
  final RxString newPassword = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  String email = '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      email = args['email'] ?? '';
    }
  }

  void setCode(String value) => code.value = value;
  void setNewPassword(String value) => newPassword.value = value;
  void setConfirmPassword(String value) => confirmPassword.value = value;
  void toggleObscureNew() => obscureNew.value = !obscureNew.value;
  void toggleObscureConfirm() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> submitReset() async {
    if (code.value.trim().length != 5) {
      Get.snackbar(
        "Peringatan",
        "Kode reset harus 5 digit",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (newPassword.value.trim().length < 8) {
      Get.snackbar(
        "Peringatan",
        "Password minimal 8 karakter",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (newPassword.value.trim() != confirmPassword.value.trim()) {
      Get.snackbar(
        "Peringatan",
        "Konfirmasi password tidak cocok",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Email tidak ditemukan, silakan ulangi dari awal",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final res = await AuthService.resetPassword(
        email: email,
        code: code.value.trim(),
        newPassword: newPassword.value.trim(),
      );

      Get.snackbar(
        "Berhasil",
        res["message"] ?? "Password berhasil direset",
        backgroundColor: const Color(0xFFF0FDF4),
        colorText: const Color(0xFF15803D),
      );

      Get.offAllNamed(AppRoutes.loginpage);
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