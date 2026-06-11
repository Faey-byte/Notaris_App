import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/data/services/logging_service.dart';

class DokumenModel {
  final String nama;
  final String url;
  final String tanggal;
  final bool isImage;
  final String staffName;

  DokumenModel({
    required this.nama,
    required this.url,
    required this.tanggal,
    required this.isImage,
    required this.staffName,
  });
}

class DetailBerkasController extends GetxController {
  final String baseUrl =
      'https://virtually-persian-nevertheless-properties.trycloudflare.com/api/v1';

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
      fallbackName = data.client.name ?? "";
      fallbackPublicID = data.client.publicID ?? "";

      publicId.value = fallbackPublicID;
      statusPengerjaan.value = data.status.toUpperCase();

      fetchDetailBerkas(clientName: fallbackName, publicID: fallbackPublicID);
    }
  }

  Future<void> fetchDetailBerkas({
    required String clientName,
    required String publicID,
  }) async {
    isLoading.value = true;
    try {
      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final String fullUrl =
          '$baseUrl/show-detailing-byClient'
          '?clientName=${Uri.encodeComponent(clientName)}'
          '&publicID=${Uri.encodeComponent(publicID)}';

      print("=== REQUEST URL ===");
      print(fullUrl);

      final response = await http.get(Uri.parse(fullUrl), headers: headers);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);

        final data = resBody['data'];
        if (data == null) return;

        final staff = data['staff'];
        namaStaff.value = staff?['StaffName'] ?? "Sistem Otomatis";

        final client = data['client'];
        publicId.value = client?['publicID'] ?? fallbackPublicID;

        statusPengerjaan.value = (data['status'] ?? 'pending')
            .toString()
            .toUpperCase();

        final asset = data['document_transaction']?['asset'];
        final metadata = asset?['metadata'];

        if (metadata != null) {
          final dynamic rawAmount = metadata['amount'];
          int amountInt = 0;
          if (rawAmount is int) {
            amountInt = rawAmount;
          } else if (rawAmount is String) {
            amountInt =
                int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          }

          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalBiaya.value = amountInt > 0
              ? formatter.format(amountInt)
              : "Rp 0";

          final loc = metadata['location'];
          if (loc != null && loc is Map) {
            final lat = loc['latitude']?.toString() ?? "";
            final lng = loc['longitude']?.toString() ?? "";
            alamat.value = (lat.isNotEmpty && lng.isNotEmpty)
                ? "Lat: $lat, Lng: $lng"
                : "Tidak ada lokasi";
          } else {
            alamat.value = "Tidak ada lokasi";
          }

          final rawFiles = metadata['files'];
          if (rawFiles != null && rawFiles is List) {
            dokumenList.value = rawFiles
                .where((f) => f is Map && (f['url'] ?? '').isNotEmpty)
                .map((f) {
                  final fileUrl = f['url'] as String;
                  final fileName = f['name'] ?? fileUrl.split('/').last;
                  return DokumenModel(
                    nama: fileName,
                    url: fileUrl,
                    tanggal: "13 Nov 2023",
                    isImage: [
                      '.jpg',
                      '.jpeg',
                      '.png',
                    ].any((ext) => fileUrl.toLowerCase().endsWith(ext)),
                    staffName: namaStaff.value,
                  );
                })
                .toList();
          }
        }
      }
    } catch (e) {
      print("ERROR HANDLER: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPekerjaan(String value) async {
    statusPengerjaan.value = value.toUpperCase();
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
  }

  Color getStatusPekerjaanColor(String status) => AppColors.statusProses;
  Color getStatusPekerjaanBg(String status) => AppColors.statusProsesBg;
  Color getStatusPajakColor(String status) => AppColors.statusProses;
  Color getStatusPajakBg(String status) => AppColors.statusProsesBg;
}
