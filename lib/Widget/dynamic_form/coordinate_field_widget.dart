import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/Model/dynamic_field_model.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/utils/logger.dart';

class CoordinateFieldWidget extends StatefulWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const CoordinateFieldWidget(
    this.field, {
    super.key,
    required this.controller,
  });

  @override
  State<CoordinateFieldWidget> createState() => _CoordinateFieldWidgetState();
}

class _CoordinateFieldWidgetState extends State<CoordinateFieldWidget> {
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

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
            widget.field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Obx(() {
            final hasData =
                widget.field.latitude.value != 0.0 &&
                widget.field.longitude.value != 0.0;

            return Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                color: Colors.grey[50],
              ),
              child: widget.field.isLoading.value
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
                                ? "Latitude : ${widget.field.latitude.value.toStringAsFixed(6)}\nLongitude: ${widget.field.longitude.value.toStringAsFixed(6)}"
                                : "Titik Koordinat Belum Ditentukan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasData
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: hasData
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              color: Colors.blue[50],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Input Koordinat Secara Manual",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: "-6.175392",
                    labelText: "Latitude",
                    prefixIcon: const Icon(Icons.north),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: "106.827153",
                    labelText: "Longitude",
                    prefixIcon: const Icon(Icons.east),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveCoordinateFromInput(),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Simpan Koordinat"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  widget.controller.openManualLocationPicker(widget.field),
              icon: const Icon(Icons.map),
              label: const Text("Pilih Dari Map"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCoordinateFromInput() async {
    try {
      final latitudeText = latitudeController.text.trim();
      final longitudeText = longitudeController.text.trim();

      if (latitudeText.isEmpty || longitudeText.isEmpty) {
        Get.snackbar(
          "Input Tidak Lengkap",
          "Silakan isi Latitude dan Longitude",
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      final latitude = double.tryParse(latitudeText);
      final longitude = double.tryParse(longitudeText);

      if (latitude == null || longitude == null) {
        Get.snackbar(
          "Format Tidak Valid",
          "Latitude dan Longitude harus berupa angka desimal",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      if (latitude < -90 || latitude > 90) {
        Get.snackbar(
          "Latitude Tidak Valid",
          "Latitude harus antara -90 dan 90",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      if (longitude < -180 || longitude > 180) {
        Get.snackbar(
          "Longitude Tidak Valid",
          "Longitude harus antara -180 dan 180",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      widget.field.latitude.value = latitude;
      widget.field.longitude.value = longitude;

      await widget.controller.dbHelper.saveDraft({
        'id_field': "${widget.controller.jenis}_${widget.field.label}",
        'jenis_pekerjaan': widget.controller.jenis,
        'label': widget.field.label,
        'text_value': "$latitude,$longitude",
      });

      AppLogger.log("✅ === KOORDINAT BERHASIL DISIMPAN ===");
      AppLogger.log("Latitude  : $latitude");
      AppLogger.log("Longitude : $longitude");
      AppLogger.log("Format    : $latitude,$longitude");
      AppLogger.log("=====================================\n");

      latitudeController.clear();
      longitudeController.clear();

      Get.snackbar(
        "Berhasil",
        "Koordinat berhasil disimpan!\nLat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      widget.controller.fields.refresh();
    } catch (e) {
      AppLogger.log("❌ [COORDINATE INPUT ERROR]: $e");
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
