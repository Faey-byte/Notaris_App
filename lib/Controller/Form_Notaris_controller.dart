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

// NEW: represents one entry of entities.PenghadapRequest
// { public_id, name, order_number, title }
class NotarisPenghadap {
  /// Sent to backend as `public_id`. Generated client-side so it stays
  /// stable while the user edits name/title, and unique across entries.
  final String publicId;

  int orderNumber;

  final TextEditingController nameCtrl;
  final TextEditingController titleCtrl;

  NotarisPenghadap({
    required this.publicId,
    required this.orderNumber,
  })  : nameCtrl = TextEditingController(),
        titleCtrl = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      "public_id": publicId,
      "name": nameCtrl.text.trim(),
      "order_number": orderNumber,
      "title": titleCtrl.text.trim(),
    };
  }

  void dispose() {
    nameCtrl.dispose();
    titleCtrl.dispose();
  }
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

  // NEW: akta_nature — free text, required by backend
  final aktaNatureCtrl = TextEditingController();

  // NEW: akta_date — required by backend, previously missing entirely
  // from the form. Stored as a DateTime (like DynamicFormController's
  // deedDate pattern) and sent as "dd/MM/yyyy" on submit.
  var aktaDateValue = Rxn<DateTime>();

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

  // NEW: dynamic list of "penghadap" (parties appearing in the deed).
  // Backend requires at least 1.
  var penghadapList = <NotarisPenghadap>[].obs;

  static const String baseUrl = "${ApiConfig.baseUrl}";

  @override
  void onInit() {
    dbHelper = DbHelper();
    berkasId = "NOTARIS_${DateTime.now().millisecondsSinceEpoch}";
    super.onInit();
    _loadToken();

    // Start with one penghadap row so the form isn't empty
    // (backend rejects an empty penghadap array).
    addPenghadap();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token.value = prefs.getString('auth_token') ?? "";
    print("🔑 [TOKEN LOADED]: ${_token.value}");
  }

  /// Helper untuk mengambil ID (user_id) dari token via endpoint convert
  Future<int?> _fetchUserId(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/convert/tokenTo/ID'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['user_id'] as int?;
      } else {
        print("❌ [CONVERT TOKEN FAILED]: (${response.statusCode}) ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ [CONVERT TOKEN ERROR]: $e");
      return null;
    }
  }

  void addExtraDocField(String label) {
    if (label.trim().isEmpty) return;
    docFields.add(NotarisDocField(label: label.trim()));
  }

  void removeDocField(NotarisDocField field) {
    docFields.remove(field);
  }

  // =========================================================
  // Tanggal Akta (akta_date) picker
  // =========================================================
  Future<void> pickAktaDate() async {
    try {
      final context = Get.context;
      if (context == null) return;

      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: aktaDateValue.value ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5),
      );

      if (picked == null) return;

      aktaDateValue.value = picked;
    } catch (e) {
      Get.snackbar(
        "Gagal Memilih Tanggal",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Formats aktaDateValue as "dd/MM/yyyy"
  String _formatAktaDate() {
    final d = aktaDateValue.value;
    if (d == null) return "";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return "$dd/$mm/$yyyy";
  }

  // =========================================================
  // Penghadap management
  // =========================================================

  void addPenghadap() {
    final orderNumber = penghadapList.length + 1;
    penghadapList.add(
      NotarisPenghadap(
        publicId:
            "PENGHADAP_${DateTime.now().millisecondsSinceEpoch}_$orderNumber",
        orderNumber: orderNumber,
      ),
    );
  }

  void removePenghadap(NotarisPenghadap item) {
    if (penghadapList.length <= 1) {
      Get.snackbar(
        "Peringatan",
        "Minimal harus ada 1 penghadap",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    item.dispose();
    penghadapList.remove(item);
    _reorderPenghadap();
  }

  void _reorderPenghadap() {
    for (int i = 0; i < penghadapList.length; i++) {
      penghadapList[i].orderNumber = i + 1;
    }
    penghadapList.refresh();
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

      print("🔑 [NOTARIS UPLOAD TOKEN]: $currentToken");

      if (currentToken.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      // 1. Fetch user_id dari token
      final userId = await _fetchUserId(currentToken);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/make-notary-url'),
      );
      request.headers['Authorization'] = 'Bearer $currentToken';

      request.fields['notary_type'] = jenisPekerjaan.value;

      // 2. Sertakan user_id pada request jika berhasil didapatkan
      if (userId != null) {
        request.fields['user_id'] = userId.toString();
      }

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

    if (aktaNatureCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Sifat/Jenis Akta belum diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (aktaDateValue.value == null) {
      Get.snackbar(
        "Peringatan",
        "Tanggal Akta belum dipilih",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (penghadapList.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Minimal harus ada 1 penghadap",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    for (var penghadap in penghadapList) {
      if (penghadap.nameCtrl.text.trim().isEmpty ||
          penghadap.titleCtrl.text.trim().isEmpty) {
        Get.snackbar(
          "Peringatan",
          "Lengkapi nama dan title untuk setiap penghadap",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
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

  if (currentToken.isEmpty) {
    throw Exception("Token tidak ditemukan. Silakan login ulang.");
  }

  // ======================================================
  // Ambil user_id dari endpoint convert/tokenTo/ID
  // (sementara dipakai sebagai institute_id)
  // ======================================================
  final int? userId = await _fetchUserId(currentToken);

  if (userId == null) {
    throw Exception("Gagal mendapatkan user_id");
  }

  // sementara institute_id = user_id
  final int instituteId = userId;

  // =========================
  // BUILD METADATA
  // =========================
  final metadata = <Map<String, dynamic>>[];

  for (var field in docFields) {
    if (field.publicId.value.isNotEmpty) {
      metadata.add({
        "label": field.label,
        "url": field.fileValue.value,
      });
    }
  }

  // =========================
  // BUILD PENGHADAP
  // =========================
  final penghadapData =
      penghadapList.map((p) => p.toJson()).toList();

  // =========================
  // REQUEST BODY
  // =========================
  final Map<String, dynamic> bodyMap = {
    "clientName": namaKlienCtrl.text.trim(),

    // sementara memakai user_id
    "institude_id": instituteId,

    "staff_name": namaStaffCtrl.text.trim(),
    "amount": int.tryParse(biayaCtrl.text.trim()) ?? 0,
    "notary_type": jenisPekerjaan.value,
    "akta_nature": aktaNatureCtrl.text.trim(),
    "akta_date": _formatAktaDate(),
    "life_status": "single",
    "penghadap": penghadapData,
    "metadata": metadata,
  };

  final body = jsonEncode(bodyMap);

  print("========== NOTARY REQUEST ==========");
  print(body);
  print("====================================");

  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/upload-notary'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $currentToken',
    },
    body: body,
  );

  print("🚀 [NOTARIS SUBMIT] Response mentah:");
  print(response.body);

  if (response.statusCode != 200) {
    throw Exception(
      "Server Error (${response.statusCode}): ${response.body}",
    );
  }

  final decoded = jsonDecode(response.body);

  final message = decoded['message'] ?? "upload success";
  final isExisting = decoded['is_existing'] ?? false;
  final publicIDs = decoded['public_ids'] ?? [];

  print("========== NOTARY RESPONSE ==========");
  print("message      : $message");
  print("is_existing  : $isExisting");
  print("public_ids   : $publicIDs");
  print("====================================");
}

  Future<void> submitForm() async {
    if (!validateFields()) return;

    try {
      await _submitToServer();

      print(
        "🎊 [NOTARIS] DATA TERKIRIM. berkasId: $berkasId",
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
    aktaNatureCtrl.dispose();

    for (var penghadap in penghadapList) {
      penghadap.dispose();
    }

    super.onClose();
  }
}