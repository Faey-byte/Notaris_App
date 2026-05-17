import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final bool showToggle;
  final VoidCallback? onToggle;

  const LoginTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.obscure,
    this.showToggle = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF913632), size: 20),
          suffixIcon: showToggle
              ? GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}