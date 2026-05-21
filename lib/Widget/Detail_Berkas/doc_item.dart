import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:notaris_app/Controller/detail_berkas_controller.dart'; // Import file controller tempat DokumenModel berada
import 'package:notaris_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
              color: doc.isImage ? AppColors.primarySoft : AppColors.greySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              doc.isImage ? Icons.image_outlined : Icons.description_outlined,
              color: doc.isImage ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
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
            onPressed: () async {
              final url = Uri.parse(doc.url);
              if (doc.url.isNotEmpty && await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar("Gagal", "Link unduhan dokumen kosong atau tidak valid");
              }
            },
          ),
        ],
      ),
    );
  }
}