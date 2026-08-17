import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_info_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/detail_dropdown_card.dart';
import 'package:notaris_app/Widget/Detail_Berkas/conditional_detail_card.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/utils/currency_formatter.dart';
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
      appBar: _buildAppBar(),
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
                    _buildHeader(controller),
                    const SizedBox(height: 20),
                    DetailInfoCard(
                      title: "JENIS PEKERJAAN",
                      content: data.caseData.caseName
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                    const SizedBox(height: 12),

                    ConditionalDetailCard(
                      title: "DESKRIPSI",
                      icon: Icons.description_outlined,
                      hasData: () =>
                          controller.description.value.trim().isNotEmpty,
                      linesBuilder: () => [controller.description.value],
                    ),

                    _buildStatusRow(controller),
                    const SizedBox(height: 12),

                    Obx(
                      () => DetailInfoCard(
                        title: "LOKASI OBJEK",
                        content: controller.alamat.value,
                        icon: Icons.location_on,
                      ),
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
                      title: "NOTARIS / PPAT",
                      icon: Icons.badge_outlined,
                      hasData: () =>
                          controller.notaryName.value.trim().isNotEmpty ||
                          controller.namaInstitute.value.trim().isNotEmpty,
                      linesBuilder: () => [
                        if (controller.notaryName.value.trim().isNotEmpty)
                          "Notaris: ${controller.notaryName.value.trim()}",
                        if (controller.namaInstitute.value.trim().isNotEmpty)
                          "Kantor: ${controller.namaInstitute.value.trim()}",
                      ],
                    ),

                    ConditionalDetailCard(
                      title: "DATA PIHAK I (PENJUAL/PEMBERI)",
                      icon: Icons.person_outline,
                      hasData: () =>
                          controller.transferorName.value.trim().isNotEmpty,
                      linesBuilder: () => _buildPartyLines(
                        name: controller.transferorName.value,
                        address: controller.transferorAddress.value,
                        npwp: controller.transferorNpwp.value,
                      ),
                    ),

                    ConditionalDetailCard(
                      title: "DATA PIHAK II (PEMBELI/PENERIMA)",
                      icon: Icons.person_outline,
                      hasData: () =>
                          controller.transfereeName.value.trim().isNotEmpty,
                      linesBuilder: () => _buildPartyLines(
                        name: controller.transfereeName.value,
                        address: controller.transfereeAddress.value,
                        npwp: controller.transfereeNpwp.value,
                      ),
                    ),

                    ConditionalDetailCard(
                      title: "DATA OBJEK TANAH",
                      icon: Icons.landscape_outlined,
                      hasData: () => _hasLandData(controller),
                      linesBuilder: () => _buildLandLines(controller),
                    ),

                    ConditionalDetailCard(
                      title: "DATA PAJAK",
                      icon: Icons.receipt_long_outlined,
                      hasData: () => _hasTaxData(controller),
                      linesBuilder: () => _buildTaxLines(controller),
                    ),

                    ConditionalDetailCard(
                      title: "DATA AKTA / SERTIPIKAT",
                      icon: Icons.article_outlined,
                      hasData: () => _hasDeedData(controller),
                      linesBuilder: () => _buildDeedLines(controller),
                    ),

                    const SizedBox(height: 12),
                    _buildDocumentSection(controller),
                  ],
                ),
              ),
            ),
            _buildFooter(controller),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

    Widget _buildHeader(DetailBerkasController controller) {
      return Column(
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
        ],
      );
    }

  Widget _buildStatusRow(DetailBerkasController controller) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => AbsorbPointer(
              absorbing: controller.isUpdatingStatus.value,
              child: Opacity(
                opacity: controller.isUpdatingStatus.value ? 0.6 : 1,
                child: DetailDropdownCard(
                  title: "STATUS PENGERJAAN",
                  currentValue: controller.statusPengerjaan.value,
                  items: const ["PENDING", "REVISI", "SELESAI", "PROSES"],
                  onChanged: (val) => controller.updateStatusPekerjaan(val!),
                  backgroundColor: controller.getStatusPekerjaanBg(
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
                opacity: controller.isUpdatingStatusPajak.value ? 0.6 : 1,
                child: DetailDropdownCard(
                  title: "STATUS PAJAK",
                  currentValue: controller.statusPajak.value,
                  items: const ["Belum Lunas", "Lunas", "Titip Biaya"],
                  onChanged: (val) => controller.updateStatusPajak(val!),
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
    );
  }

  Widget _buildDocumentSection(DetailBerkasController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                style: TextStyle(color: AppColors.primary, fontSize: 13),
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
                      documentName: item.label,
                      documentUrl: item.url,
                      clientId: controller.publicId.value,
                      fileId: item.id,
                      ppatType: controller.jenisTransaksi.value,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildFooter(DetailBerkasController controller) {
    return Container(
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
            _buildFooterColumn(
              label: "TOTAL BIAYA LAYANAN",
              valueBuilder: () => controller.totalBiaya.value,
              alignment: CrossAxisAlignment.start,
              fontSize: 18,
            ),
            _buildFooterColumn(
              label: "NAMA STAFF",
              valueBuilder: () => controller.namaStaff.value,
              alignment: CrossAxisAlignment.end,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterColumn({
    required String label,
    required String Function() valueBuilder,
    required CrossAxisAlignment alignment,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            valueBuilder(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _buildPartyLines({
    required String name,
    required String address,
    required String npwp,
  }) {
    return [
      "Nama: ${name.trim()}",
      if (address.trim().isNotEmpty) "Alamat: ${address.trim()}",
      if (npwp.trim().isNotEmpty) "NPWP: ${npwp.trim()}",
    ];
  }

  bool _hasLandData(DetailBerkasController c) {
    return c.hamlet.value.trim().isNotEmpty ||
        c.village.value.trim().isNotEmpty ||
        c.landArea.value > 0 ||
        c.buildingArea.value > 0 ||
        c.book.value.trim().isNotEmpty ||
        c.number.value.trim().isNotEmpty;
  }

  List<String> _buildLandLines(DetailBerkasController c) {
    final hamlet = c.hamlet.value.trim();
    final village = c.village.value.trim();

    return [
      if (hamlet.isNotEmpty || village.isNotEmpty)
        "Lokasi: ${[hamlet, village].where((e) => e.isNotEmpty).join(', ')}",
      if (c.landArea.value > 0) "Luas Tanah: ${c.landArea.value} m²",
      if (c.buildingArea.value > 0)
        "Luas Bangunan: ${c.buildingArea.value} m²",
      if (c.book.value.trim().isNotEmpty) "Buku Tanah: ${c.book.value.trim()}",
      if (c.number.value.trim().isNotEmpty)
        "Nomor Hak: ${c.number.value.trim()}",
    ];
  }

  bool _hasTaxData(DetailBerkasController c) {
    return c.nop.value.trim().isNotEmpty ||
        c.njop.value > 0 ||
        c.bphtb.value > 0 ||
        c.taxYear.value > 0;
  }

  List<String> _buildTaxLines(DetailBerkasController c) {
    return [
      if (c.taxYear.value > 0) "Tahun Pajak: ${c.taxYear.value}",
      if (c.nop.value.trim().isNotEmpty) "NOP: ${c.nop.value.trim()}",
      if (c.njop.value > 0)
        "NJOP: ${CurrencyFormatter.formatPemasukan(c.njop.value.toDouble())}",
      if (c.bphtb.value > 0)
        "BPHTB: ${CurrencyFormatter.formatPemasukan(c.bphtb.value.toDouble())}",
    ];
  }

  bool _hasDeedData(DetailBerkasController c) {
    return c.deedNumber.value.trim().isNotEmpty ||
        c.deedType.value.trim().isNotEmpty ||
        c.rightType.value.trim().isNotEmpty ||
        c.rightNumber.value.trim().isNotEmpty;
  }

  List<String> _buildDeedLines(DetailBerkasController c) {
    final deedDate = c.deedDate.value.trim();

    return [
      if (c.deedNumber.value.trim().isNotEmpty)
        "No. Akta: ${c.deedNumber.value.trim()}",
      if (deedDate.isNotEmpty && deedDate != "-") "Tanggal Akta: $deedDate",
      if (c.deedType.value.trim().isNotEmpty)
        "Jenis Akta: ${c.deedType.value.trim().toUpperCase()}",
      if (c.rightType.value.trim().isNotEmpty)
        "Jenis Hak: ${c.rightType.value.trim().toUpperCase()}",
      if (c.rightNumber.value.trim().isNotEmpty)
        "Nomor Hak: ${c.rightNumber.value.trim()}",
    ];
  }
}