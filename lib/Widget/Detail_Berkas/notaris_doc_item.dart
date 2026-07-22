import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:notaris_app/data/db_Helper.dart';
import 'package:notaris_app/Model/notaris_detail_model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class NotarisDocItem extends StatelessWidget {
  final NotarisDocMetadata doc;

  const NotarisDocItem({super.key, required this.doc});

  void _bukaPratinjauGambar(BuildContext context) {
    _getLocalPathAndDisplay(context);
  }

  // =========================================================
  // 🔐 FUNGSI DEKRIPSI BINARY DENGAN MATCHKEY DARI SQLITE
  // =========================================================
  List<int> _decryptData(List<int> encryptedBytes, String matchKey) {
    try {
      if (matchKey.isEmpty) {
        debugPrint("[NOTARIS DEC] ⚠️ Matchkey kosong, mencoba render langsung.");
        return encryptedBytes;
      }

      // Backend Go biasanya menggunakan AES-256 mode CBC atau ECB dengan matchkey sebagai key & IV.
      // Sesuaikan padding & key length jika diperlukan.
      final keyBytes = encrypt.Key.fromUtf8(matchKey.padRight(32, '0').substring(0, 32));
      final ivBytes = encrypt.IV.fromUtf8(matchKey.padRight(16, '0').substring(0, 16));

      final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));

      return encrypter.decryptBytes(encrypted);
    } catch (e) {
      debugPrint("[NOTARIS DEC] ❌ Gagal melakukan dekripsi AES: $e");
      return encryptedBytes; // Fallback biner mentah jika gagal dekripsi
    }
  }

  Future<void> _getLocalPathAndDisplay(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final dbHelper = DbHelper();
      final dbClient = await dbHelper.db;
      final String urlLastSegment = doc.url.split('/').last;

      List<Map<String, dynamic>> result = [];

      // Step 1: Query berdasarkan URL segment (Metode paling akurat dibanding label)
      result = await dbClient.query(
        'notaris_draft',
        where: 'url LIKE ?',
        whereArgs: ['%$urlLastSegment%'],
      );

      // Step 2: Fallback exact match label
      if (result.isEmpty) {
        result = await dbClient.query(
          'notaris_draft',
          where: 'label = ?',
          whereArgs: [doc.label],
        );
      }

      if (result.isEmpty) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        // Jika data tidak ada di SQLite lokal (misal karena ganti HP), tampilkan fallback online langsung
        _tampilkanPopupGambarOnline(context, doc.url);
        return;
      }

      final Map<String, dynamic> selectedRow = result.first;
      final String idField = selectedRow['id_field'].toString();
      final String matchKey = selectedRow['matchkey']?.toString() ?? "";
      String? localPath = selectedRow['local_path']?.toString();

      bool isLocalFileValid = localPath != null &&
          localPath.isNotEmpty &&
          localPath != 'null' &&
          File(localPath).existsSync();

      // =========================================================
      // 📥 UNDUH & DEKRIPSI JIKA FILE LOKAL BELUM VALID
      // =========================================================
      if (!isLocalFileValid) {
        debugPrint("[NOTARIS DOC] 🌐 Mendownload berkas online...");
        final response = await http.get(Uri.parse(doc.url));
        
        if (response.statusCode == 200) {
          // Lakukan dekripsi biner menggunakan matchkey hasil query SQLite
          final decryptedBytes = _decryptData(response.bodyBytes, matchKey);

          final tempDir = await getTemporaryDirectory();
          final String fileName = "decrypted_${DateTime.now().millisecondsSinceEpoch}.jpg";
          final String newSavedPath = "${tempDir.path}/$fileName";

          final file = File(newSavedPath);
          await file.writeAsBytes(decryptedBytes);

          localPath = newSavedPath;
          isLocalFileValid = true;

          // Perbarui tabel berdasarkan id_field agar pencarian presisi
          await dbClient.update(
            'notaris_draft',
            {'local_path': localPath},
            where: 'id_field = ?',
            whereArgs: [idField],
          );
        } else {
          throw Exception("Gagal mengunduh berkas (Status: ${response.statusCode})");
        }
      }

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (isLocalFileValid && localPath != null) {
        _tampilkanPopupGambarLokal(context, localPath);
      } else {
        Get.snackbar("Error", "Gagal memproses penayangan file lokal.");
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Get.snackbar("Error", "Gagal memuat berkas: $e");
    }
  }

  void _tampilkanPopupGambarLokal(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: Text(
                          "Format gambar tidak kompatibel atau kunci dekripsi tidak sesuai.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanPopupGambarOnline(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (context, err, stack) => const Text("Gagal memuat gambar online."),
          ),
        ),
      ),
    );
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
              child: Text(
                doc.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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