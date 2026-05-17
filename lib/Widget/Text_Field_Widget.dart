import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notaris_app/Formatter/Currency_Formatter.dart';
import 'package:notaris_app/utils/app_colors.dart';

class TextfieldsWidget extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  final bool readOnly;
  final String? prefixText;
  final TextInputType keyboardType;
  

  const TextfieldsWidget({
    super.key,
    required this.label,
    this.controller,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,

    this.readOnly = false,
    this.prefixText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        inputFormatters: [
          if (keyboardType == TextInputType.number) CurrencyInputFormatter(),
        ],
        onChanged: onChanged,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false, required bool showToggle, required bool obscure, required void Function() onToggle, String? errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}