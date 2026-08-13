import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
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
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }
}
