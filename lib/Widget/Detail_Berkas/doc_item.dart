import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/data/db_helper.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DocItem extends StatelessWidget {
  final DokumenModel doc;
  static const String baseUrl = "${ApiConfig.baseUrl}/api/v1";

  const DocItem({super.key, required this.doc});

  void _bukaPratinjauGambar(BuildContext context) {
    final DetailBerkasController controller = Get.find();
    _getClientIdAndDisplay(context, controller);
  }

  Future<void> _getClientIdAndDisplay(
    BuildContext context,
    DetailBerkasController controller,
  ) async {
    try {
      final dbHelper = DbHelper();
      final dbClient = await dbHelper.db;
      final String urlLastSegment = doc.url.split('/').last;

      debugPrint("[DOC] ════════════════════════════════════════");
      debugPrint("[DOC] 📄 Doc nama   : '${doc.nama}'");
      debugPrint("[DOC] 🔍 QueryHint  : '${doc.queryHint}'");
      debugPrint("[DOC] 🌐 URL        : '${doc.url}'");
      debugPrint("[DOC] 🔗 URL Segment: '$urlLastSegment'");
      debugPrint("[DOC] ════════════════════════════════════════");

      List<Map<String, dynamic>> result = [];

      // Step 1: Exact match label = queryHint
      result = await dbClient.query(
        'ppat_draft',
        where: 'label = ?',
        whereArgs: [doc.queryHint],
      );
      debugPrint("[DOC] Step 1 (label exact): ${result.length} rows");

      // Step 2: Filter by text_value jika ada lebih dari 1 hasil
      if (result.length > 1) {
        final filtered = result.where((row) {
          return row['text_value']?.toString() == urlLastSegment;
        }).toList();
        debugPrint("[DOC] Step 2 (text_value filter): ${filtered.length} rows");
        if (filtered.isNotEmpty) result = filtered;
      }

      // Step 3: Fuzzy label LIKE %queryHint%
      if (result.isEmpty) {
        result = await dbClient.query(
          'ppat_draft',
          where: 'label LIKE ?',
          whereArgs: ['%${doc.queryHint}%'],
        );
        debugPrint("[DOC] Step 3 (label fuzzy): ${result.length} rows");
      }

      // Step 4: Fallback by URL segment
      if (result.isEmpty) {
        result = await dbClient.query(
          'ppat_draft',
          where: 'url LIKE ?',
          whereArgs: ['%$urlLastSegment%'],
        );
        debugPrint("[DOC] Step 4 (url fallback): ${result.length} rows");
      }

      if (result.isEmpty) {
        debugPrint("[DOC] ❌ Tidak ada record untuk: '${doc.queryHint}'");
        Get.snackbar("Error", "Record tidak ditemukan untuk: ${doc.queryHint}");
        return;
      }

      final Map<String, dynamic> selectedRow = result.first;
      final String? fileId = selectedRow['file_id']?.toString();
      final String? clientId = selectedRow['client_id']?.toString();

      debugPrint("[DOC] ════════════════════════════════════════");
      debugPrint("[DOC] ✅ FINAL SELECTION:");
      debugPrint("[DOC]    - label     : '${selectedRow['label']}'");
      debugPrint("[DOC]    - text_value: '${selectedRow['text_value']}'");
      debugPrint("[DOC]    - file_id   : '$fileId'");
      debugPrint("[DOC]    - client_id : '$clientId'");
      debugPrint("[DOC] ════════════════════════════════════════");

      if (fileId == null || fileId.isEmpty) {
        Get.snackbar("Error", "File ID kosong");
        return;
      }

      if (clientId == null || clientId.isEmpty) {
        Get.snackbar("Error", "Client ID kosong");
        return;
      }

      // 🔧 Sekarang fileId juga dikirim, dipakai sebagai 'id' di /read-ppat
      controller.displayDocument(
        context: context,
        documentName: doc.queryHint,
        documentUrl: doc.url,
        clientId: clientId,
        fileId: fileId,
        ppatType: doc.ppatType,
      );
    } catch (e) {
      debugPrint("[DOC] ❌ Exception: $e");
      Get.snackbar("Error", "Gagal memuat dokumen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _bukaPratinjauGambar(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_outlined, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.nama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Diunggah ${doc.tanggal}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: AppColors.primary),
              onPressed: () => _bukaPratinjauGambar(context),
            ),
          ],
        ),
      ),
    );
  }
}