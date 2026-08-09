import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/profile_controller.dart';

class ProfileLogoutButton extends StatelessWidget {
  final ProfileController controller;

  const ProfileLogoutButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.confirmLogout,
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF913632), width: 1.5),
          backgroundColor: const Color(0xFF913632),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}