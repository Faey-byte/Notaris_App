import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DocItem extends StatelessWidget {
  final DokumenModel doc;

  const DocItem(this.doc, {super.key});

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
              color: doc.isImage
                  ? AppColors.primarySoft
                  : AppColors.greySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              doc.isImage
                  ? Icons.image_outlined
                  : Icons.description_outlined,
              color: doc.isImage
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Diunggah ${doc.tanggal}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }
}