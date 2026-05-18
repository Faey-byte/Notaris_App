import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
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
}