import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Ppat_Controller.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import 'package:notaris_app/Widget/Berkas/Berkas_Card.dart';
import 'package:notaris_app/Widget/Berkas/Jenis_Filter_Chip.dart';
import 'package:notaris_app/Widget/Berkas/Page_Header_Widget.dart';
import 'package:notaris_app/Widget/Berkas/Search_Bar_Widget.dart';
import 'package:notaris_app/Widget/Berkas/Status_Chip.dart';
import 'package:notaris_app/utils/app_colors.dart';

class PpatPage extends StatelessWidget {
  PpatPage({super.key});

  final controller = Get.put(PpatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            controller.onScrollNotification(notification);
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              SliverToBoxAdapter(
                child: PageHeaderWidget(
                  title: "Berkas PPAT",
                  icon: Icons.insert_drive_file_outlined,
                  buttonLabel: "Tambah",
                  onButtonPressed: controller.goToTambah,
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBarWidget(
                        hintText: "Cari nama klien...",
                        onChanged: controller.setSearch,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() => Row(
                          children: controller.jenisList.map((jenis) {
                            return JenisFilterChip(
                              label: jenis,
                              isSelected: controller.selectedJenis.value == jenis,
                              onTap: () => controller.setJenis(jenis),
                            );
                          }).toList(),
                        )),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                                  SizedBox(width: 4),
                                  Text("STATUS",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            ...controller.statusList.map((s) => Obx(() => StatusChip(
                              label: s.label,
                              textColor: s.textColor,
                              bgColor: s.bgColor,
                              isSelected: controller.selectedStatus.value == s.label,
                              onTap: () => controller.setStatus(s.label),
                            ))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("DAFTAR BERKAS TERKINI",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          letterSpacing: 0.8, color: AppColors.primary),
                      ),
                      Obx(() => Text("${controller.filteredList.length} Berkas ditemukan",
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                      )),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (!controller.isLoading.value && controller.filteredList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.folder_off_outlined, size: 48, color: AppColors.border),
                          SizedBox(height: 12),
                          Text("Tidak ada data", style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              Obx(() => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BerkasCard(data: controller.filteredList[index]),
                    childCount: controller.filteredList.length,
                  ),
                ),
              )),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoadingMore.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!controller.hasMore.value && controller.filteredList.isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text("Semua data sudah dimuat",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ),
                    );
                  }
                  return const SizedBox(height: 16);
                }),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: controller.onBottomNavTap,
      ),
    );
  }
}