import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Notaris_Controller.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/Widget/Detail_Berkas/doc_item.dart';
import 'package:notaris_app/Widget/Detail_Berkas/info_box.dart';
import 'package:notaris_app/Widget/Detail_Berkas/label.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasNotarisPage extends StatelessWidget {
  final AktaItem item;
  const DetailBerkasNotarisPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(), // ✅ back ke notaris page
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF334155), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Detail Berkas',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ─── CONTENT ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── NAMA + NOMOR ───
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nama,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No. Akta: ${item.no}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ─── status badge ───
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getBgColor(item.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: _getFgColor(item.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ─── INFO BOXES ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // ✅ pake InfoBox + LabelText
                          InfoBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelText('JENIS PEKERJAAN'),
                                const SizedBox(height: 4),
                                Text(
                                  item.jenis,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          InfoBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelText('TANGGAL'),
                                const SizedBox(height: 4),
                                Text(
                                  item.tanggal,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // ─── biaya + staff ───
                          InfoBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LabelText('TOTAL BIAYA LAYANAN'),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rp 4.500.000',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    LabelText('NAMA STAFF'),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Andini Putri',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── DOKUMEN ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dokumen Persyaratan',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ pake DocItem yang udah ada
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          DocItem(_makeDok('Sertifikat_Asli_Scan.jpg', '13 Nov 2023', true)),
                          DocItem(_makeDok('KTP Pemilik.pdf', '12 Nov 2023', false)),
                          DocItem(_makeDok('Akta Notaris.pdf', '13 Nov 2023', false)),
                          DocItem(_makeDok('PBB Tahun Berjalan.pdf', '13 Nov 2023', false)),
                          DocItem(_makeDok('Foto Objek.jpg', '13 Nov 2023', true)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBgColor(String status) {
    switch (status) {
      case 'SELESAI': return const Color(0xFFDCFCE7);
      case 'PROSES':  return const Color(0xFFFEF3C7);
      case 'REVISI':  return const Color(0xFFDBEAFE);
      default:        return const Color(0xFFF1F5F9);
    }
  }

  Color _getFgColor(String status) {
    switch (status) {
      case 'SELESAI': return const Color(0xFF15803D);
      case 'PROSES':  return const Color(0xFFB45309);
      case 'REVISI':  return const Color(0xFF1D4ED8);
      default:        return const Color(0xFF64748B);
    }
  }

  // ✅ helper buat DokumenModel — sesuaiin sama field di DocItem
  _makeDok(String nama, String tanggal, bool isImage) {
    return DokumenModel(nama: nama, tanggal: tanggal, isImage: isImage);
  }
}