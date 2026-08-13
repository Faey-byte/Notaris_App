import 'package:flutter/material.dart';
import 'package:notaris_app/Formatter/currency_formatter.dart';

class TextfieldsWidget extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final ValueChanged<String>? onChanged;
  final String? errorText;

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
    this.prefixIconData,
    this.onChanged,
    this.errorText,

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
          prefixIcon: prefixIconData != null ? Icon(prefixIconData) : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
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
