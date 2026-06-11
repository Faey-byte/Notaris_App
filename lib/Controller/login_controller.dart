import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/data/services/auth_service.dart';
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

      if (token != null && token.isNotEmpty) {

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print("TOKEN BERHASIL DISIMPAN KE SHAREDPREFERENCES: $token");
      } else {
        print("PERINGATAN: Token tidak ditemukan dalam respons login backend.");
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
    // Biarkan GetX mengelola siklus hidup memori controller secara otomatis.
    // Menghapus manual dispose di sini mencegah error "used after being disposed".
    super.onClose();
  }

  Future<void> sesilogin(String email, String password) async {
    try {
      isLoading.value = true;
      
      // ... Logika hit API login kamu di sini ...
      // Misal respon API sukses dan mengembalikan data token:
      String tokenDariApi = "ini_contoh_token_jwt_12345"; 

      // KUNCI SESI: Simpan token ke SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', tokenDariApi);

      Get.snackbar("Sukses", "Selamat datang kembali!");
      
      // Tendang ke HomePage dan hapus history login
      Get.offAllNamed(AppRoutes.homepage);
      
    } catch (e) {
      Get.snackbar("Error", "Login gagal: $e");
    } finally {
      isLoading.value = false;
    }
  }
}