import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:path/path.dart' as p;
import 'package:graphql_flutter/graphql_flutter.dart';

class DynamicField {
  final String label;
  final String type;
  final String? placeholder;
  
  var fileValue = "".obs;   
  var fileId = "".obs;      
  var matchKey = "".obs;    
  var isLoading = false.obs;

  DynamicField({required this.label, required this.type, this.placeholder});
}

class DynamicFormController extends GetxController {
  final String jenis;
  DynamicFormController(this.jenis);

  var fields = <DynamicField>[].obs;
  var controllers = <String, TextEditingController>{};
  final ImagePicker _picker = ImagePicker();
  final DbHelper _dbHelper = DbHelper(); 

  @override
  void onInit() {
    super.onInit();
    generateForm();
    loadSavedDraft();
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
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
      {"label": "NPWP Pemilik sertipikat", "type": "upload"},
      {"label": "PBB tahun berjalan", "type": "upload"},
      {"label": "Bukti bayar PBB tahun berjalan", "type": "upload"},
      {"label": "Foto objek", "type": "upload"},
      {"label": "Titik Koordinat", "type": "coordinate"},
      {"label": "KTP Pembeli", "type": "upload"},
      {"label": "KK Pembeli", "type": "upload"},
      {"label": "Total biaya layanan", "type": "number"},
      {"label": "Nama Staff", "type": "text"},
      {"label": "Public ID", "type": "text"},
    ],
    "APHB": [
      {"label": "Nama Client/Perusahaan", "type": "text"},
      {"label": "Sertipikat Asli", "type": "upload"},
      {"label": "KTP Pemilik Sertipikat (suami istri)", "type": "upload"},
      {"label": "KK Pemilk Sertipikat", "type": "upload"},
      {"label": "Akta Kematian (jika pasangan meninggal)", "type": "upload"},
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
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
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
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
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
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
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
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
      {"label": "Surat Keterangan Kelurahan (jika belum menikah)", "type": "upload"},
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

    var requirementList = ppatRequirements[jenis] ?? [{"label": "Data Default", "type": "text"}];

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

  Future<void> loadSavedDraft() async {
    try {
      List<Map<String, dynamic>> savedData = await _dbHelper.getDraftByJenis(jenis);
      if (savedData.isNotEmpty) {
        for (var data in savedData) {
          var field = fields.firstWhereOrNull((f) => f.label == data['label']);
          if (field != null) {
            if (field.type == "upload") {
              field.fileValue.value = data['url'] ?? "";
              field.fileId.value = data['file_id'] ?? "";
              field.matchKey.value = data['matchkey'] ?? "";
            } else {
              controllers[field.label]?.text = data['text_value'] ?? "";
            }
          }
        }
      }
    } catch (e) {
      print("Error loading draft: $e");
    }
  }

  Future<void> pickAndUploadFile(DynamicField field, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        field.isLoading.value = true;
        File file = File(pickedFile.path);

        final response = await http.post(
          Uri.parse('https://desktops-effectively-filename-attached.trycloudflare.com/api/v1/make-url'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'file_name': p.basename(file.path)}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          field.fileValue.value = data['url'] ?? "";
          field.fileId.value = data['id']?.toString() ?? "";
          field.matchKey.value = data['matchkey'] ?? "";

          await _dbHelper.saveDraft({
            'id_field': "${jenis}_${field.label}",
            'jenis_pekerjaan': jenis,
            'label': field.label,
            'text_value': "",
            'file_id': field.fileId.value,
            'matchkey': field.matchKey.value,
            'url': field.fileValue.value,
          });

          Get.snackbar("Sukses", "${field.label} berhasil disimpan ke draft");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal upload: $e");
    } finally {
      field.isLoading.value = false;
    }
  }

  Future<void> submitForm() async {
    Map<String, dynamic> variables = {
      "input": {
        "public_id": "CLIENT_${DateTime.now().millisecondsSinceEpoch}",
        "jenis_pekerjaan": jenis,
        "dokumen_syarat": fields.where((f) => f.type == "upload").map((f) => {
          "label": f.label,
          "file_id": f.fileId.value,
          "matchkey": f.matchKey.value,
          "url": f.fileValue.value
        }).toList(),
        "input_data": fields.where((f) => f.type == "text" || f.type == "number").map((f) => {
          "label": f.label,
          "value": controllers[f.label]?.text
        }).toList(),
      }
    };

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      const String mutation = r'''
        mutation calculatePPAT($input: PPATInput!) {
          calculatePPAT(input: $input) {
            status
            message
          }
        }
      ''';

      final HttpLink httpLink = HttpLink('https://desktops-effectively-filename-attached.trycloudflare.com/graphql');
      final GraphQLClient client = GraphQLClient(link: httpLink, cache: GraphQLCache());

      final QueryResult result = await client.mutate(MutationOptions(
        document: gql(mutation),
        variables: variables,
      ));

      Get.back();

      if (result.hasException) {
        Get.snackbar("Error", "Gagal simpan ke pusat: ${result.exception.toString()}");
      } else {
        await _dbHelper.deleteDraftByJenis(jenis);
        Get.snackbar("Sukses", "Berkas PPAT berhasil dikirim!");
        Get.offAllNamed('/home'); 
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Terjadi kesalahan sistem: $e");
    }
  }

  @override
  void onClose() {
    for (var c in controllers.values) { c.dispose(); }
    super.onClose();
  }
}