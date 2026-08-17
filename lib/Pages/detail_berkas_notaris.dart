import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_notaris_controller.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_info_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_dropdown_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/conditional_detail_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/info_box.dart';
import 'package:notaris_app/Widget/Detail_Berkas/label.dart';
import 'package:notaris_app/Widget/Detail_Berkas/notaris_doc_item.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasNotarisPage extends StatelessWidget {
  final String clientName;
  final String? publicId;
  final String? localBerkasId;

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
                      const SizedBox(height: 20),

                    DetailInfoCard(
                      title: "JENIS PEKERJAAN",
                      content: controller.jenisPekerjaan.value,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DetailInfoCard(
                              title: "SIFAT AKTA",
                              content: controller.sifatAkta.value,
                              icon: Icons.description_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => DetailInfoCard(
                              title: "TANGGAL AKTA",
                              content: controller.tanggalAkta.value,
                              icon: Icons.event_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(
                      () => DetailInfoCard(
                        title: "STATUS PERKAWINAN",
                        content: controller.statusPerkawinan.value,
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => AbsorbPointer(
                              absorbing: controller.isUpdatingStatus.value,
                              child: Opacity(
                                opacity: controller.isUpdatingStatus.value
                                    ? 0.6
                                    : 1,
                                child: DetailDropdownCard(
                                  title: "STATUS PENGERJAAN",
                                  currentValue:
                                      controller.statusPengerjaan.value,
                                  items: const [
                                    "PENDING",
                                    "PROSES",
                                    "REVISI",
                                    "SELESAI",
                                  ],
                                  onChanged: (val) =>
                                      controller.updateStatusPekerjaan(val!),
                                  backgroundColor: controller
                                      .getStatusPekerjaanBg(
                                        controller.statusPengerjaan.value,
                                      ),
                                  textColor: controller.getStatusPekerjaanColor(
                                    controller.statusPengerjaan.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => AbsorbPointer(
                              absorbing: controller.isUpdatingStatusPajak.value,
                              child: Opacity(
                                opacity: controller.isUpdatingStatusPajak.value
                                    ? 0.6
                                    : 1,
                                child: DetailDropdownCard(
                                  title: "STATUS PAJAK",
                                  currentValue: controller.statusPajak.value,
                                  items: const [
                                    "Belum Lunas",
                                    "Lunas",
                                    "Titip Biaya",
                                  ],
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ConditionalDetailCard(
                      title: "NOMINAL TITIP BIAYA",
                      icon: Icons.savings_outlined,
                      hasData: () => controller.titipBiayaAmount.value > 0,
                      linesBuilder: () =>
                          [controller.titipBiayaAmountFormatted.value],
                    ),

                    ConditionalDetailCard(
                      title: "KETERANGAN",
                      icon: Icons.notes_outlined,
                      hasData: () => controller.keterangan.value.isNotEmpty,
                      linesBuilder: () => [controller.keterangan.value],
                    ),

                    const Text(
                      "Daftar Penghadap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (controller.penghadapList.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: const Text(
                            "Belum ada penghadap terdaftar",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.penghadapList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final penghadap = controller.penghadapList[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Text(
                                    "${penghadap.orderNumber}",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        penghadap.name.isEmpty
                                            ? '-'
                                            : penghadap.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (penghadap.title.isNotEmpty)
                                        Text(
                                          penghadap.title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 12),

                    const Text(
                      "Dokumen Persyaratan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
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
                              return NotarisDocItem(doc: doc);
                            },
                          ),
                  ],
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: InfoBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LabelText("TOTAL BIAYA LAYANAN"),
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
                          const LabelText("NAMA STAFF"),
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
            ),
          ],
        );
      }),
    );
  }
}