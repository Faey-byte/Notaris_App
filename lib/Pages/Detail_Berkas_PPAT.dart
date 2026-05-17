import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/info_box.dart';
import 'package:notaris_app/Widget/Detail_Berkas/label.dart';
import 'package:notaris_app/Widget/Detail_Berkas/status_box.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasPage extends StatelessWidget {
  final BerkasModel data;

  DetailBerkasPage({super.key, required this.data});

  late final DetailBerkasController c = Get.put(DetailBerkasController(data));

  void confirmChange({
    required String title,
    required String value,
    required Function() onConfirm,
  }) {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Ubah $title jadi \"$value\" ?",
      textConfirm: "OK",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        onConfirm();
        Get.back();
      },
    );
  }

  void showStatusPicker({
    required String title,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            const Divider(),
            ...options.map(
              (e) => ListTile(
                title: Text(e, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Get.back();
                  confirmChange(
                    title: title,
                    value: e,
                    onConfirm: () => onSelect(e),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text(
          "Detail Berkas",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              data.nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            InfoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelText("JENIS PEKERJAAN"),
                  const SizedBox(height: 6),
                  Text(
                    data.jenis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showStatusPicker(
                        title: "Status Pekerjaan",
                        options: ["PENDING", "PROSES", "SELESAI", "REVISI"],
                        onSelect: (val) => c.updateStatusPekerjaan(val),
                      );
                    },
                    child: StatusBox(
                      title: "STATUS PEKERJAAN",
                      value: c.statusPekerjaan.value,
                      textColor: c.getStatusPekerjaanColor(c.statusPekerjaan.value),
                      bgColor: c.getStatusPekerjaanBg(c.statusPekerjaan.value),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showStatusPicker(
                        title: "Status Pajak",
                        options: ["Lunas", "Belum Bayar"],
                        onSelect: (val) => c.updateStatusPajak(val),
                      );
                    },
                    child: StatusBox(
                      title: "STATUS PAJAK",
                      value: c.statusPajak.value,
                      textColor: c.getStatusPajakColor(c.statusPajak.value),
                      bgColor: c.getStatusPajakBg(c.statusPajak.value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            InfoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelText("LOKASI OBJEK"),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.alamat.value,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Dokumen Persyaratan",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            c.dokumenList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Tidak ada dokumen terlampir.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  )
                : Column(
                    children: c.dokumenList.map((doc) => DocItem(doc)).toList(),
                  ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL BIAYA LAYANAN",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.totalBiaya.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "NAMA STAFF",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.namaStaff.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}