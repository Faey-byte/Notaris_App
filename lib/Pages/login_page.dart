import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Routes/routes.dart';

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
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              _buildLogo(),
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 40),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── LOGO ───────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F0E8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.gavel,
            color: Color(0xFFB13E37),
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Notaris & PPAT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0D141B),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: const [
        SizedBox(height: 8),
        Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFB13D37),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Silahkan Masuk Akun Menejemen anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── FORM ────────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        const Text(
          'Email/Ussername',
          style: TextStyle(
            color: Color(0xFFB13D37),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'Masukkan Email/Username',
          prefixIcon: Icons.mail_outline,
          obscure: false,
        ),
        const SizedBox(height: 16),

        // Password label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                color: Color(0xFFB13D37),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lupa Password?',
                style: TextStyle(
                  color: Color(0xFFB13D37),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'Masukkan Password',
          prefixIcon: Icons.lock_outline,
          obscure: _obscurePassword,
          showToggle: true,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.offAllNamed(AppRoutes.homepage);
            },
            icon: const Text(
              'Log In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            label: const Icon(Icons.login, color: Colors.white, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF913632),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData prefixIcon,
    required bool obscure,
    bool showToggle = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9A9595)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              obscureText: obscure,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (showToggle) ...[
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ] else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ─── DIVIDER ─────────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
        const SizedBox(width: 12),
        const Text(
          'OR HELP',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
      ],
    );
  }

  // ─── FOOTER ──────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Need technical assistance?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Contact System Administrator',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2B8CEE),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2026 TWELVETEAM SMK RUS KUDUS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}