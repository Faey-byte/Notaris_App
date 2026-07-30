import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Home_Controller.dart';
import 'package:notaris_app/Widget/Stat_Card.dart';

class HomeQuickOverview extends StatelessWidget {
  const HomeQuickOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => Column(
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
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              StatCard(
                icon: Icons.description_outlined,
                iconBg: const Color(0xFFF7E3E2),
                iconColor: const Color(0xFF913632),
                value: controller.isLoadingSummary.value
                    ? 'Loading...'
                    : controller.notarisFiles.value,
                label: 'Notaris File',
              ),
              StatCard(
                icon: Icons.history_edu_outlined,
                iconBg: const Color(0xFFF7E3E2),
                iconColor: const Color(0xFF913632),
                value: controller.isLoadingSummary.value
                    ? 'Loading...'
                    : controller.ppatFiles.value,
                label: 'PPAT File',
              ),
              StatCard(
                icon: Icons.sync,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                value: controller.isLoadingSummary.value
                    ? 'Loading...'
                    : controller.inProcess.value,
                label: 'Proses',
              ),
              StatCard(
                icon: Icons.task_alt,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                value: controller.isLoadingSummary.value
                    ? 'Loading...'
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