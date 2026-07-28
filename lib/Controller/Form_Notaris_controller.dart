import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class NotarisDocField {
  final String label;
  var fileValue = ''.obs;
  var matchKey = ''.obs;
  var publicId = ''.obs;
  var localFilePath = ''.obs;
  var isLoading = false.obs;

  NotarisDocField({required this.label});
}

class NotarisFormController extends GetxController {
  late final DbHelper dbHelper;
  final ImagePicker _picker = ImagePicker();

  late final String berkasId;

  var _token = "".obs;

  var jenisPekerjaan = 'original'.obs;

  final namaKlienCtrl = TextEditingController();
  final nomorAktaCtrl = TextEditingController();
  final biayaCtrl = TextEditingController();
  final namaStaffCtrl = TextEditingController();

  final List<String> jenisPekerjaanOptions = [
    "Akta Pendirian PT",
    "Akta Pendirian CV",
    "Akta Yayasan",
    "Akta Kuasa",
    "Legalisasi Dokumen",
  ];

  var docFields = <NotarisDocField>[
    NotarisDocField(label: 'KTP (Pemilik/Direktur)'),
    NotarisDocField(label: 'Kartu Keluarga'),
    NotarisDocField(label: 'NPWP'),
  ].obs;

  static const String baseUrl = "${ApiConfig.baseUrl}";

  @override
  void onInit() {
    dbHelper = DbHelper();
    berkasId = "NOTARIS_${DateTime.now().millisecondsSinceEpoch}";
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token.value = prefs.getString('auth_token') ?? "";
  }

  void addExtraDocField(String label) {
    if (label.trim().isEmpty) return;
    docFields.add(NotarisDocField(label: label.trim()));
  }

  void removeDocField(NotarisDocField field) {
    docFields.remove(field);
  }

  Future<void> pickAndUploadFile(
    NotarisDocField field,
    ImageSource source,
  ) async {
    try {
      if (jenisPekerjaan.value.isEmpty) {
        Get.snackbar(
          "Peringatan",
          "Pilih jenis pekerjaan dulu sebelum upload dokumen",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      field.localFilePath.value = pickedFile.path;
      field.isLoading.value = true;

      final file = File(pickedFile.path);

      final prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('auth_token') ?? "";
      _token.value = currentToken;

      if (currentToken.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/make-notary-url'),
      );
      request.headers['Authorization'] = 'Bearer $currentToken';

      request.fields['notary_type'] = jenisPekerjaan.value;

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          filename: p.basename(file.path),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception(
          "Server Error (${response.statusCode}): ${response.body}",
        );
      }

      print("🚀 [NOTARIS UPLOAD] Response mentah: ${response.body}");

      final decoded = jsonDecode(response.body);
      Map<String, dynamic>? targetFileData;

      if (decoded != null && decoded['files'] != null) {
        final filesData = decoded['files'];

        if (filesData is Map &&
            filesData['files'] != null &&
            filesData['files'] is List) {
          final List innerList = filesData['files'];
          if (innerList.isNotEmpty && innerList[0] is Map) {
            targetFileData = innerList[0] as Map<String, dynamic>;
          }
        } else if (filesData is List && filesData.isNotEmpty) {
          final firstElement = filesData[0];
          if (firstElement is Map &&
              firstElement['files'] != null &&
              firstElement['files'] is List) {
            final List innerList = firstElement['files'];
            if (innerList.isNotEmpty && innerList[0] is Map) {
              targetFileData = innerList[0] as Map<String, dynamic>;
            }
          } else if (firstElement is Map<String, dynamic>) {
            targetFileData = firstElement;
          }
        }
      }

      if (targetFileData == null) {
        throw Exception("Gagal mengekstrak struktur file dari response.");
      }

      final extractedUrl = targetFileData['url'] ?? "";
      final extractedMatchKey = targetFileData['matchkey'] ?? "";
      final extractedFileId = targetFileData['id']?.toString() ?? "";

      field.fileValue.value = extractedUrl;
      field.matchKey.value = extractedMatchKey;
      field.publicId.value = extractedFileId;
      docFields.refresh();

      await dbHelper.saveNotarisDraft({
        'id_field': "${berkasId}_${field.label}",
        'berkas_id': extractedFileId,
        'jenis_pekerjaan': jenisPekerjaan.value,
        'label': field.label,
        'url': extractedUrl,
        'matchkey': extractedMatchKey,
        'local_path': file.path,
        'text_value': null,
      });

      print(
        "💾 [NOTARIS] Tersimpan -> label: ${field.label}, "
        "url: $extractedUrl, matchkey: $extractedMatchKey, publicId: $extractedFileId",
      );

      Get.snackbar("Sukses", "${field.label} berhasil diupload");
    } catch (e) {
      print("❌ [NOTARIS UPLOAD ERROR]: $e");
      Get.snackbar(
        "Upload Gagal",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      field.isLoading.value = false;
    }
  }

  Future<void> _saveTextFields() async {
    await dbHelper.saveNotarisDraft({
      'id_field': "${berkasId}_Jenis Pekerjaan",
      'berkas_id': berkasId,
      'jenis_pekerjaan': jenisPekerjaan.value,
      'label': 'Jenis Pekerjaan',
      'text_value': jenisPekerjaan.value,
      'url': null,
      'matchkey': null,
      'local_path': null,
    });

    final Map<String, TextEditingController> textMap = {
      'Nama Klien/Perusahaan': namaKlienCtrl,
      'Nomor Akta': nomorAktaCtrl,
      'Total Biaya Layanan': biayaCtrl,
      'Nama Staff': namaStaffCtrl,
    };

    for (var entry in textMap.entries) {
      if (entry.value.text.isEmpty) continue;
      await dbHelper.saveNotarisDraft({
        'id_field': "${berkasId}_${entry.key}",
        'berkas_id': berkasId,
        'jenis_pekerjaan': jenisPekerjaan.value,
        'label': entry.key,
        'text_value': entry.value.text,
        'url': null,
        'matchkey': null,
        'local_path': null,
      });
    }
  }

  bool validateFields() {
    if (jenisPekerjaan.value.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Pilih jenis pekerjaan dulu",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (namaKlienCtrl.text.isEmpty ||
        nomorAktaCtrl.text.isEmpty ||
        namaStaffCtrl.text.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Lengkapi dulu semua kolom teks",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    for (var field in docFields) {
      if (field.fileValue.value.isEmpty) {
        Get.snackbar(
          "Peringatan",
          "${field.label} belum diupload",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submitToServer() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('auth_token') ?? "";

    final instituteId = prefs.getInt('institute_id') ?? 0;

    if (currentToken.isEmpty) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    final publicIds = <String>[];
    final metadata = <Map<String, dynamic>>[];

    for (var field in docFields) {
      if (field.publicId.value.isNotEmpty) {
        publicIds.add(field.publicId.value);
        metadata.add({"label": field.label, "url": field.fileValue.value});
      }
    }

    final body = jsonEncode({
      "institude_id": 1,
      "public_ids": publicIds,
      "staff_name": namaStaffCtrl.text,
      "client_name": namaKlienCtrl.text,
      "notary_type": jenisPekerjaan.value,
      "life_status": "single",
      "metadata": metadata,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/upload-notary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentToken',
      },
      body: body,
    );

    print("🚀 [NOTARIS SUBMIT] Response mentah: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Server Error (${response.statusCode}): ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);
    final message = decoded['message'] ?? "upload success";
    final isExisting = decoded['is_existing'] ?? false;

    print(
      "🎊 [NOTARIS] SUBMIT KE SERVER SUKSES -> message: $message, "
      "is_existing: $isExisting, public_ids: ${decoded['public_ids']}",
    );
  }

  Future<void> submitForm() async {
    if (!validateFields()) return;

    try {
      await _saveTextFields();
      await _submitToServer();

      print(
        "🎊 [NOTARIS] SEMUA DATA TERSIMPAN & TERKIRIM. berkasId: $berkasId",
      );

      Get.snackbar(
        "Sukses",
        "Berkas notaris berhasil dikirim (ID: $berkasId)",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/Notaris');
    } catch (e) {
      print("❌ [NOTARIS SUBMIT ERROR]: $e");
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    namaKlienCtrl.dispose();
    nomorAktaCtrl.dispose();
    biayaCtrl.dispose();
    namaStaffCtrl.dispose();
    super.onClose();
  }
}
