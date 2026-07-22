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

  get queryHint => null;

  get ppatType => null;
}

class DetailBerkasController extends GetxController {
  final String baseUrl =
      'https://walt-tee-search-cardiff.trycloudflare.com/api/v1';

  // ================== STATUS MAPPING ==================
  // Backend (Go) cuma menerima 4 status final: pending, done, revision, rejected.
  // Cara mengisinya via field `Action`, yang oleh backend akan di-mapping:
  //   "done"     -> status "done"
  //   "pending"  -> status "pending"
  //   "revision" -> status "revision"
  //   "reject"   -> status "rejected"
  // Jadi label Indonesia di UI TIDAK pernah dikirim langsung, selalu lewat map ini.
  static const Map<String, String> statusLabelToAction = {
    "PENDING": "pending",
    "REVISI": "revision",
    "SELESAI": "done",
    "DITOLAK": "reject",
  };

  // Untuk menampilkan status yang datang dari backend (bahasa Inggris)
  // menjadi label Indonesia di UI.
  static const Map<String, String> backendStatusToLabel = {
    "pending": "PENDING",
    "revision": "REVISI",
    "done": "SELESAI",
    "rejected": "DITOLAK",
  };

  static String labelFromBackendStatus(String? backendStatus) {
    final key = (backendStatus ?? "pending").toLowerCase().trim();
    return backendStatusToLabel[key] ?? key.toUpperCase();
  }
  // ======================================================

  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;

  var publicId = "".obs;
  var alamat = "Tidak ada lokasi".obs;
  var totalBiaya = "Rp 0".obs;
  var statusPajak = "Belum Bayar".obs;
  var statusPengerjaan = "PENDING".obs;
  var namaStaff = "Sistem Otomatis".obs;
  var dokumenList = <DokumenModel>[].obs;

  String fallbackName = "";
  String fallbackPublicID = "";
  int transactionId = 0;

  void initData(BerkasModel? data) {
    if (data != null) {
      fallbackName = data.client.name ?? "";
      fallbackPublicID = data.client.publicID ?? "";

      publicId.value = fallbackPublicID;
      transactionId = data.id;
      statusPengerjaan.value = labelFromBackendStatus(data.status);

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

        final rawId = data['id'];
        if (rawId is int) {
          transactionId = rawId;
        } else if (rawId is String) {
          transactionId = int.tryParse(rawId) ?? transactionId;
        }

        statusPengerjaan.value = labelFromBackendStatus(
          data['status']?.toString(),
        );

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

  /// Update status pengerjaan.
  /// [label] adalah label Indonesia dari dropdown ("PENDING", "REVISI", "SELESAI", "DITOLAK").
  /// Label ini dipetakan ke `action` bahasa Inggris sebelum dikirim ke backend,
  /// sesuai logic ManagementProgress di Go (field Action: done/pending/revision/reject).
  Future<void> updateStatusPekerjaan(String label) => updateStatusPengerjaan(label);

  Future<void> updateStatusPengerjaan(String label) async {
    final action = statusLabelToAction[label];
    if (action == null) {
      Get.snackbar("Gagal", "Status \"$label\" tidak dikenali");
      return;
    }

    if (transactionId == 0) {
      Get.snackbar("Gagal", "ID transaksi tidak ditemukan");
      return;
    }

    final previousLabel = statusPengerjaan.value;
    if (previousLabel == label) return;

    // optimistic update supaya UI langsung responsif
    statusPengerjaan.value = label;
    isUpdatingStatus.value = true;

    try {
      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      // Sesuai handler ManagementProgress: path harus persis
      // /api/v1/transactions/{id}/progress (5 segmen, segmen terakhir "progress").
      final url = Uri.parse('$baseUrl/transactions/$transactionId/progress');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "action": action,
        }),
      );

      print("=== UPDATE STATUS ===");
      print("URL: $url");
      print("Action dikirim: $action");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        // rollback kalau gagal
        statusPengerjaan.value = previousLabel;

        String message = "Status pengerjaan gagal diperbarui";
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}

        Get.snackbar("Gagal", message);
      }
    } catch (e) {
      statusPengerjaan.value = previousLabel;
      print("ERROR UPDATE STATUS: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat memperbarui status");
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
  }

  Color getStatusPekerjaanColor(String status) => AppColors.statusProses;
  Color getStatusPekerjaanBg(String status) => AppColors.statusProsesBg;
  Color getStatusPajakColor(String status) => AppColors.statusProses;
  Color getStatusPajakBg(String status) => AppColors.statusProsesBg;

  void displayDocument({required documentName, required String documentUrl, required String clientId, required ppatType}) {}
}