import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final bool showToggle;
  final VoidCallback? onToggle;
  final TextEditingController? controller;
  final String? errorText;

  const LoginTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.obscure,
    this.showToggle = false,
    this.onToggle,
    this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? const Color(0xFFE53E3E) : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(prefixIcon,
                color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF913632),
                size: 20),
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
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: Color(0xFFE53E3E)),
              const SizedBox(width: 4),
              Text(errorText!,
                style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }
}