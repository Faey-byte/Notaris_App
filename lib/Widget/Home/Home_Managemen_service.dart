import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/home_controller.dart';

class HomeManagementServices extends StatelessWidget {
  const HomeManagementServices({super.key});

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            _buildMenuTile(
              icon: Icons.gavel,
              iconBg: const Color(0xFF913632),
              title: 'Notaris',
              subtitle: 'Kelola akta, wasiat & legalisasi',
              onTap: () => Get.toNamed('/Notaris'),
            ),
            _buildMenuTile(
              icon: Icons.map_outlined,
              iconBg: const Color(0xFF913632),
              title: 'PPAT',
              subtitle: 'Kelola AJB, Hibah & Hak Tanggungan',
              onTap: () => Get.toNamed('/PPAT'),
            ),
            _buildMenuTile(
              icon: Icons.calculate_outlined,
              iconBg: const Color(0xFF10B981),
              title: 'Kalkulator Biaya',
              subtitle: 'Estimasi pajak & PNBP otomatis',
              onTap: () => Get.toNamed('/Calculator'),
            ),
            _buildMenuTile(
              icon: Icons.analytics_outlined,
              iconBg: const Color(0xFFF59E0B),
              title: 'Rekap Laporan',
              subtitle: 'Bulanan, Triwulan & Tahunan',
              onTap: () => Get.toNamed('/LaporanPage'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: controller.logout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
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
                      SizedBox(height: 2),
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
                const Icon(Icons.chevron_right, color: Color(0xFFFCA5A5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
