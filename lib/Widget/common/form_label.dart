import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final bool required;
  final bool showError;

  const FormLabel(
    this.text, {
    super.key,
    this.required = false,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: text),
          if (required && showError)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}