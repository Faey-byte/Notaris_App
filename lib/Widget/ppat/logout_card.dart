import 'package:flutter/material.dart';
import 'package:notaris_app/utils/app_colors.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusRevisiBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.statusRevisi),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.statusRevisi,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Keluar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  Text("Logout dari aplikasi", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}