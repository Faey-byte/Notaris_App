import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class DynamicField {
  final String label;
  final String type;
  final String? placeholder;
  var fileValue = "".obs; 
  var isLoading = false.obs;

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
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    generateForm();
  }

  void generateForm() {
    if (jenis == "AJB") {
      fields.value = [
        DynamicField(label: "Nama Klien / Nama Perusahaan", type: "text", placeholder: "Masukkan nama klien atau perusahaan"),
        DynamicField(label: "Sertifikat Asli", type: "upload"),
        DynamicField(label: "KTP Pemilik Sertifikat", type: "upload"),
        DynamicField(label: "Bukti Kepemilikan", type: "upload"),
      ];
    } else {
      fields.value = [DynamicField(label: "Data Default", type: "text", placeholder: "Belum ada form")];
    }

    for (var field in fields) {
      if (field.type == "text") {
        controllers[field.label] = TextEditingController();
      }
    }
  }

  Future<void> pickAndUploadFile(DynamicField field, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      
      if (pickedFile != null) {
        field.isLoading.value = true;
        File file = File(pickedFile.path);
        String fileName = p.basename(file.path);

        final response = await http.post(
          Uri.parse('https://virtserver.swaggerhub.com/MikhaelJhon/notary/1.0.0/api/v1/make-url'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'file_name': fileName}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          field.fileValue.value = data['url'] ?? ""; 
          Get.snackbar("Sukses", "${field.label} berhasil diupload");
        } else {
          Get.snackbar("Error", "Gagal enkripsi file: ${response.statusCode}");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      field.isLoading.value = false;
    }
  }

  void submitForm() {
    Map<String, dynamic> body = {};
    for (var field in fields) {
      if (field.type == "text") {
        if (controllers[field.label]!.text.isEmpty) {
          Get.snackbar("Error", "${field.label} wajib diisi");
          return;
        }
        body[field.label] = controllers[field.label]!.text;
      } else if (field.type == "upload") {
        if (field.fileValue.isEmpty) {
          Get.snackbar("Error", "Mohon upload ${field.label}");
          return;
        }
        body[field.label] = field.fileValue.value;
      }
    }
    print("READY UNTUK GRAPHQL: $body");
    Get.snackbar("Sukses", "Data siap dikirim ke database");
  }

  @override
  void onClose() {
    for (var c in controllers.values) { c.dispose(); }
    super.onClose();
  }
}