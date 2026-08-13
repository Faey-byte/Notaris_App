import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/profile_controller.dart';
import 'package:notaris_app/Widget/common/thin_divider.dart';

class ProfileInfoSection extends StatelessWidget {
  final ProfileController controller;

  const ProfileInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Obx(
            () => _InfoRow(
              icon: Icons.person_outline,
              label: 'NAMA LENGKAP',
              value: controller.nama.value,
              isFirst: true,
            ),
          ),
          const ThinDivider(),
          Obx(
            () => _InfoRow(
              icon: Icons.cake_outlined,
              label: 'TANGGAL LAHIR',
              value: controller.tanggalLahir.value,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF913632), size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFFCBD5E1),
          size: 20,
        ),
      ),
    );
  }
}