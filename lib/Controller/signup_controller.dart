import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Pages/Otp_Pages.dart';
import 'package:notaris_app/data/services/auth_service.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;

  var obscure = true.obs;

  final formKey = GlobalKey<FormState>();

  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final companyC = TextEditingController();

  void togglePassword() {
    obscure.value = !obscure.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username wajib diisi";
    }

    if (value.length < 4) {
      return "Username minimal 4 karakter";
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email wajib diisi";
    }

    if (!value.contains("@")) {
      return "Email harus menggunakan @";
    }

    if (!GetUtils.isEmail(value)) {
      return "Format email tidak valid";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password wajib diisi";
    }

    if (value.length < 8) {
      return "Password minimal 8 karakter";
    }

    return null;
  }

  String? validateCompany(String? value) {
    if (value == null || value.isEmpty) {
      return "Company Name wajib diisi";
    }

    return null;
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final userEmail = emailC.text.trim();

      final data = await AuthService.signup(
        username: usernameC.text.trim(),
        email: userEmail,
        password: passC.text.trim(),
        companyName: companyC.text.trim(),
      );

      Get.snackbar("Success", data["message"] ?? "Signup berhasil");

      Get.to(() => const OtpPages(), arguments: userEmail);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // usernameC.dispose();
    // emailC.dispose();
    // passC.dispose();
    // companyC.dispose();

    super.onClose();
  }
}
