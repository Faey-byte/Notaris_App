import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_info_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_dropdown_card.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasPage extends StatelessWidget {
  final BerkasModel data;

  const DetailBerkasPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailBerkasController());
    controller.initData(data);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Detail Berkas",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.fallbackName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "#${controller.publicId.value}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    DetailInfoCard(
                      title: "JENIS PEKERJAAN",
                      content: data.caseData.caseName
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DetailDropdownCard(
                            title: "STATUS PENGERJAAN",
                            currentValue: controller.statusPengerjaan.value,
                            items: const [
                              "PENDING",
                              "PROSES",
                              "REVISI",
                              "SELESAI",
                            ],
                            onChanged: (val) =>
                                controller.updateStatusPekerjaan(val!),
                            backgroundColor: controller.getStatusPekerjaanBg(
                              controller.statusPengerjaan.value,
                            ),
                            textColor: controller.getStatusPekerjaanColor(
                              controller.statusPengerjaan.value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DetailDropdownCard(
                            title: "STATUS PAJAK",
                            currentValue: controller.statusPajak.value,
                            items: const ["Belum Bayar", "Lunas"],
                            onChanged: (val) =>
                                controller.updateStatusPajak(val!),
                            backgroundColor: controller.getStatusPajakBg(
                              controller.statusPajak.value,
                            ),
                            textColor: controller.getStatusPajakColor(
                              controller.statusPajak.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(
                      () => DetailInfoCard(
                        title: "LOKASI OBJEK",
                        content: controller.alamat.value,
                        icon: Icons.location_on,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Obx(
                      () => DetailInfoCard(
                        title: "STAFF PENANGGUNG JAWAB",
                        content: controller.namaStaff.value,
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dokumen Persyaratan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    controller.dokumenList.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            alignment: Alignment.center,
                            child: const Text(
                              "Tidak ada berkas fisik terunggah",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.dokumenList.length,
                            itemBuilder: (context, index) {
                              return DocItem(
                                doc: controller.dokumenList[index],
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "TOTAL BIAYA LAYANAN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.totalBiaya.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "NAMA STAFF",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.namaStaff.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
