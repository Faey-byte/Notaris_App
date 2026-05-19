import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DokumenModel {
  final String nama;
  final String tanggal;
  final bool isImage;

  DokumenModel({
    required this.nama,
    required this.tanggal,
    this.isImage = false,
  });
}

class DetailBerkasController extends GetxController {
  final BerkasModel data;

  DetailBerkasController(this.data);


  final String baseUrl = 'https://teach-wiley-grid-reproduced.trycloudflare.com';


  var isLoading = false.obs;
  var alamat = "Memuat lokasi...".obs;
  var totalBiaya = "Rp 0".obs;
  var namaStaff = "-".obs;

  var statusPajak = "Belum Bayar".obs;
  var statusPekerjaan = "PENDING".obs;

  var dokumenList = <DokumenModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    statusPekerjaan.value = data.status;
    fetchDetailFromGraphQL();
  }

  Future<void> fetchDetailFromGraphQL() async {
    isLoading.value = true;
    try {
      final String query = '''
        query getPpatRecordById(\$id: ID!) {
          getPpatRecordById(id: \$id) {
            id
            status_pengerjaan
            status_pajak
            metadata {
              label
              type
              value
            }
          }
        }
      ''';

      final response = await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": query,
          "variables": {"id": data.id}
        }),
      );

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        final record = resBody['data']?['getPpatRecordById'];

        if (record != null) {
          statusPekerjaan.value = record['status_pengerjaan'] ?? "PENDING";
          statusPajak.value = record['status_pajak'] ?? "Belum Bayar";

          final List? metadataList = record['metadata'];
          if (metadataList != null) {
            List<DokumenModel> fetchedDocs = [];
            
            for (var item in metadataList) {
              String label = item['label'] ?? "";
              String type = item['type'] ?? "";
              String value = item['value'] ?? "";

              if (label.toLowerCase().contains("alamat") || label.toLowerCase().contains("lokasi") || type == "coordinate") {
                alamat.value = value.isNotEmpty ? value : "Lokasi tidak terisi";
              } else if (label.toLowerCase().contains("biaya") || label.toLowerCase().contains("layanan")) {
                totalBiaya.value = value;
              } else if (label.toLowerCase().contains("staff")) {
                namaStaff.value = value;
              } else if (type == "upload" && value.isNotEmpty) {
                bool isImg = value.toLowerCase().endsWith(".jpg") || value.toLowerCase().endsWith(".png") || value.toLowerCase().endsWith(".jpeg");
                fetchedDocs.add(DokumenModel(
                  nama: value, 
                  tanggal: "Terunggah", 
                  isImage: isImg
                ));
              }
            }
            dokumenList.value = fetchedDocs;
          }
        }
      }
    } catch (e) {
      print("Error Fetch GraphQL Detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPekerjaan(String value) async {
    statusPekerjaan.value = value;
    try {
      final String mutation = '''
        mutation updateStatusPengerjaan(\$id: ID!, \$status: String!) {
          updateStatusPengerjaan(id: \$id, status_pengerjaan: \$status) {
            id
            status_pengerjaan
          }
        }
      ''';

      await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": mutation,
          "variables": {"id": data.id, "status": value}
        }),
      );
    } catch (e) {
      print("Gagal update status pekerjaan ke server: $e");
    }
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
    try {
      final String mutation = '''
        mutation updateStatusPajak(\$id: ID!, \$status: String!) {
          updateStatusPajak(id: \$id, status_pajak: \$status) {
            id
            status_pajak
          }
        }
      ''';

      await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": mutation,
          "variables": {"id": data.id, "status": value}
        }),
      );
    } catch (e) {
      print("Gagal update status pajak ke server: $e");
    }
  }

  Color getStatusPekerjaanColor(String status) {
    switch (status.toUpperCase()) {
      case "SELESAI":
        return AppColors.statusSelesai;
      case "REVISI":
        return Colors.red;
      default:
        return AppColors.statusProses;
    }
  }

  Color getStatusPekerjaanBg(String status) {
    switch (status.toUpperCase()) {
      case "SELESAI":
        return AppColors.statusSelesaiBg;
      case "REVISI":
        return Colors.red.withOpacity(0.1);
      default:
        return AppColors.statusProsesBg;
    }
  }

  Color getStatusPajakColor(String status) {
    if (status.toLowerCase() == "lunas") {
      return AppColors.statusSelesai;
    }
    return Colors.red;
  }

  Color getStatusPajakBg(String status) {
    if (status.toLowerCase() == "lunas") {
      return AppColors.statusSelesaiBg;
    }
    return Colors.red.withOpacity(0.1);
  }
}