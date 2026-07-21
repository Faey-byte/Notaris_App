import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/login_controller.dart';
import 'package:notaris_app/Routes/routes.dart';
import 'package:notaris_app/Widget/Button_Filds.dart';
import 'package:notaris_app/Widget/Text_Field_Widget.dart';
import '../utils/app_colors.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),

                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel, color: AppColors.primary),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Notaris & PPAT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Selamat Datang",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Silahkan masuk akun menejemen anda",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email/Username",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 8),

                Obx(
                  () => CustomTextField(
                    controller: controller.emailC,
                    hint: "Masukkan Email",
                    icon: Icons.mail_outline,
                    isPassword: false,
                    showToggle: false,
                    obscure: false,
                    onToggle: () {},
                    errorText: controller.emailError.value,
                  ),
                ),

                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 8),

                Obx(
                  () => TextFormField(
                    controller: controller.passC,
                    obscureText: controller.obscure.value,
                    decoration: InputDecoration(
                      hintText: "Masukkan Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: controller.togglePassword,
                        icon: Icon(
                          controller.obscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      errorText: controller.passwordError.value,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Obx(
                  () => PrimaryButton(
                    text: "Log In",
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.signuppage);
                  },
                  child: const Text("Belum punya akun? Daftar "),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}