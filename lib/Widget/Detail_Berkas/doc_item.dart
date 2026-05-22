import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart'; // FIX: Mengimpor DokumenModel dari Controller
import 'package:notaris_app/utils/app_colors.dart';

class DocItem extends StatelessWidget {
  final DokumenModel doc;

  const DocItem({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: doc.isImage ? AppColors.statusSelesaiBg : AppColors.statusProsesBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              doc.isImage ? Icons.image_outlined : Icons.description_outlined,
              color: doc.isImage ? AppColors.statusSelesai : AppColors.statusProses,
            ),
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
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}