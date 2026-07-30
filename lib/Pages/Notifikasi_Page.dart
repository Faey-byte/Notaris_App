import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/Controller/Notifikasi_Controller.dart';
import 'package:notaris_app/Model/Notifikasi_Model.dart';
import 'package:notaris_app/Widget/Notifikasi_Card_Widget.dart';
import 'package:notaris_app/utils/app_colors.dart';

class NotifikasiPage extends StatelessWidget {
  NotifikasiPage({super.key});

  final controller = Get.put(NotifikasiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), 
        actions: [
          
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            tooltip: "Tandai semua dibaca",
            onPressed: () => controller.markAllAsRead(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifikasiList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.border),
                SizedBox(height: 12),
                Text("Belum ada notifikasi baru", style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
          
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifikasi,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifikasiList.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = controller.notifikasiList[index];
              return NotifikasiCardWidget(
                data: item,
                onTap: () => controller.markAsRead(item.id),
              );
            },
          ),
        );
      }),
    );
  }
}