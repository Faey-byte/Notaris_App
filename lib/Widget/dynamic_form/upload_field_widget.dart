import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/Model/dynamic_field_model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class UploadFieldWidget extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const UploadFieldWidget(this.field, {super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final bool showStar =
                controller.attemptedSubmit.value &&
                controller.isFieldEmpty(field);

            return RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: field.label),
                  if (showStar)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          Obx(() {
            return Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                color: Colors.grey[50],
              ),
              child: _buildPreviewContent(),
            );
          }),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.pickAndUploadFile(field, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Ambil"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.pickAndUploadFile(field, ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Galeri"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (field.localFilePath.value.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Image.file(
              File(field.localFilePath.value),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

          if (field.isLoading.value)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    if (field.fileValue.value.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          field.fileValue.value,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildDocumentFallback();
          },
        ),
      );
    }

    if (field.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Center(
      child: Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
    );
  }

  Widget _buildDocumentFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          Text(
            "Berkas Tersimpan Aman",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Terunggah di Cloud Server",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
