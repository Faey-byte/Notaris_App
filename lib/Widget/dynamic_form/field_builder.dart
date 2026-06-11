import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';
import '../../Widget/dynamic_form/upload_field_widget.dart'; // 1. Pastikan path import ke UploadFieldWidget ini sudah benar

class FieldBuilder extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const FieldBuilder({super.key, required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case "text":
      case "number": return buildTextField();
      case "upload": return buildUpload(); // Ini akan memanggil fungsi di bawah
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

  // 2. Fungsi buildUpload diperbaiki untuk menggunakan widget khusus pratinjau gambar yang sudah mendukung Obx
  Widget buildUpload() {
    return UploadFieldWidget(
      field,
      controller: controller, // Mengoper controller bertag ke sub-widget agar sinkron
    );
  }

  // 🔥 UPDATE: Fungsi buildCoordinate yang sudah interaktif dan reaktif
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
            color: AppColors.white,
          ),
          child: Column(
            children: [
              // 🔥 Menggunakan Obx agar ikon dan teks koordinat berubah secara real-time
              Obx(() {
                final bool hasData = field.latitude.value != 0.0 && field.longitude.value != 0.0;

                if (field.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: [
                    Icon(
                      Icons.location_on, 
                      size: 40, 
                      color: hasData ? Colors.redAccent : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasData
                          ? "Latitude: ${field.latitude.value.toStringAsFixed(6)}\nLongitude: ${field.longitude.value.toStringAsFixed(6)}"
                          : "Titik Koordinat Belum Ditentukan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
                        color: hasData ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      // 🔥 Dihubungkan ke fungsi pencarian lokasi otomatis GPS
                      onPressed: () => controller.getCurrentLocation(field),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text("Deteksi", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      // 🔥 Dihubungkan ke simulasi input manual
                      onPressed: () => controller.openManualLocationPicker(field),
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