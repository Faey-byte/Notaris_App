import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Routes/routes.dart';
import 'package:notaris_app/Widget/Login/Login_Teks_Field.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/Widget/Login/Login_Logo.dart';
import 'package:notaris_app/Widget/Login/Login_Header.dart';
import 'package:notaris_app/Widget/Login/Login_Divider.dart';
import 'package:notaris_app/Widget/Login/Login_Footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const LoginLogo(),
              const SizedBox(height: 8),
              const LoginHeader(),
              const SizedBox(height: 24),
              _buildForm(),              // ini masih di page karena butuh setState
              const SizedBox(height: 40),
              const LoginDivider(),
              const SizedBox(height: 20),
              const LoginFooter(),
              const SizedBox(height: 32),
            ],

          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email/Username',
            style: TextStyle(color: Color(0xFFB13D37), fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const LoginTextField(
          hint: 'Masukkan Email/Username',
          prefixIcon: Icons.mail_outline,
          obscure: false,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Password',
                style: TextStyle(color: Color(0xFFB13D37), fontSize: 14, fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () {},
              child: const Text('Lupa Password?',
                  style: TextStyle(color: Color(0xFFB13D37), fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LoginTextField(
          hint: 'Masukkan Password',
          prefixIcon: Icons.lock_outline,
          obscure: _obscurePassword,
          showToggle: true,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.offAllNamed(AppRoutes.homepage),
            icon: const Text('Log In',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            label: const Icon(Icons.login, color: Colors.white, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF913632),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
