import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class SignupController extends GetxController {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final companyC = TextEditingController();

  final service = AuthService();

  void signup() async {
    final result = await service.signup(
      name: nameC.text,
      email: emailC.text,
      password: passwordC.text,
      company: companyC.text,
    );

    if (result) {
      Get.snackbar("Sukses", "Akun berhasil dibuat");
    } else {
      Get.snackbar("Error", "Gagal daftar");
    }
  }
}