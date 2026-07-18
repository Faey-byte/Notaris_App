import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_notaris_controller.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_info_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_dropdown_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/notaris_doc_item.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasNotarisPage extends StatelessWidget {
  final String clientName;
  final String? publicId;      // opsional, kalau nanti sudah kesimpen
  final String? localBerkasId; // opsional, buat fallback total biaya

  const DetailBerkasNotarisPage({
    super.key,
    required this.clientName,
    this.publicId,
    this.localBerkasId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailBerkasNotarisController());
    controller.initData(
      clientName: clientName,
      publicIdParam: publicId,
      localBerkasId: localBerkasId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Detail Berkas Notaris",
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
                      controller.fallbackName.value,
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
                      content: controller.jenisPekerjaan.value,
                    ),
                    const SizedBox(height: 12),

                    DetailDropdownCard(
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
  final doc = controller.dokumenList[index];
  return NotarisDocItem(doc: doc); // ✅
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
                        Obx(() => Text(
                          controller.totalBiaya.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )),
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
                        Obx(() => Text(
                          controller.namaStaff.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )),
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