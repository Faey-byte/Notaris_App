import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/home_controller.dart';

class HomeQuickOverview extends StatelessWidget {
  const HomeQuickOverview({super.key});

  Widget _buildStatTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Ringkasan Singkat',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'RINGKASAN BERKAS',
                style: TextStyle(
                  color: Color(0xFF913632),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
            children: [
              _buildStatTile(
                icon: Icons.description_outlined,
                iconBg: const Color(0xFFF7E3E2),
                iconColor: const Color(0xFF913632),
                value: controller.isLoadingSummary.value
                    ? '...'
                    : controller.notarisFiles.value,
                label: 'Notaris File',
              ),
              _buildStatTile(
                icon: Icons.history_edu_outlined,
                iconBg: const Color(0xFFF7E3E2),
                iconColor: const Color(0xFF913632),
                value: controller.isLoadingSummary.value
                    ? '...'
                    : controller.ppatFiles.value,
                label: 'PPAT File',
              ),
              _buildStatTile(
                icon: Icons.sync,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                value: controller.isLoadingSummary.value
                    ? '...'
                    : controller.inProcess.value,
                label: 'Proses',
              ),
              _buildStatTile(
                icon: Icons.task_alt,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                value: controller.isLoadingSummary.value
                    ? '...'
                    : controller.completed.value,
                label: 'Selesai',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
