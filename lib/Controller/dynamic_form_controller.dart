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
import 'package:notaris_app/Model/dynamic_field_model.dart';

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

  var dateValue = Rxn<DateTime>();

  bool get isImageFile => true;

  DynamicField({
    required this.label,
    required this.type,
    required this.placeholder,
  });
}

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
  late final DbHelper dbHelper;

  var lifeStatus = "".obs;
  var _token = "".obs;

  var _teamKey = "".obs;

  var pendingUploads = <String, PendingUploadData>{}.obs;

  var uploadedFilesData = <String, Map<String, String>>{}.obs;

  final List<String> lifeStatusOptions = [
    "single",
    "married",
    "divorced",
    "widowed",
  ];

  static const String baseUrl = "${ApiConfig.baseUrl}";
  static const String labelTransferorName =
      "Nama Pihak yang Mengalihkan (Transferor)";
  static const String labelTransferorAddress = "Alamat Pihak yang Mengalihkan";
  static const String labelTransferorNpwp = "NPWP Pihak yang Mengalihkan";
  static const String labelTransfereeName = "Nama Pihak Penerima (Transferee)";
  static const String labelTransfereeAddress = "Alamat Pihak Penerima";
  static const String labelTransfereeNpwp = "NPWP Pihak Penerima";
  static const String labelHamlet = "Dusun";
  static const String labelVillage = "Desa/Kelurahan";
  static const String labelLandArea = "Luas Tanah (m²)";
  static const String labelBuildingArea = "Luas Bangunan (m²)";
  static const String labelBook = "Buku Tanah";
  static const String labelNumber = "Nomor Sertifikat/Buku";
  static const String labelTaxYear = "Tahun Pajak (PBB)";
  static const String labelNop = "NOP (Nomor Objek Pajak)";
  static const String labelNjop = "NJOP (Rp)";
  static const String labelBphtb = "BPHTB (Rp)";
  static const String labelDeedNumber = "Nomor Akta";
  static const String labelDeedDate = "Tanggal Akta";
  static const String labelDeedType = "Jenis Akta";
  static const String labelRightType = "Jenis Hak Atas Tanah";
  static const String labelRightNumber = "Nomor Hak";
  static const String labelNotaryName = "Nama Notaris";

  @override
  void onInit() {
    dbHelper = DbHelper();
    super.onInit();

    print("🔥 [CONTROLLER] jenis masuk: '$jenis'");

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

  List<Map<String, String>> _commonPpatFields() {
    return [
      {"label": labelNotaryName, "type": "text"},
      {"label": labelTransferorName, "type": "text"},
      {"label": labelTransferorAddress, "type": "text"},
      {"label": labelTransferorNpwp, "type": "text"},
      {"label": labelTransfereeName, "type": "text"},
      {"label": labelTransfereeAddress, "type": "text"},
      {"label": labelTransfereeNpwp, "type": "text"},
      {"label": labelHamlet, "type": "text"},
      {"label": labelVillage, "type": "text"},
      {"label": labelLandArea, "type": "number"},
      {"label": labelBuildingArea, "type": "number"},
      {"label": labelBook, "type": "text"},
      {"label": labelNumber, "type": "text"},
      {"label": labelTaxYear, "type": "number"},
      {"label": labelNop, "type": "text"},
      {"label": labelNjop, "type": "number"},
      {"label": labelBphtb, "type": "number"},
      {"label": labelDeedNumber, "type": "text"},
      {"label": labelDeedDate, "type": "date"},
      {"label": labelDeedType, "type": "text"},
      {"label": labelRightType, "type": "text"},
      {"label": labelRightNumber, "type": "text"},
    ];
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
      "HIBAH": [
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
      "LELANG": [
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

    final requirementList = List<Map<String, String>>.from(
      ppatRequirements[jenis] ??
          [
            {"label": "Data Default", "type": "text"},
          ],
    );

    final insertIndex = requirementList.indexWhere(
      (item) => item["label"] == "Total biaya layanan",
    );
    final commonFields = _commonPpatFields();

    if (insertIndex != -1) {
      requirementList.insertAll(insertIndex, commonFields);
    } else {
      requirementList.addAll(commonFields);
    }

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
      _teamKey.value = prefs.getString('teamkey') ?? "";
      debugPrint("Token SharedPreferences Berhasil Dimuat: ${_token.value}");
      debugPrint(
        "TeamKey SharedPreferences Berhasil Dimuat: ${_teamKey.value}",
      );
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
          field.matchKey.value = data['matchkey'] ?? "";
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

      final currentTeamKey = prefs.getString('teamkey') ?? "";
      _teamKey.value = currentTeamKey;

      if (currentToken.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      if (currentTeamKey.isEmpty) {
        throw Exception("TeamKey tidak ditemukan. Silakan login ulang.");
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/make-url'),
      );

      request.headers['Authorization'] = 'Bearer $currentToken';
      request.fields['ppat_type'] = jenis;
      request.fields['field_label'] = field.label;
      request.fields['aes_institute_key'] = currentTeamKey;

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

        final extractedMatchKey = targetFileData['matchkey'] ?? "";

        final normalizedLabel = field.label.trim();

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

    final bool hasSavedLocation =
        field.latitude.value != 0.0 || field.longitude.value != 0.0;

    final pickedResult = await Get.to<LatLng>(
      () => MapPickerPage(
        initialLat: hasSavedLocation ? field.latitude.value : null,
        initialLng: hasSavedLocation ? field.longitude.value : null,
      ),
    );

    if (pickedResult != null) {
      field.latitude.value = pickedResult.latitude;
      field.longitude.value = pickedResult.longitude;

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

  Future<void> pickDeedDate(DynamicField field) async {
    try {
      final context = Get.context;
      if (context == null) return;

      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: field.dateValue.value ?? now,
        firstDate: DateTime(1970),
        lastDate: DateTime(now.year + 5),
      );

      if (picked == null) return;

      field.dateValue.value = picked;

      fields.refresh();
    } catch (e) {
      Get.snackbar(
        "Gagal Memilih Tanggal",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

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
      } else if (field.type == "date") {
        if (field.dateValue.value == null) {
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

  String _text(String label) => controllers[label]?.text.trim() ?? "";

  double _number(String label) =>
      double.tryParse(controllers[label]?.text.trim() ?? "") ?? 0.0;

  int _intNumber(String label) =>
      int.tryParse(controllers[label]?.text.trim() ?? "") ?? 0;

  Future<int> _fetchInstitudeId(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/convert/tokenTo/ID'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("🔑 === RESPONS convert/tokenTo/ID ===");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("=====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Gagal mengambil institude_id (${response.statusCode}): ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);
    final userId = decoded['user_id'];

    if (userId == null) {
      throw Exception("user_id tidak ditemukan di response convert/tokenTo/ID");
    }

    return userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
  }

  Future<void> _updateAesEncKeyFileTeam({
    required String token,
    required String teamKey,
    required String ppatType,
    required String clientId,
    required String publicId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/update/aes/encKey/fileTeam'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "aes_institute_key": teamKey,
          "ppat_type": ppatType,
          "client_id": clientId,
          "public_id": publicId,
        }),
      );

      print("🔐 === RESPONS update/aes/encKey/fileTeam ===");
      print("Status : ${response.statusCode}");
      print("Body   : ${response.body}");
      print("=============================================");

      if (response.statusCode != 200) {
        throw Exception(
          "Gagal update AES enc key (${response.statusCode}): ${response.body}",
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded['success'] != true) {
        throw Exception(
          decoded['message'] ?? "Update AES enc key gagal tanpa pesan error",
        );
      }
    } catch (e) {
      print("❌ [UPDATE AES ENC KEY ERROR]: $e");
      Get.snackbar(
        "Peringatan",
        "Data tersimpan, tapi gagal sinkronkan team key: ${e.toString().replaceAll("Exception: ", "")}",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitForm() async {
    if (!validateFields()) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('auth_token') ?? "";
      _token.value = currentToken;

      if (currentToken.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final int institudeId = await _fetchInstitudeId(currentToken);

      final files = fields
          .where((f) => f.type == "upload" && f.fileValue.value.isNotEmpty)
          .map((f) {
            final fileData = uploadedFilesData[f.label.trim()] ?? {};

            final fileId = fileData['id']?.toString() ?? f.fileId.value;
            final matchKey = fileData['matchkey'] ?? f.matchKey.value;

            return {
              "id": fileId,
              "name": f.label,
              "url": f.fileValue.value,
              "matchkey": matchKey,
            };
          })
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

      final deedDateField = fields.firstWhereOrNull(
        (f) => f.label == labelDeedDate,
      );
      final int deedDateEpoch = deedDateField?.dateValue.value != null
          ? deedDateField!.dateValue.value!.millisecondsSinceEpoch ~/ 1000
          : 0;

      final variables = {
        "client_name": controllers["Nama Client/Perusahaan"]?.text ?? "Agus",
        "public_ids": ["CLIENT_${DateTime.now().millisecondsSinceEpoch}"],
        "ppat_type": jenis,
        "life_status": "married",
        "metadata": metadata,
        "staff_name": controllers["Nama Staff"]?.text ?? "Staff Notaris",
        "institude_id": institudeId,
        "notary_name": _text(labelNotaryName),
        "transferor_name": _text(labelTransferorName),
        "transferor_address": _text(labelTransferorAddress),
        "transferor_npwp": _text(labelTransferorNpwp),
        "transferee_name": _text(labelTransfereeName),
        "transferee_address": _text(labelTransfereeAddress),
        "transferee_npwp": _text(labelTransfereeNpwp),
        "hamlet": _text(labelHamlet),
        "village": _text(labelVillage),
        "land_area": _number(labelLandArea),
        "building_area": _number(labelBuildingArea),
        "book": _text(labelBook),
        "number": _text(labelNumber),
        "tax_year": _intNumber(labelTaxYear),
        "nop": _text(labelNop),
        "njop": _number(labelNjop),
        "bphtb": _number(labelBphtb),
        "deed_number": _text(labelDeedNumber),
        "deed_date": deedDateEpoch,
        "deed_type": _text(labelDeedType),
        "right_type": _text(labelRightType),
        "right_number": _text(labelRightNumber),
      };

      const mutation = r'''
          mutation UploadAsset(
            $client_name: String!,
            $public_ids: [String!]!,
            $ppat_type: String!,
            $metadata: JSON!,
            $life_status: String!,
            $staff_name: String!,
            $institude_id: Int!,
            $notary_name: String!,
            $transferor_name: String!,
            $transferor_address: String!,
            $transferor_npwp: String!,
            $transferee_name: String!,
            $transferee_address: String!,
            $transferee_npwp: String!,
            $hamlet: String!,
            $village: String!,
            $land_area: Float!,
            $building_area: Float!,
            $book: String!,
            $number: String!,
            $tax_year: Int!,
            $nop: String!,
            $njop: Float!,
            $bphtb: Float!,
            $deed_number: String!,
            $deed_date: Int!,
            $deed_type: String!,
            $right_type: String!,
            $right_number: String!
          ) {
            uploadAsset(
              client_name: $client_name,
              public_ids: $public_ids,
              ppat_type: $ppat_type,
              metadata: $metadata,
              life_status: $life_status,
              staff_name: $staff_name,
              institude_id: $institude_id,
              notary_name: $notary_name,
              transferor_name: $transferor_name,
              transferor_address: $transferor_address,
              transferor_npwp: $transferor_npwp,
              transferee_name: $transferee_name,
              transferee_address: $transferee_address,
              transferee_npwp: $transferee_npwp,
              hamlet: $hamlet,
              village: $village,
              land_area: $land_area,
              building_area: $building_area,
              book: $book,
              number: $number,
              tax_year: $tax_year,
              nop: $nop,
              njop: $njop,
              bphtb: $bphtb,
              deed_number: $deed_number,
              deed_date: $deed_date,
              deed_type: $deed_type,
              right_type: $right_type,
              right_number: $right_number
            ) {
              message
              ppat_type
              metadata
              public_ids
              is_existing
              notaryName
              building_area
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

      final List<dynamic>? publicIds = responseData['public_ids'];
      if (publicIds == null || publicIds.isEmpty) {
        throw Exception("public_ids tidak ditemukan di response GraphQL");
      }

      final String clientId = publicIds.first.toString();
      final String message = responseData['message'] ?? "";
      final String ppatType = responseData['ppat_type'] ?? jenis;
      final String notaryName = responseData['notaryName'] ?? "";

      print("🎉 === GRAPHQL RESPONSE BERHASIL ===");
      print("Message       : $message");
      print("ClientID      : $clientId");
      print("PPAT Type     : $ppatType");
      print("Notary Name   : $notaryName");
      print("Public IDs    : $publicIds");
      print("====================================\n");

      if (clientId.isEmpty) {
        throw Exception("ClientID tidak valid dari public_ids");
      }
      await _updateAesEncKeyFileTeam(
        token: currentToken,
        teamKey: _teamKey.value,
        ppatType: ppatType,
        clientId: clientId,
        publicId: clientId,
      );

      print("💾 === PROSES SIMPAN CACHE FILE (url + matchkey) ===");

      for (var entry in uploadedFilesData.entries) {
        final label = entry.key.trim();
        final fileData = entry.value;

        final matchKey = (fileData['matchkey'] ?? "").trim();
        final url = fileData['url'] ?? "";

        final draftRow = {
          'id_field': "${jenis}_$label",
          'jenis_pekerjaan': jenis,
          'label': label,
          'url': url,
          'matchkey': matchKey,
        };

        await dbHelper.saveDraft(draftRow);

        print("✅ Saved (local cache): $label");
        print("   - URL      : $url");
        print("   - Matchkey : $matchKey");
        print("");
      }

      print("====================================");
      print("🎊 SUBMIT SELESAI — data lengkap ada di server,");
      print("   sqflite cuma menyimpan url + matchkey gambar.\n");

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
