import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/notaris_controller.dart';
import 'package:notaris_app/Controller/rekap_laporan_controller.dart';
import 'package:notaris_app/Pages/calculator_page.dart';
import 'package:notaris_app/Pages/home_page.dart';
import 'package:notaris_app/Pages/ppat_page.dart';
import 'package:notaris_app/Pages/Tambah_Berkas_Notaris.dart';
import 'package:notaris_app/Widget/app_bottom_navbar.dart';
import 'package:notaris_app/Widget/Notaris/notaris_card.dart';
import 'package:notaris_app/Widget/Berkas/page_header_widget.dart';
import 'package:notaris_app/Widget/Berkas/search_bar_widget.dart';
import 'package:notaris_app/Widget/Berkas/status_chip.dart';
import 'package:notaris_app/utils/app_colors.dart';

class NotarisPage extends StatelessWidget {
  NotarisPage({super.key});

  final controller = Get.put(NotarisController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => HomePage());
              break;
            case 1:
              Get.offAll(() => NotarisPage());
              break;
            case 2:
              Get.offAll(() => PpatPage());
              break;
            case 3:
              Get.offAll(() => CalculatorPage());
              break;
            case 4:
              Get.offAll(() => const RekapLaporanController());
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PageHeaderWidget(
                title: 'Berkas Notaris',
                icon: Icons.gavel,
                buttonLabel: 'Berkas',
                onButtonPressed: () =>
                    Get.to(() => const TambahBerkasNotarisPage()),
              ),
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(
                      hintText: 'Cari Nama Klien atau Nomor Akta...',
                      onChanged: controller.setSearch,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'STATUS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...controller.statusList.map(
                            (s) => Obx(
                              () => StatusChip(
                                label: s.label,
                                textColor: s.textColor,
                                bgColor: s.bgColor,
                                isSelected:
                                    controller.selectedStatus.value == s.label,
                                onTap: () => controller.setStatus(s.label),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DAFTAR BERKAS TERKINI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.filteredItems.length} Berkas ditemukan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.filteredItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 48,
                          color: AppColors.border,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada data',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: controller.filteredItems.length,
                  itemBuilder: (_, i) =>
                      NotarisCard(item: controller.filteredItems[i]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
