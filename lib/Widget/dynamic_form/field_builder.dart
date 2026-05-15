import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';

class FieldBuilder extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const FieldBuilder({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case "text":
      case "number":
        return buildTextField();

      case "upload":
        return buildUpload();

      case "coordinate":
        return buildCoordinate();

      default:
        return const SizedBox();
    }
  }

  // 🔥 TEXT FIELD
  Widget buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.controllers[field.label],
          keyboardType: field.type == "number"
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: field.placeholder,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 🔥 UPLOAD UI
  Widget buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 40, color: Colors.grey),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Ambil"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.image_outlined),
                      label: const Text("Galeri"),
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

  // 🔥 COORDINATE UI
  Widget buildCoordinate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 40, color: Colors.grey),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.my_location),
                      label: const Text("Deteksi"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_location_alt),
                      label: const Text("Manual"),
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