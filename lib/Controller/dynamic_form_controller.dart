import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicField {
  final String label;
  final String type;
  final String? placeholder;

  DynamicField({
    required this.label,
    required this.type,
    this.placeholder,
  });
}

class DynamicFormController extends GetxController {
  final String jenis;

  DynamicFormController(this.jenis);

  var fields = <DynamicField>[].obs;
  var controllers = <String, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    print("JENIS MASUK: $jenis");
    generateForm();
  }

  void generateForm() {
    switch (jenis) {
      case "AJB":
        fields.value = [
          DynamicField(
            label: "Nama Klien / Nama Perusahaan",
            type: "text",
            placeholder: "Masukkan nama klien atau perusahaan",
          ),
          DynamicField(label: "Sertifikat Asli", type: "upload"),
          DynamicField(label: "KTP Pemilik Sertifikat", type: "upload"),
          DynamicField(label: "Bukti Kepemilikan", type: "upload"),
        ];
        break;

      default:
        fields.value = [
          DynamicField(
            label: "Data Default",
            type: "text",
            placeholder: "Belum ada form untuk jenis ini",
          ),
        ];
    }

    print("FIELDS KEISI: ${fields.length}");

    // init controller text
    for (var field in fields) {
      if (field.type == "text") {
        controllers[field.label] = TextEditingController();
      }
    }
  }

  void submitForm() {
    for (var field in fields) {
      if (field.type == "text") {
        final value = controllers[field.label]?.text ?? "";

        if (value.isEmpty) {
          Get.snackbar("Error", "${field.label} wajib diisi");
          return;
        }
      }
    }

    Get.snackbar("Sukses", "Berkas berhasil disimpan");
  }

  @override
  void onClose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}