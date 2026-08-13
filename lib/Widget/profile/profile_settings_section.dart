import 'package:flutter/material.dart';
import 'package:notaris_app/Widget/common/thin_divider.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          _SettingsRow(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            isFirst: true,
          ),
          ThinDivider(),
          _SettingsRow(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            trailing: 'v1.2.4',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isFirst;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}
