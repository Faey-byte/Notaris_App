import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Home_Controller.dart';
import 'package:notaris_app/Widget/Service_Item.dart';

class HomeManagementServices extends StatelessWidget {
  const HomeManagementServices({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Manajemen',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ServiceItem(
          icon: Icons.gavel,
          iconBg: const Color(0xFF913632),
          title: 'Notaris',
          subtitle: 'Kelola akta, wasiat & legalisasi',
          onTap: () => Get.toNamed('/Notaris'),
        ),
        const SizedBox(height: 10),
        ServiceItem(
          icon: Icons.map_outlined,
          iconBg: const Color(0xFF913632),
          title: 'PPAT',
          subtitle: 'Kelola AJB, Hibah & Hak Tanggungan',
          onTap: () => Get.toNamed('/PPAT'),
        ),
        const SizedBox(height: 10),
        ServiceItem(
          icon: Icons.calculate_outlined,
          iconBg: const Color(0xFF10B981),
          title: 'Kalkulator Biaya',
          subtitle: 'Estimasi pajak & PNBP otomatis',
          onTap: () => Get.toNamed('/Calculator'),
        ),
        const SizedBox(height: 10),
        ServiceItem(
          icon: Icons.analytics_outlined,
          iconBg: const Color(0xFFF59E0B),
          title: 'Rekap Laporan',
          subtitle: 'Bulanan, Triwulan & Tahunan',
          onTap: () => Get.toNamed('/rekap'),
        ),
        const SizedBox(height: 16),
        
        // Tombol Logout Utama
        GestureDetector(
          onTap: controller.logout, // Memanggil dialog konfirmasi logout
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Logout dari aplikasi',
                        style: TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 12,
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