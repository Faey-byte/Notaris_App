import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;

  const SectionTitle({super.key, required this.title, this.trailingText});

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    );

    if (trailingText == null) return titleText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleText,
        Text(
          trailingText!,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
