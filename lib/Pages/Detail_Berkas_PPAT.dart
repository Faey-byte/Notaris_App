import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_info_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_dropdown_card.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/Model/ppat_model.dart';

class DetailBerkasPage extends StatelessWidget {
  final PpatDetailModel data;

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

                    // ==== Deskripsi & status hidup ====
                    Obx(() {
                      if (controller.description.value.trim().isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DESKRIPSI",
                            content: controller.description.value,
                            icon: Icons.description_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

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
                                    "REVISI",
                                    "SELESAI",
                                    "PROSES",
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

                    Obx(
                      () => DetailInfoCard(
                        title: "LOKASI OBJEK",
                        content: controller.alamat.value,
                        icon: Icons.location_on,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (controller.titipBiayaAmount.value <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "NOMINAL TITIP BIAYA",
                            content: controller.titipBiayaAmountFormatted.value,
                            icon: Icons.savings_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Notaris / kantor ====
                    Obx(() {
                      final notary = controller.notaryName.value.trim();
                      final institute = controller.namaInstitute.value.trim();
                      if (notary.isEmpty && institute.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final lines = <String>[
                        if (notary.isNotEmpty) "Notaris: $notary",
                        if (institute.isNotEmpty) "Kantor: $institute",
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "NOTARIS / PPAT",
                            content: lines.join("\n"),
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Data Pihak I (Transferor) ====
                    Obx(() {
                      final name = controller.transferorName.value.trim();
                      if (name.isEmpty) return const SizedBox.shrink();
                      final lines = <String>[
                        "Nama: $name",
                        if (controller.transferorAddress.value
                            .trim()
                            .isNotEmpty)
                          "Alamat: ${controller.transferorAddress.value}",
                        if (controller.transferorNpwp.value.trim().isNotEmpty)
                          "NPWP: ${controller.transferorNpwp.value}",
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DATA PIHAK I (PENJUAL/PEMBERI)",
                            content: lines.join("\n"),
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Data Pihak II (Transferee) ====
                    Obx(() {
                      final name = controller.transfereeName.value.trim();
                      if (name.isEmpty) return const SizedBox.shrink();
                      final lines = <String>[
                        "Nama: $name",
                        if (controller.transfereeAddress.value
                            .trim()
                            .isNotEmpty)
                          "Alamat: ${controller.transfereeAddress.value}",
                        if (controller.transfereeNpwp.value.trim().isNotEmpty)
                          "NPWP: ${controller.transfereeNpwp.value}",
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DATA PIHAK II (PEMBELI/PENERIMA)",
                            content: lines.join("\n"),
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Data objek tanah ====
                    Obx(() {
                      final hamlet = controller.hamlet.value.trim();
                      final village = controller.village.value.trim();
                      final landArea = controller.landArea.value;
                      final buildingArea = controller.buildingArea.value;
                      final book = controller.book.value.trim();
                      final number = controller.number.value.trim();

                      final hasData = hamlet.isNotEmpty ||
                          village.isNotEmpty ||
                          landArea > 0 ||
                          buildingArea > 0 ||
                          book.isNotEmpty ||
                          number.isNotEmpty;
                      if (!hasData) return const SizedBox.shrink();

                      final lines = <String>[
                        if (hamlet.isNotEmpty || village.isNotEmpty)
                          "Lokasi: ${[
                            hamlet,
                            village,
                          ].where((e) => e.isNotEmpty).join(', ')}",
                        if (landArea > 0) "Luas Tanah: $landArea m²",
                        if (buildingArea > 0)
                          "Luas Bangunan: $buildingArea m²",
                        if (book.isNotEmpty) "Buku Tanah: $book",
                        if (number.isNotEmpty) "Nomor Hak: $number",
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DATA OBJEK TANAH",
                            content: lines.join("\n"),
                            icon: Icons.landscape_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Data pajak (NOP, NJOP, BPHTB) ====
                    Obx(() {
                      final nop = controller.nop.value.trim();
                      final njop = controller.njop.value;
                      final bphtb = controller.bphtb.value;
                      final taxYear = controller.taxYear.value;

                      final hasData =
                          nop.isNotEmpty || njop > 0 || bphtb > 0 || taxYear > 0;
                      if (!hasData) return const SizedBox.shrink();

                      final lines = <String>[
                        if (taxYear > 0) "Tahun Pajak: $taxYear",
                        if (nop.isNotEmpty) "NOP: $nop",
                        if (njop > 0) "NJOP: ${_formatRupiahLocal(njop)}",
                        if (bphtb > 0) "BPHTB: ${_formatRupiahLocal(bphtb)}",
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DATA PAJAK",
                            content: lines.join("\n"),
                            icon: Icons.receipt_long_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // ==== Data akta / sertipikat ====
                    Obx(() {
                      final deedNumber = controller.deedNumber.value.trim();
                      final deedType = controller.deedType.value.trim();
                      final rightType = controller.rightType.value.trim();
                      final rightNumber = controller.rightNumber.value.trim();
                      final deedDate = controller.deedDate.value.trim();

                      final hasData = deedNumber.isNotEmpty ||
                          deedType.isNotEmpty ||
                          rightType.isNotEmpty ||
                          rightNumber.isNotEmpty;
                      if (!hasData) return const SizedBox.shrink();

                      final lines = <String>[
                        if (deedNumber.isNotEmpty) "No. Akta: $deedNumber",
                        if (deedDate.isNotEmpty &&
                            deedDate != "-")
                          "Tanggal Akta: $deedDate",
                        if (deedType.isNotEmpty)
                          "Jenis Akta: ${deedType.toUpperCase()}",
                        if (rightType.isNotEmpty)
                          "Jenis Hak: ${rightType.toUpperCase()}",
                        if (rightNumber.isNotEmpty)
                          "Nomor Hak: $rightNumber",
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailInfoCard(
                            title: "DATA AKTA / SERTIPIKAT",
                            content: lines.join("\n"),
                            icon: Icons.article_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    const SizedBox(height: 12),

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
                              final item = controller.dokumenList[index];
                              return PpatDocItem(
                                doc: item,
                                onPreview: () => controller.displayDocument(
                                  context: context,
                                  documentName: item.label,
                                  documentUrl: item.url,
                                  clientId: controller.publicId.value,
                                  fileId: item
                                      .id,
                                  ppatType: controller
                                      .jenisTransaksi
                                      .value,
                                ),
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
                    color: Colors.black.withValues(alpha: 0.04),
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

/// Formatter Rupiah lokal untuk kartu-kartu di halaman ini
/// (tidak memakai intl NumberFormat supaya tidak perlu locale init tambahan di sini).
String _formatRupiahLocal(int amount) {
  if (amount <= 0) return "Rp 0";
  final reversed = amount.toString().split('').reversed.join();
  final chunks = <String>[];
  for (var i = 0; i < reversed.length; i += 3) {
    chunks.add(
      reversed.substring(i, i + 3 > reversed.length ? reversed.length : i + 3),
    );
  }
  final grouped = chunks.join('.').split('').reversed.join();
  return "Rp $grouped";
}