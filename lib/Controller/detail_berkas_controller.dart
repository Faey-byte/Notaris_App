import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class DokumenModel {
  final String nama;
  final String url;
  final String tanggal;
  final bool isImage;

  DokumenModel({
    required this.nama,
    required this.url,
    required this.tanggal,
    required this.isImage,
  });
}

class DetailBerkasController extends GetxController {
  final String baseUrl = 'https://clause-structure-ran-scholarships.trycloudflare.com';

  var isLoading = false.obs;

  var publicId = "".obs;
  var alamat = "Tidak ada lokasi".obs;
  var totalBiaya = "Rp 0".obs;
  var statusPajak = "Belum Bayar".obs;
  var statusPengerjaan = "PENDING".obs;
  var namaStaff = "Sistem Otomatis".obs;
  var dokumenList = <DokumenModel>[].obs;

  String fallbackName = "";
  String fallbackPublicID = "";

  void initData(BerkasModel? data) {
    if (data != null) {
      fallbackName = data.client.name;
      fallbackPublicID = data.client.publicID;
      publicId.value = data.client.publicID;
      statusPengerjaan.value = data.status.toUpperCase();
      

      fetchDetailBerkas(clientName: fallbackName, publicID: fallbackPublicID);
    }
  }

  Future<void> fetchDetailBerkas({required String clientName, required String publicID}) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/show-detailing-byClient'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",

        },
        body: json.encode({
          "client_name": clientName,
          "publicID": publicID,
        }),
      );

      print("=== DEBUG RESPONSE BODY API DETAIL ===");
      print("Status Code: ${response.statusCode}");
      print(response.body);
      print("======================================");

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);

        if (resBody['status'] == true && resBody['data'] != null) {
          final rawData = resBody['data'];


          publicId.value = rawData['publicID'] ?? rawData['client']?['publicID'] ?? publicID;
          statusPengerjaan.value = (rawData['status'] ?? statusPengerjaan.value).toString().toUpperCase();


          String statusBayarRaw = rawData['status_pembayaran'] ?? rawData['status'] ?? "pending";
          statusPajak.value = (statusBayarRaw.toLowerCase() == "success" || statusBayarRaw.toLowerCase() == "lunas")
              ? "Lunas"
              : "Belum Bayar";


          if (rawData['staff'] != null) {
            namaStaff.value = rawData['staff']['name'] ?? "Sistem Otomatis";
          } else {
            namaStaff.value = "Andini Putri";
          }


          dynamic metadata = rawData['document_transaction'] ?? rawData['transaction'] ?? rawData['metadata'] ?? rawData;
          if (metadata != null && metadata is Map) {
            

            final dynamic rawAmount = metadata['amount'] ?? metadata['total_biaya'] ?? rawData['amount'];
            int amountInt = 0;
            if (rawAmount is int) amountInt = rawAmount;
            else if (rawAmount is String) amountInt = int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            
            final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
            totalBiaya.value = amountInt > 0 ? currencyFormatter.format(amountInt) : "Rp 4.500.000"; // Mockup fallback


            alamat.value = metadata['location'] ?? metadata['alamat'] ?? "Jl. Melati No. 45, Kebayoran Baru, Jakarta Selatan";


            final dynamic rawFiles = metadata['files'] ?? metadata['documents'] ?? rawData['files'];
            if (rawFiles != null && rawFiles is List) {
              List<DokumenModel> tempDocs = [];
              for (var f in rawFiles) {
                String fileName = "Dokumen Persyaratan";
                String fileUrl = "";

                if (f is Map) {
                  fileName = f['name'] ?? f['filename'] ?? "Dokumen Tanpa Nama";
                  fileUrl = f['url'] ?? f['path'] ?? "";
                }
                if (fileUrl.isNotEmpty) {
                  tempDocs.add(DokumenModel(
                    nama: fileName,
                    url: fileUrl,
                    tanggal: "13 Nov 2023",
                    isImage: fileUrl.toLowerCase().endsWith(".jpg") || fileUrl.toLowerCase().endsWith(".png"),
                  ));
                }
              }
              dokumenList.value = tempDocs;
            }
          }
        }
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateStatusPekerjaan(String value) async {
    statusPengerjaan.value = value.toUpperCase();
    Get.snackbar("Sukses", "Status pengerjaan diubah menjadi $value");
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
    Get.snackbar("Sukses", "Status pajak diubah menjadi $value");
  }


  Color getStatusPekerjaanColor(String status) {
    switch (status.toUpperCase()) {
      case 'SELESAI': return AppColors.statusSelesai;
      case 'REVISI': return AppColors.statusRevisi;
      default: return AppColors.statusProses;
    }
  }

  Color getStatusPekerjaanBg(String status) {
    switch (status.toUpperCase()) {
      case 'SELESAI': return AppColors.statusSelesaiBg;
      case 'REVISI': return AppColors.statusRevisiBg;
      default: return AppColors.statusProsesBg;
    }
  }

  Color getStatusPajakColor(String status) =>
      status.toLowerCase() == "lunas" ? AppColors.statusSelesai : AppColors.statusProses;

  Color getStatusPajakBg(String status) =>
      status.toLowerCase() == "lunas" ? AppColors.statusSelesaiBg : AppColors.statusProsesBg;
}