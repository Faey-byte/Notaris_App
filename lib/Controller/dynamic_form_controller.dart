import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Pages/map_picker_page.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:path/path.dart' as p;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DynamicField {
  final String label;
  final String type;
  final String placeholder;

  var fileValue = ''.obs;
  var fileId = ''.obs;
  var matchKey = ''.obs;
  var isLoading = false.obs;
  var localFilePath = ''.obs;

  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  bool get isImageFile => true;

  DynamicField({
    required this.label,
    required this.type,
    required this.placeholder,
  });
}

class DynamicFormController extends GetxController {
  final String jenis;
  DynamicFormController(this.jenis);

  var fields = <DynamicField>[].obs;
  var controllers = <String, TextEditingController>{};

  final ImagePicker _picker = ImagePicker();
  final DbHelper _dbHelper = DbHelper();

  var lifeStatus = "".obs;
  var _token = "".obs;

  final List<String> lifeStatusOptions = [
    "single",
    "married",
    "divorced",
    "widowed",
  ];

  final String baseUrl =
      'https://clause-structure-ran-scholarships.trycloudflare.com';

  @override
  void onInit() {
    super.onInit();
    _initFormWithToken();
  }

  Future<void> _initFormWithToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _token.value = prefs.getString('auth_token') ?? "";
      debugPrint("Token SharedPreferences Berhasil Dimuat: ${_token.value}");
    } catch (e) {
      debugPrint("Gagal mengambil token dari SharedPreferences: $e");
    }

    generateForm();
    loadSavedDraft();
  }

  void _clearControllers() {
    for (var c in controllers.values) {
      c.dispose();
    }
    controllers.clear();
  }

  void generateForm() {
    final Map<String, List<Map<String, String>>> ppatRequirements = {
      "AJB": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilk Sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Kematian (jika pasangan meninggal)", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "KTP Pembeli", "type": "upload"},
        {"label": "KK Pembeli", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "APHB": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilk Sertipikat", "type": "upload"},
        {"label": "Akta Kematian (jika pasangan meninggal)", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "SKMHT": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilk Sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Kematian (jika pasangan meninggal)", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "KTP Kreditur (Pimpinan Bank)", "type": "upload"},
        {"label": "KK Kreditur (Pimpinan Bank)", "type": "upload"},
        {"label": "Perjanjian Kredit", "type": "upload"},
        {"label": "SK Pimpinan Bank / Akta Pendirian", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "APHT": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilk Sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Kematian & Ket. Belum Menikah Lagi", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "KTP Kreditur (Pimpinan Bank)", "type": "upload"},
        {"label": "KK Kreditur (Pimpinan Bank)", "type": "upload"},
        {"label": "Perjanjian Kredit", "type": "upload"},
        {"label": "SK Pimpinan Bank / Akta Pendirian", "type": "upload"},
        {"label": "SKMHT", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Hibah": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilk Sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Kematian & Ket. Belum Menikah Lagi", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "KTP Penerima Hibah", "type": "upload"},
        {"label": "KK Penerima Hibah", "type": "upload"},
        {"label": "Surat Pernyataan Persetujuan Anak", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Tukar Menukar": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilik Sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Kematian & Ket. Belum Menikah Lagi", "type": "upload"},
        {
          "label": "Surat Keterangan Kelurahan (jika belum menikah)",
          "type": "upload",
        },
        {"label": "NPWP Pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Turun Waris": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "Akta Kematian pemilik Sertipikat", "type": "upload"},
        {"label": "Surat Keterangan Waris", "type": "upload"},
        {"label": "KTP seluruh ahli waris", "type": "upload"},
        {"label": "KK seluruh ahli waris", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "APHW": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat Asli", "type": "upload"},
        {"label": "Akta Kematian pemilik Sertipikat", "type": "upload"},
        {"label": "Surat Keterangan Waris", "type": "upload"},
        {"label": "Surat Pernyataan / Akta pembagian waris", "type": "upload"},
        {"label": "KTP seluruh ahli waris", "type": "upload"},
        {"label": "KK seluruh ahli waris", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "VALIDASI": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP pemilik/ahli waris", "type": "upload"},
        {"label": "Surat keterangan waris (jika meninggal)", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "ROYA": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP pemilik/ahli waris", "type": "upload"},
        {"label": "Surat Keterangan waris (jika meninggal)", "type": "upload"},
        {"label": "Sertipikat Hak Tanggungan", "type": "upload"},
        {"label": "Surat Roya", "type": "upload"},
        {"label": "PBB Tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Ralat Data": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP Pemilik sertipikat", "type": "upload"},
        {"label": "KK pemilik sertipikat", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Surat Keterangan dari kelurahan", "type": "upload"},
        {"label": "Surat Kronologi", "type": "upload"},
        {"label": "Data Pendukung (Akta Lahir/Nikah/Ijazah)", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Ganti Nama Kreditur": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP pemilik sertipikat", "type": "upload"},
        {"label": "KK pemilik sertipikat", "type": "upload"},
        {"label": "Akta Pendirian Bank (perubahan terakhir)", "type": "upload"},
        {"label": "Surat OJK", "type": "upload"},
        {"label": "PBB Tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Sertipikat Hak Tanggungan", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Ganti Blanko": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP Pemilik sertipikat", "type": "upload"},
        {"label": "KK Pemilik sertipikat", "type": "upload"},
        {"label": "Gambar Sket", "type": "upload"},
        {"label": "KTP pemilik perbatasan tanah", "type": "upload"},
        {"label": "Surat kelurahan", "type": "upload"},
        {"label": "PBB Tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Titik koordinat", "type": "coordinate"},
        {"label": "Foto patok Geo-tagging", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "Lelang": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP Pemilik sertipikat", "type": "upload"},
        {"label": "KK Pemilik sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Risalah Lelang", "type": "upload"},
        {"label": "Bukti Bayar SSP", "type": "upload"},
        {"label": "PBB Tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "KTP Pemenang Lelang", "type": "upload"},
        {"label": "KK Pemenang Lelang", "type": "upload"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
      "WAKAF": [
        {"label": "Nama Client/Perusahaan", "type": "text"},
        {"label": "Sertipikat asli", "type": "upload"},
        {"label": "KTP Pemilik sertipikat (suami istri)", "type": "upload"},
        {"label": "KK Pemilik sertipikat", "type": "upload"},
        {"label": "Surat Nikah", "type": "upload"},
        {"label": "Akta Ikrar Wakaf (PPAIW)", "type": "upload"},
        {"label": "PBB tahun berjalan", "type": "upload"},
        {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
        {"label": "Foto Objek", "type": "upload"},
        {"label": "Titik Koordinat", "type": "coordinate"},
        {"label": "Total biaya layanan", "type": "number"},
        {"label": "Nama Staff", "type": "text"},
      ],
    };

    final requirementList =
        ppatRequirements[jenis] ??
        [
          {"label": "Data Default", "type": "text"},
        ];

    fields.value = requirementList.map((item) {
      return DynamicField(
        label: item["label"]!,
        type: item["type"]!,
        placeholder: "Masukkan ${item["label"]}",
      );
    }).toList();

    for (var field in fields) {
      if (field.type == "text" || field.type == "number") {
        controllers[field.label] = TextEditingController();
      }
    }
  }

  DynamicField? _findField(String label) {
    for (final f in fields) {
      if (f.label == label) return f;
    }
    return null;
  }

  Future<void> loadSavedDraft() async {
    try {
      final savedData = await _dbHelper.getDraftByJenis(jenis);
      if (savedData.isEmpty) return;

      for (var data in savedData) {
        final field = _findField(data['label'] ?? '');
        if (field == null) continue;

        if (field.type == "upload") {
          field.fileValue.value = data['url'] ?? "";
          field.fileId.value = data['file_id'] ?? "";
          field.matchKey.value = data['matchkey'] ?? "";

          if (data['local_path'] != null &&
              data['local_path'].toString().isNotEmpty) {
            field.localFilePath.value = data['local_path'];
          }
        } else if (field.type == "coordinate") {
          final savedValue = data['text_value'] ?? data['value'];
          if (savedValue != null && savedValue.toString().contains(',')) {
            final parts = savedValue.toString().split(',');
            field.latitude.value = double.tryParse(parts[0]) ?? 0.0;
            field.longitude.value = double.tryParse(parts[1]) ?? 0.0;
          }
        } else {
          controllers[field.label]?.text =
              data['text_value'] ?? data['value'] ?? "";
        }
      }
    } catch (e) {
      debugPrint("Error loading draft: $e");
    }
  }

  Future<void> pickAndUploadFile(DynamicField field, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      field.localFilePath.value = pickedFile.path;
      field.isLoading.value = true;

      final file = File(pickedFile.path);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('auth_token') ?? "";
      _token.value = currentToken;

      if (currentToken.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/make-url'),
      );

      request.headers['Authorization'] = 'Bearer $currentToken';
      request.fields['ppat_type'] = jenis;

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

      if (targetFileData != null) {
        field.fileValue.value = targetFileData['url'] ?? "";
        field.fileId.value = targetFileData['id']?.toString() ?? "";
        field.matchKey.value =
            targetFileData['new_chain_key'] ?? targetFileData['matchkey'] ?? "";
      } else {
        throw Exception("Gagal mengekstrak struktur file.");
      }

      fields.refresh();

      await _dbHelper.saveDraft({
        'id_field': "${jenis}_${field.label}",
        'jenis_pekerjaan': jenis,
        'label': field.label,
        'file_id': field.fileId.value,
        'matchkey': field.matchKey.value,
        'url': field.fileValue.value,
        'text_value': field.fileValue.value,
      });

      Get.snackbar("Sukses", "${field.label} tersimpan");
    } catch (e) {
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

  Future<void> getCurrentLocation(DynamicField field) async {
    try {
      field.isLoading.value = true;
      fields.refresh();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("GPS Anda mati. Silakan aktifkan lokasi perangkat.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Izin akses lokasi ditolak oleh pengguna.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Izin lokasi ditolak permanen. Ubah di pengaturan HP.");
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      field.latitude.value = position.latitude;
      field.longitude.value = position.longitude;

      await _dbHelper.saveDraft({
        'id_field': "${jenis}_${field.label}",
        'jenis_pekerjaan': jenis,
        'label': field.label,
        'text_value': "${position.latitude},${position.longitude}",
      });

      fields.refresh();

      Get.snackbar(
        "Berhasil",
        "Koordinat objek berhasil diparsing!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      if (errorMessage.contains("Timeout")) {
        errorMessage =
            "Gagal mendapatkan lokasi: Waktu pencarian habis. Gunakan opsi 'Manual'.";
      }

      Get.snackbar(
        "Gagal Mendeteksi",
        errorMessage,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      field.isLoading.value = false;
      fields.refresh();
    }
  }

  Future<void> openManualLocationPicker(DynamicField field) async {
    try {
      field.isLoading.value = true;
      fields.refresh();

      final pickedResult = await Get.to<LatLng>(
        () => MapPickerPage(
          initialLat: field.latitude.value == 0.0
              ? -6.175392
              : field.latitude.value,
          initialLng: field.longitude.value == 0.0
              ? 106.827153
              : field.longitude.value,
        ),
      );

      if (pickedResult != null) {
        field.latitude.value = pickedResult.latitude;
        field.longitude.value = pickedResult.longitude;

        await _dbHelper.saveDraft({
          'id_field': "${jenis}_${field.label}",
          'jenis_pekerjaan': jenis,
          'label': field.label,
          'text_value': "${pickedResult.latitude},${pickedResult.longitude}",
        });

        fields.refresh();

        Get.snackbar(
          "Berhasil",
          "Lokasi manual berhasil diparsing ke koordinat form!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        debugPrint("Pemilihan lokasi manual dibatalkan oleh pengguna.");
      }
    } catch (e) {
      Get.snackbar(
        "Gagal Mengambil Lokasi",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      field.isLoading.value = false;
      fields.refresh();
    }
  }

  Future<void> submitForm() async {
    final files = fields
        .where((f) => f.type == "upload" && f.fileValue.value.isNotEmpty)
        .map((f) => {"name": f.label, "url": f.fileValue.value})
        .toList();

    final coordinateField = fields.firstWhereOrNull(
      (f) => f.type == "coordinate",
    );
    double targetLat = coordinateField?.latitude.value ?? -6.175392;
    double targetLng = coordinateField?.longitude.value ?? 106.827153;

    final metadata = {
      "amount":
          int.tryParse(controllers["Total biaya layanan"]?.text ?? "0") ?? 0,
      "files": files,
      "location": {"latitude": targetLat, "longitude": targetLng},
    };

    final variables = {
      "client_name": controllers["Nama Client/Perusahaan"]?.text ?? "Agus",
      "public_ids": ["CLIENT_${DateTime.now().millisecondsSinceEpoch}"],
      "ppat_type": jenis,
      "life_status": "married",
      "metadata": metadata,
    };

    try {
      const mutation = r'''
        mutation UploadAsset(
          $client_name: String!,
          $public_ids: [String!]!,
          $ppat_type: String!,
          $metadata: JSON!,
          $life_status: String!
        ) {
          uploadAsset(
            client_name: $client_name,
            public_ids: $public_ids,
            ppat_type: $ppat_type,
            metadata: $metadata,
            life_status: $life_status
          ) {
            message
            ppat_type
            metadata
            public_ids
            is_existing
          }
        }
      ''';

      final client = GraphQLClient(
        link: HttpLink(
          '$baseUrl/graphql',
          defaultHeaders: {"Authorization": "Bearer ${_token.value}"},
        ),
        cache: GraphQLCache(),
      );

      final result = await client.mutate(
        MutationOptions(document: gql(mutation), variables: variables),
      );

      if (result.hasException) {
        Get.snackbar("Error", result.exception.toString());
        return;
      }

      await _dbHelper.deleteDraftByJenis(jenis);
      Get.snackbar("Sukses", "Data berhasil dikirim!");
      Get.offAllNamed('/PPAT');
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  @override
  void onClose() {
    _clearControllers();
    super.onClose();
  }
}
