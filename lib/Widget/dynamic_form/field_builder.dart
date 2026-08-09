import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';
import '../../Widget/dynamic_form/upload_field_widget.dart';

class FieldBuilder extends StatefulWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const FieldBuilder({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  State<FieldBuilder> createState() => _FieldBuilderState();
}

class _FieldBuilderState extends State<FieldBuilder> {
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  bool showInputForm = false;

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
    switch (widget.field.type) {
      case "text":
      case "number":
        return buildTextField();
      case "upload":
        return buildUpload();
      case "coordinate":
        return buildCoordinate();
      case "date": // NEW
        return buildDate();
      default:
        return const SizedBox();
    }
  }

  // =========================================================
  // LABEL dengan bintang merah (*) kalau field wajib masih kosong
  // dan user sudah pernah menekan tombol submit/lanjut.
  // =========================================================
  Widget _buildLabel(DynamicField field) {
    return Obx(() {
      final bool showStar = widget.controller.attemptedSubmit.value &&
          widget.controller.isFieldEmpty(field);

      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
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
    });
  }

  Widget buildTextField() {
    final bool isMoneyField =
        DynamicFormController.moneyFieldLabels.contains(widget.field.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(widget.field),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller.controllers[widget.field.label],
          keyboardType: widget.field.type == "number"
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: isMoneyField
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ]
              : null,
          onChanged: (_) {
            // Supaya bintang merah langsung update (hilang/muncul)
            // secara real-time saat user mengetik, tanpa menunggu submit.
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: widget.field.placeholder,
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

  Widget buildUpload() {
    return UploadFieldWidget(
      widget.field,
      controller: widget.controller,
    );
  }

  // =========================================================
  // DATE (NEW) — e.g. "Tanggal Akta" / deed_date
  // Styled to match buildCoordinate(): icon + status text + action button.
  // =========================================================
  Widget buildDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(widget.field),
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
              Obx(() {
                final selectedDate = widget.field.dateValue.value;
                final hasDate = selectedDate != null;

                final displayText = hasDate
                    ? "${selectedDate!.day.toString().padLeft(2, '0')}/"
                        "${selectedDate.month.toString().padLeft(2, '0')}/"
                        "${selectedDate.year}"
                    : "Tanggal Belum Dipilih";

                return Column(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await widget.controller.pickDeedDate(widget.field);
                    // Update bintang merah setelah tanggal dipilih.
                    setState(() {});
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text("Pilih Tanggal"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildCoordinate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(widget.field),
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

              Obx(() {
                final bool hasData = widget.field.latitude.value != 0.0 &&
                    widget.field.longitude.value != 0.0;

                if (widget.field.isLoading.value) {
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
                      color: hasData ? AppColors.primary : AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasData
                          ? "Latitude: ${widget.field.latitude.value.toStringAsFixed(6)}\nLongitude: ${widget.field.longitude.value.toStringAsFixed(6)}"
                          : "Titik Koordinat Belum Ditentukan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
                        color: hasData ? Colors.black : Colors.black,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              if (!showInputForm)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        showInputForm = true;
                      });
                    },
                    icon: const Icon(Icons.edit_location_alt),
                    label: const Text("Input Koordinat"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),

              if (showInputForm) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Input Koordinat Secara Manual",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showInputForm = false;
                              });
                            },
                            icon: const Icon(Icons.close),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                            decimal: true),
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
              ],

              if (showInputForm) const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await widget.controller
                        .openManualLocationPicker(widget.field);
                    // Update bintang merah setelah lokasi dipilih dari map.
                    setState(() {});
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("Pilih Dari Map"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
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

      print("✅ === KOORDINAT BERHASIL DISIMPAN ===");
      print("Latitude  : $latitude");
      print("Longitude : $longitude");
      print("Format    : $latitude,$longitude");
      print("=====================================\n");

      latitudeController.clear();
      longitudeController.clear();
      setState(() {
        showInputForm = false;
      });

      Get.snackbar(
        "Berhasil",
        "Koordinat berhasil disimpan!\nLat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      widget.controller.fields.refresh();
    } catch (e) {
      print("❌ [COORDINATE INPUT ERROR]: $e");
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}