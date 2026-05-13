import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/signup_controller.dart';
import 'package:notaris_app/Widget/Text_Field_Widget.dart';
import 'package:notaris_app/utils/app_colors.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Text("Notaris & PPAT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            TextfieldsWidget(
              label: "Nama Lengkap",
              controller: controller.nameC,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              hint: "nama@email.com",
              icon: Icons.email,
              controller: controller.emailC,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              hint: "Password",
              icon: Icons.lock,
              isPassword: true,
              controller: controller.passwordC,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              hint: "Nama Perusahaan",
              icon: Icons.business,
              controller: controller.companyC,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: controller.signup,
              child: const Text("Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}