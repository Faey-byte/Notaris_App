import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:http/http.dart' as http;
  import 'package:image_picker/image_picker.dart';
  import 'package:notaris_app/Pages/map_picker_page.dart';
  import 'package:notaris_app/config/base_url.dart';
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

  // ============================================================================
  // 🌍 GLOBAL STATE UNTUK MENYIMPAN MATCHKEY & FILE DATA SEMENTARA
  // ============================================================================
  class PendingUploadData {
    final String label;
    final String fileId;
    final String matchKey;
    final String url;
    final String localFilePath;

    PendingUploadData({
      required this.label,
      required this.fileId,
      required this.matchKey,
      required this.url,
      required this.localFilePath,
    });

    Map<String, dynamic> toMap() {
      return {
        'label': label,
        'file_id': fileId,
        'matchkey': matchKey,
        'url': url,
        'local_path': localFilePath,
      };
    }
  }

  class DynamicFormController extends GetxController {
    final String jenis;
    DynamicFormController(this.jenis);

    var fields = <DynamicField>[].obs;
    var controllers = <String, TextEditingController>{};

    final ImagePicker _picker = ImagePicker();
    late final DbHelper dbHelper; // ✅ PUBLIC AGAR BISA DIAKSES DARI WIDGET

    var lifeStatus = "".obs;
    var _token = "".obs;

    // ========================================================================
    // 🌐 GLOBAL STATE: Menyimpan semua pending upload data sementara
    // ========================================================================
    var pendingUploads = <String, PendingUploadData>{}.obs;

    // ========================================================================
    // 🌐 GLOBAL STATE: File data dari REST API /make-url yang sudah ter-upload
    // Format: { "label": { "id": "...", "matchkey": "...", "url": "..." } }
    // Ini akan digunakan saat submitForm() dipanggil
    // ========================================================================
    var uploadedFilesData = <String, Map<String, String>>{}.obs;

    final List<String> lifeStatusOptions = [
      "single",
      "married",
      "divorced",
      "widowed",
    ];

    static const String baseUrl = "${ApiConfig.baseUrl}";

    @override
    void onInit() {
      dbHelper = DbHelper(); // ✅ INITIALIZE DI SINI
      super.onInit();

        print("🔥 [CONTROLLER] jenis masuk: '$jenis'");

    // ❌ HARD STOP kalau kosong
    if (jenis.isEmpty) {
      throw Exception("❌ jenis / ppat_type kosong dari halaman sebelumnya!");
    }
      _initFormWithToken();
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

    Future<void> loadSavedDraft() async {
      try {
        final savedData = await dbHelper.getDraftByJenis(jenis);
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

        print("🚀 === RESPONS MENTAH DARI SERVER UPLOAD FILE ===");
        print(response.body);
        print("=================================================");

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
          final extractedUrl = targetFileData['url'] ?? "";
          final extractedFileId = targetFileData['id']?.toString() ?? "";

          // ✨ PERBAIKAN: Ambil matchkey dari response
          final extractedMatchKey = targetFileData['matchkey'] ?? "";

          // ✨ Normalisasi label dokumen
          final normalizedLabel = field.label.trim();

          // ✨ PERBAIKAN: Simpan file data ke global state sementara
          // Nanti akan digunakan saat submitForm() untuk disimpan ke database
          uploadedFilesData[normalizedLabel] = {
            'id': extractedFileId,
            'matchkey': extractedMatchKey,
            'url': extractedUrl,
          };

          print("🌐 === SIMPAN FILE DATA KE GLOBAL STATE ===");
          print("Label        : $normalizedLabel");
          print("File ID      : $extractedFileId");
          print("Matchkey     : $extractedMatchKey");
          print("URL          : $extractedUrl");
          print("=========================================\n");

          // ✨ Update UI field dengan URL (untuk preview)
          field.fileValue.value = extractedUrl;
          field.fileId.value = extractedFileId;
          field.matchKey.value = extractedMatchKey;

          fields.refresh();
          Get.snackbar("Sukses", "$normalizedLabel siap untuk dikirim");
        } else {
          throw Exception("Gagal mengekstrak struktur file.");
        }
      } catch (e) {
        print("❌ [UPLOAD ERROR LOG]: $e");
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

          await dbHelper.saveDraft({
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

    // ============================================================
    // ✅ VALIDASI SEMUA FIELD (Length Logic)
    // - text/number  : controller.text.length == 0 -> kosong
    // - upload       : fileValue.value.length == 0 -> belum upload
    // - coordinate   : latitude & longitude masih 0.0 -> belum dipilih
    // Jika ada yang kosong, tampilkan snackbar dan return false
    // ============================================================
    bool validateFields() {
      for (var field in fields) {
        if (field.type == "text" || field.type == "number") {
          final value = controllers[field.label]?.text ?? "";
          if (value.length == 0) {
            Get.snackbar(
              "Peringatan",
              "Tidak bisa lanjut, karena kolom kosong",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return false;
          }
        } else if (field.type == "upload") {
          if (field.fileValue.value.length == 0) {
            Get.snackbar(
              "Peringatan",
              "Tidak bisa lanjut, karena kolom kosong",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return false;
          }
        } else if (field.type == "coordinate") {
          if (field.latitude.value == 0.0 && field.longitude.value == 0.0) {
            Get.snackbar(
              "Peringatan",
              "Tidak bisa lanjut, karena kolom kosong",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return false;
          }
        }
      }
      return true;
    }

    Future<void> submitForm() async {
      // ✅ Validasi semua field sebelum lanjut submit
      if (!validateFields()) return;

      try {
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
          "staff_name": controllers["Nama Staff"]?.text ?? "Staff Notaris",
          "institude_id": 1,
        };

        const mutation = r'''
          mutation UploadAsset(
            $client_name: String!,
            $public_ids: [String!]!,
            $ppat_type: String!,
            $metadata: JSON!,
            $life_status: String!,
            $staff_name: String!,
            $institude_id: Int!
          ) {
            uploadAsset(
              client_name: $client_name,
              public_ids: $public_ids,
              ppat_type: $ppat_type,
              metadata: $metadata,
              life_status: $life_status,
              staff_name: $staff_name,
              institude_id: $institude_id
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
          print("❌ GraphQL Error: ${result.exception}");
          Get.snackbar("Error", result.exception.toString());
          return;
        }

        final responseData = result.data?['uploadAsset'];

        if (responseData == null) {
          throw Exception("Response GraphQL tidak valid");
        }

        // ✨ PERBAIKAN: Ambil public_ids dari response GraphQL
        final List<dynamic>? publicIds = responseData['public_ids'];
        if (publicIds == null || publicIds.isEmpty) {
          throw Exception("public_ids tidak ditemukan di response GraphQL");
        }

        final String clientId = publicIds.first.toString(); // ✨ Ambil elemen pertama
        final String message = responseData['message'] ?? "";
        final String ppatType = responseData['ppat_type'] ?? jenis;

        print("🎉 === GRAPHQL RESPONSE BERHASIL ===");
        print("Message       : $message");
        print("ClientID      : $clientId"); // ✨ Dari public_ids[0]
        print("PPAT Type     : $ppatType");
        print("Public IDs    : $publicIds");
        print("====================================\n");

        if (clientId.isEmpty) {
          throw Exception("ClientID tidak valid dari public_ids");
        }

        print("💾 === PROSES SIMPAN KE DATABASE ===");

        // ✨ PERBAIKAN: Gunakan uploadedFilesData yang sudah dikumpulkan dari REST API
        for (var entry in uploadedFilesData.entries) {
          final label = entry.key.trim();
          final fileData = entry.value;

          final fileId = fileData['id'] ?? "";
          final matchKey = fileData['matchkey'] ?? "";
          final url = fileData['url'] ?? "";

          // Ambil nama file dari URL Cloudinary
          final String fileNameOnly = url.isNotEmpty ? url.split('/').last : "";

          final draftRow = {
            'id_field': "${jenis}_$label",
            'jenis_pekerjaan': jenis,
            'label': label,
            'file_id': fileId,                      // ✅ Dari REST API
            'matchkey': matchKey.trim(),             // ✅ Dari REST API
            'url': url,                              // ✅ Dari REST API
            'text_value': fileNameOnly,              // Nama file untuk preview
            'local_path': null,
            'client_id': clientId,                   // ✅ Dari GraphQL response
          };

          await dbHelper.saveDraft(draftRow);

          print("✅ Saved File: $label");
          print("   - ID            : $fileId");
          print("   - Matchkey      : $matchKey");
          print("   - URL           : $url");
          print("   - ClientID      : $clientId");
          print("");
        }

        if (coordinateField != null) {
          final coordinateRow = {
            'id_field': "${jenis}_${coordinateField.label}",
            'jenis_pekerjaan': jenis,
            'label': coordinateField.label,
            'text_value': "$targetLat,$targetLng",
            'client_id': clientId, // ✨ Gunakan clientId dari public_ids
          };
          await dbHelper.saveDraft(coordinateRow);
          print("✅ Saved: Coordinate");
          print("   - Latitude   : $targetLat");
          print("   - Longitude  : $targetLng");
          print("   - Client ID  : $clientId\n");
        }

        for (var field in fields) {
          if ((field.type == "text" || field.type == "number") &&
              !["Nama Staff", "Total biaya layanan"].contains(field.label)) {
            final controller = controllers[field.label];
            if (controller != null && controller.text.isNotEmpty) {
              // ✨ PERBAIKAN: Text fields hanya perlu field-field penting
              final textRow = {
                'id_field': "${jenis}_${field.label}",
                'jenis_pekerjaan': jenis,
                'label': field.label,
                'text_value': controller.text,
                'client_id': clientId,
                // File-related fields akan otomatis null di database
              };
              await dbHelper.saveDraft(textRow);
              print("✅ Saved: ${field.label}");
              print("   - Value      : ${controller.text}");
              print("   - Type       : text");
              print("   - Client ID  : $clientId\n");
            }
          }
        }

        print("====================================");
        print("🎊 SEMUA DATA BERHASIL DISIMPAN!\n");

        // ✨ PERBAIKAN: Clear global state setelah selesai
        uploadedFilesData.clear();
        pendingUploads.clear();
        
        Get.snackbar(
          "Sukses",
          "Data berhasil dikirim dengan ClientID: $clientId",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/PPAT');
      } catch (e) {
        print("❌ [SUBMIT ERROR]: $e");
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
      _clearControllers();
      super.onClose();
    }
  }