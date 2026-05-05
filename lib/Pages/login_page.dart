import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 884),
          child: Container(
            width: 403,
            height: 884,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 15.40,
                  offset: Offset(9, 11),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 390,
                  height: 614,
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 40,
                    right: 40,
                    bottom: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: double.infinity, height: 28),
                            Container(
                              height: 78,
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF9F0E8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 40,
                                          child: Text(
                                            'gavel',
                                            style: TextStyle(
                                              color: const Color(0xFFB13E37),
                                              fontSize: 36,
                                              fontFamily: 'Material Symbols Outlined',
                                              fontWeight: FontWeight.w400,
                                              height: 1.11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 249.11,
                              height: 32,
                              child: Text(
                                'Notaris & PPAT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF0D141B),
                                  fontSize: 24,
                                  fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 1.33,
                                  letterSpacing: -0.60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 187,
                        child: Text(
                          'Selamat Datang',
                          style: TextStyle(
                            color: const Color(0xFFB13D37),
                            fontSize: 24,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.17,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 261,
                        child: Text(
                          'Silahkan Masuk Akun Menejemen anda',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 310,
                                          child: Text(
                                            'Email/Ussername',
                                            style: TextStyle(
                                              color: const Color(0xFFB13D37),
                                              fontSize: 14,
                                              fontFamily: 'Public Sans',
                                              fontWeight: FontWeight.w500,
                                              height: 1.43,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                            left: 40,
                                            right: 16,
                                            bottom: 15,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: const Color(0xFF9A9595),
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 252,
                                                        child: Text(
                                                          'Masukkan Email/Username',
                                                          style: TextStyle(
                                                            color: const Color(0xFF6B7280),
                                                            fontSize: 16,
                                                            fontFamily: 'Public Sans',
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 12,
                                          top: 11,
                                          child: Container(
                                            height: 28,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 28,
                                                  child: Text(
                                                    'mail',
                                                    style: TextStyle(
                                                      color: const Color(0xFF94A3B8),
                                                      fontSize: 20,
                                                      fontFamily: 'Material Symbols Outlined',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.40,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 68,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 129.74,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 83,
                                              height: 20,
                                              child: Text(
                                                'Password',
                                                style: TextStyle(
                                                  color: const Color(0xFFB13D37),
                                                  fontSize: 14,
                                                  fontFamily: 'Public Sans',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.43,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(width: 100.84, height: 16),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                            left: 40,
                                            right: 48,
                                            bottom: 15,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: const Color(0xFF9A9595),
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 220,
                                                        child: Text(
                                                          'Masukkan Password',
                                                          style: TextStyle(
                                                            color: const Color(0xFF6B7280),
                                                            fontSize: 16,
                                                            fontFamily: 'Public Sans',
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 12,
                                          top: 11,
                                          child: Container(
                                            height: 28,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 28,
                                                  child: Text(
                                                    'lock',
                                                    style: TextStyle(
                                                      color: const Color(0xFF94A3B8),
                                                      fontSize: 20,
                                                      fontFamily: 'Material Symbols Outlined',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.40,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 278,
                                          top: 11,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 28,
                                                    child: Text(
                                                      'visibility',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: const Color(0xFF94A3B8),
                                                        fontSize: 20,
                                                        fontFamily: 'Material Symbols Outlined',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.40,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF913632),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x332B8CEE),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                          spreadRadius: -2,
                                        ),BoxShadow(
                                          color: Color(0x332B8CEE),
                                          blurRadius: 6,
                                          offset: Offset(0, 4),
                                          spreadRadius: -1,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 45.94,
                                              height: 24,
                                              child: Text(
                                                'Log In',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: const Color(0xFFFFFCFC),
                                                  fontSize: 16,
                                                  fontFamily: 'Public Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.50,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 28,
                                              child: Text(
                                                'login',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: const Color(0xFFFFFCFC),
                                                  fontSize: 18,
                                                  fontFamily: 'Material Symbols Outlined',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.56,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 32,
                    right: 32,
                    bottom: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 59.72,
                                  height: 16,
                                  child: Text(
                                    'OR HELP',
                                    style: TextStyle(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w500,
                                      height: 1.33,
                                      letterSpacing: 1.20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 169.72,
                            height: 32,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Need technical assistance?\n',
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 12,
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Contact System Administrator',
                                    style: TextStyle(
                                      color: const Color(0xFF2B8CEE),
                                      fontSize: 12,
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 255.98,
                        height: 15,
                        child: Text(
                          '© 2026 TWELVETEAM SMK RUS KUDUS',
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}