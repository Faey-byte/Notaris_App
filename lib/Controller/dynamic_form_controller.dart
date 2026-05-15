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
    generateForm();
  }

  void generateForm() {
    if (jenis == "Jual Beli") {
      fields.value = [
        DynamicField(
          label: "Nama Klien / Nama Perusahaan",
          type: "text",
          placeholder: "Masukkan nama klien atau perusahaan",
        ),
        DynamicField(label: "Sertifikat Asli", type: "upload"),
        DynamicField(label: "KTP Pemilik Sertipikat", type: "upload"),
        DynamicField(label: "KK Pemilik Sertipikat", type: "upload"),
        DynamicField(label: "Surat Nikah", type: "upload"),
        DynamicField(label: "PBB Tahun Berjalan", type: "upload"),
        DynamicField(label: "Foto Objek", type: "upload"),
        DynamicField(label: "Titik Koordinat", type: "coordinate"),
        DynamicField(label: "KTP Pembeli", type: "upload"),
        DynamicField(label: "Total Biaya Layanan", type: "number"),
        DynamicField(
          label: "Nama Staff",
          type: "text",
          placeholder: "Masukkan nama staff",
        ),
      ];
    }

    for (var f in fields) {
      if (f.type == "text" || f.type == "number") {
        controllers[f.label] = TextEditingController();
      }
    }
  }

  void submit() {
    final data = {};

    for (var f in fields) {
      if (controllers.containsKey(f.label)) {
        data[f.label] = controllers[f.label]!.text;
      }
    }

    print(data);
  }
}