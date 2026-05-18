import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Routes/routes.dart';

class OtpPages extends StatefulWidget {
  const OtpPages({super.key});

  @override
  State<OtpPages> createState() => _OtpPagesState();
}

class _OtpPagesState extends State<OtpPages> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

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
              const SizedBox(height: 32),
              _buildOtpFields(),
              const SizedBox(height: 32),
              _buildVerifyButton(),
              const SizedBox(height: 24),
              _buildResendRow(),
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
          decoration: const BoxDecoration(
            color: Color(0xFFF9F0E8),
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
    return const Column(
      children: [
        SizedBox(height: 8),
        Text(
          'Verifikasi OTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFB13D37),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Masukkan kode OTP yang telah dikirim\nke email atau nomor HP anda',
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

  // ─── OTP FIELDS ─────────────────────────────────────────────────────────────

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF9A9595)),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D141B),
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          ),
        );
      }),
    );
  }

  // ─── VERIFY BUTTON ──────────────────────────────────────────────────────────

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_otpValue.length == _otpLength) {
            Get.offAllNamed(AppRoutes.homepage);
          }
        },
        icon: const Text(
          'Verifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        label: const Icon(Icons.verified_outlined, color: Colors.white, size: 20),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF913632),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // ─── RESEND ROW ─────────────────────────────────────────────────────────────

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Tidak menerima kode? ',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: trigger resend OTP
          },
          child: const Text(
            'Kirim Ulang',
            style: TextStyle(
              color: Color(0xFFB13D37),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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