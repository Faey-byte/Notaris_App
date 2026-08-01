import 'package:flutter/material.dart';
import 'package:notaris_app/Model/ppat_model.dart';
import 'package:notaris_app/utils/app_colors.dart';

/// PpatDocItem — versi simple.
///
/// CATATAN PENTING (kenapa ini diubah):
/// Sebelumnya widget ini mencoba men-download file dari Cloudinary lalu
/// mendekripsi bytes-nya sendiri di client pakai AES + `matchkey`, meniru
/// pola NotarisDocItem. Ternyata skema enkripsi file PPAT BERBEDA dari
/// notaris (sudah dibuktikan lewat percobaan banyak kombinasi key/IV/mode
/// yang semuanya gagal menghasilkan gambar valid).
///
/// Backend PPAT sudah punya endpoint khusus yang MENDEKRIPSI FILE DI SISI
/// SERVER: `/api/v1/read-ppat` (lihat DetailBerkasController.displayDocument).
/// Jadi client tidak perlu (dan tidak boleh) coba dekripsi manual lagi —
/// tinggal panggil endpoint itu dan render bytes yang dikembalikan.
///
/// Widget ini sekarang murni tampilan (dumb widget): saat di-tap, dia
/// cuma memanggil callback [onPreview] yang disediakan oleh halaman
/// pemanggil (biasanya `() => controller.displayDocument(...)`).
class PpatDocItem extends StatelessWidget {
  final PpatDocMetadata doc;
  final VoidCallback onPreview;

  const PpatDocItem({
    super.key,
    required this.doc,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPreview,
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
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF2E7D32),
              ),
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
              icon: const Icon(
                Icons.visibility_outlined,
                color: AppColors.primary,
              ),
              onPressed: onPreview,
            ),
          ],
        ),
      ),
    );
  }
}