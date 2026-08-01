import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Notaris_Controller.dart';
import 'package:notaris_app/Pages/detail_berkas_notaris.dart'; 

class NotarisCard extends StatelessWidget {
  final AktaItem item;
  const NotarisCard({super.key, required this.item});

  Color _getBgColor() {
    switch (item.status) {
      case 'SELESAI': return const Color(0xFFDCFCE7);
      case 'PENDING':
      case 'PROSES':  return const Color(0xFFFEF3C7);
      case 'REVISI':  return const Color(0xFFDBEAFE);
      case 'DITOLAK': return const Color(0xFFFEE2E2);
      default:        return const Color(0xFFF1F5F9);
    }
  }

  Color _getFgColor() {
    switch (item.status) {
      case 'SELESAI': return const Color(0xFF15803D);
      case 'PENDING':
      case 'PROSES':  return const Color(0xFFB45309);
      case 'REVISI':  return const Color(0xFF1D4ED8);
      case 'DITOLAK': return const Color(0xFFDC2626);
      default:        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotarisController controller = Get.find<NotarisController>();

    return GestureDetector(
      onTap: () async {
  // Menggunakan await agar kode di bawahnya tereksekusi pasca halaman detail di-close
    await Get.to(() => DetailBerkasNotarisPage(
      clientName: item.nama,        
      localBerkasId: item.berkasId,
    ));
    // Refresh dari server (bukan sqlite lagi) biar status/data terbaru muncul
    controller.loadFromServer(reset: true);
  },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nama,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(item.jenis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2B8CEE), fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _getBgColor(), borderRadius: BorderRadius.circular(8)),
                  child: Text(item.status,
                    style: TextStyle(color: _getFgColor(), fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, color: Color(0xFF888888), size: 16),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PUBLIC ID', style: TextStyle(fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w600)),
                          Text(item.no, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF888888), size: 16),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TANGGAL', style: TextStyle(fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w600)),
                          Text(item.tanggal, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}