import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/otp_controller.dart';
import 'package:notaris_app/Widget/Otp%20Widget/otp_input_field.dart';

class OtpPages extends StatefulWidget {
  const OtpPages({super.key});

  @override
  State<OtpPages> createState() => _OtpPagesState();
}

class _OtpPagesState extends State<OtpPages> {
  final int _otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  final OtpController controller = Get.put(OtpController());

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

  String get _otpValue => _controllers.map((c) => c.text).join();

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return OtpInputField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) => _onOtpChanged(value, index),
                  );
                }),
              ),

              const SizedBox(height: 32),

              Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator(color: Color(0xFF913632))
                    : _buildVerifyButton(),
              ),

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
          child: const Icon(Icons.gavel, color: Color(0xFFB13E37), size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Notaris & PPAT',
          style: TextStyle(
            color: Color(0xFF0D141B),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'Verifikasi OTP',
          style: TextStyle(
            color: Color(0xFFB13D37),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masukkan kode OTP yang telah dikirim\nke email: ${controller.email}', // Menampilkan email yang dinamis
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.verifyOtp(_otpValue),
        icon: const Text(
          'Verifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        label: const Icon(
          Icons.verified_outlined,
          color: Colors.white,
          size: 20,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF913632),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Tidak menerima kode? ',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        GestureDetector(
          onTap: () => controller.resendOtp(),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
        const SizedBox(width: 12),
        const Text(
          'ATAU BANTUAN',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Butuh bantuan teknis?',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Hubungi Administrator Sistem',
            style: TextStyle(color: Color(0xFF2B8CEE), fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2026 TWELVETEAM SMK RUS KUDUS',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
