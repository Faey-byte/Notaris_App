import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';


class FieldBuilder extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const FieldBuilder({super.key, required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case "text":
      case "number": return buildTextField();
      case "upload": return buildUpload();
      case "coordinate": return buildCoordinate();
      default: return const SizedBox();
    }
  }

  Widget buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller.controllers[field.label],
          keyboardType: field.type == "number" ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: field.placeholder,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: field.fileValue.isNotEmpty ? Colors.green.withOpacity(0.05) : Colors.transparent,
            border: Border.all(color: field.fileValue.isNotEmpty ? Colors.green : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (field.isLoading.value)
                const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
              else
                Icon(
                  field.fileValue.isNotEmpty ? Icons.check_circle_outline : Icons.insert_drive_file_outlined,
                  size: 40,
                  color: field.fileValue.isNotEmpty ? Colors.green : Colors.grey,
                ),
              const SizedBox(height: 12),
              
              if (field.fileValue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text("File Terenkripsi Berhasil", style: TextStyle(color: Colors.green, fontSize: 11)),
                ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickAndUploadFile(field, ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text("Ambil", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickAndUploadFile(field, ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text("Galeri", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              )
            ],
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildCoordinate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on_outlined, size: 40, color: Colors.grey),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text("Deteksi", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_location_alt, size: 18),
                      label: const Text("Manual", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}