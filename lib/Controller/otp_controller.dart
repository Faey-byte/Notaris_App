import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/login_controller.dart';
import 'package:notaris_app/Controller/signup_controller.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/Routes/routes.dart';
import 'package:notaris_app/data/services/auth_service.dart';

class OtpController extends GetxController {
  var isLoading = false.obs;
  String email = '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      email = Get.arguments as String;
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    if (otpCode.length < 4) {
      Get.snackbar("Peringatan", "Masukkan 4 digit kode OTP");
      return;
    }

    try {
      isLoading.value = true;

      final res = await AuthService.verifyOtp(email: email, otp: otpCode);

      Get.snackbar("Success", res["message"] ?? "Verifikasi berhasil!");
      Get.delete<SignupController>();
      Get.delete<LoginController>();
      Get.offAllNamed(AppRoutes.loginpage);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      final res = await AuthService.resendOtp(email: email);
      Get.snackbar("Success", res["message"] ?? "OTP berhasil dikirim ulang");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
