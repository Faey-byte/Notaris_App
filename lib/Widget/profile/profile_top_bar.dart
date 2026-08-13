import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/profile_controller.dart';

class ProfileTopBar extends StatelessWidget {
  final ProfileController controller;

  const ProfileTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1E293B),
              size: 22,
            ),
          ),
          const Expanded(
            child: Text(
              'Profil Saya',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.openEditDialog,
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF1E293B),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}