import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TambahBerkasTopBar extends StatelessWidget {
  const TambahBerkasTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF334155), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tambah Berkas Notaris',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.45,
            ),
          ),
        ],
      ),
    );
  }
}