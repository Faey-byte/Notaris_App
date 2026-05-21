import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';

class CoordinateFieldWidget extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const CoordinateFieldWidget(
    this.field, {
    super.key,
    required this.controller,
  });

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
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Obx(() {
            final hasData = field.latitude.value != 0.0 && field.longitude.value != 0.0;
            
            return Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                color: Colors.grey[50],
              ),
              child: field.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 36,
                            color: hasData ? Colors.redAccent : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasData
                                ? "Latitude : ${field.latitude.value.toStringAsFixed(6)}\nLongitude: ${field.longitude.value.toStringAsFixed(6)}"
                                : "Titik Koordinat Belum Ditentukan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
                              color: hasData ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.getCurrentLocation(field),
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text("Deteksi"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.openManualLocationPicker(field),
                  icon: const Icon(Icons.edit_location_alt),
                  label: const Text("Manual"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}