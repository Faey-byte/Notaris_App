import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:notaris_app/Model/notaris_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailBerkasNotarisController extends GetxController {
  late final DbHelper dbHelper;
  static const String baseUrl = "${ApiConfig.baseUrl}";

  final RxBool isLoading = true.obs;
  final RxBool isUpdatingStatus = false.obs;
  final Rxn<NotarisDetailModel> detail = Rxn<NotarisDetailModel>();

  final RxString fallbackName = ''.obs;
  final RxString publicId = ''.obs;
  final RxString statusPengerjaan = 'PENDING'.obs;
  final RxString totalBiaya = '-'.obs;
  final RxString namaStaff = '-'.obs;
  final RxString jenisPekerjaan = '-'.obs;
  final RxList<NotarisDocMetadata> dokumenList = <NotarisDocMetadata>[].obs;
  
  // 🔧 Variabel baru untuk menyimpan berkas_id lokal (SQLite)
  final RxString currentLocalBerkasId = ''.obs; 

  int transactionId = 0;

  // ================== STATUS MAPPING ==================
  // Backend (Go) NotaryManagementProgress cuma menerima 4 status final:
  // pending, done, revision, rejected.
  // Diisi lewat field `action`, yang oleh backend dipetakan:
  //    "done"     -> status "done"
  //    "revision" -> status "revision"
  //    "reject"   -> status "rejected"
  //    selain itu (termasuk "pending") -> default branch: accept=false -> "pending"
  // Jadi label Indonesia di UI TIDAK pernah dikirim langsung, selalu lewat map ini.
  static const Map<String, String> statusLabelToAction = {
    "PENDING": "pending",
    "PROSES": "pending", // Dipetakan ke pending agar aman di sisi server
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

  @override
  void onInit() {
    dbHelper = DbHelper();
    super.onInit();
  }

  Future<void> initData({
    required String clientName,
    String? publicIdParam,
    String? localBerkasId,
  }) async {
    fallbackName.value = clientName;
    
    // 🔧 Simpan localBerkasId ke RxString agar bisa digunakan di fungsi updateStatusPekerjaan
    if (localBerkasId != null) {
      currentLocalBerkasId.value = localBerkasId;
    }
    
    await fetchDetail(clientName: clientName, publicId: publicIdParam);
    if (localBerkasId != null) {
      await _loadTotalBiayaFromLocal(localBerkasId);
    }
  }

  Future<void> fetchDetail({String? clientName, String? publicId}) async {
    try {
      isLoading.value = true;

      if ((clientName == null || clientName.isEmpty) &&
          (publicId == null || publicId.isEmpty)) {
        throw Exception("clientName atau publicID wajib diisi");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final queryParams = <String, String>{};
      if (clientName != null && clientName.isNotEmpty) {
        queryParams['clientName'] = clientName;
      }
      if (publicId != null && publicId.isNotEmpty) {
        queryParams['publicID'] = publicId;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/show-detailing-notary-byClient',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print("🚀 [NOTARIS DETAIL] Response mentah: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200 || decoded['status'] != true) {
        throw Exception(decoded['message'] ?? "Gagal mengambil detail berkas");
      }

      final model = NotarisDetailModel.fromJson(decoded['data']);
      detail.value = model;

      transactionId = model.id;
      fallbackName.value = model.client.name;
      publicId2(model.client.publicId);
      
      // Mencegah penimpalan status jika di lokal sudah tersimpan data yang lebih baru
      if (currentLocalBerkasId.isNotEmpty) {
        final savedStatus = prefs.getString('status_notaris_${currentLocalBerkasId.value}');
        statusPengerjaan.value = savedStatus ?? labelFromBackendStatus(model.status);
      } else {
        statusPengerjaan.value = labelFromBackendStatus(model.status);
      }
      
      namaStaff.value = model.staff.staffName.isEmpty
          ? '-'
          : model.staff.staffName;
      jenisPekerjaan.value = model.caseData.caseName
          .replaceAll('_', ' ')
          .toUpperCase();

      dokumenList.value = model.documentTransaction?.asset.metadata ?? [];
    } catch (e) {
      print("❌ [NOTARIS DETAIL ERROR]: $e");
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // helper kecil supaya assignment ke RxString publicId tetap eksplisit & aman
  void publicId2(String value) {
    publicId.value = value;
  }

  Future<void> _loadTotalBiayaFromLocal(String berkasId) async {
    try {
      final rows = await dbHelper.getNotarisDraftByBerkasId(berkasId);
      final match = rows.where((r) => r['label'] == 'Total Biaya Layanan');
      if (match.isNotEmpty) {
        final val = match.first['text_value']?.toString();
        if (val != null && val.isNotEmpty) {
          totalBiaya.value = val;
        }
      }
    } catch (e) {
      print("❌ [NOTARIS DETAIL] Gagal ambil total biaya lokal: $e");
    }
  }

  /// Update status pengerjaan.
  /// [label] adalah label Indonesia dari dropdown ("PENDING", "REVISI", "SELESAI", "DITOLAK").
  /// Label ini dipetakan ke `action` bahasa Inggris sebelum dikirim ke backend,
  /// sesuai logic NotaryManagementProgress di Go.
  Future<void> updateStatusPekerjaan(String label) async {
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token.isNotEmpty) "Authorization": "Bearer $token",
      };

      // Sesuai handler NotaryManagementProgress: path harus persis
      // /api/v1/notary/transactions/{id}/progress (6 segmen, segmen terakhir "progress").
      final url = Uri.parse(
        '$baseUrl/api/v1/notary/transactions/$transactionId/progress',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "action": action,
        }),
      );

      print("=== UPDATE STATUS NOTARIS ===");
      print("URL: $url");
      print("Action dikirim: $action");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 🔧 DI SINI PROSES PENYIMPANAN BERHASIL KE LOCAL CACHE DIJALANKAN
        if (currentLocalBerkasId.value.isNotEmpty) {
          await prefs.setString('status_notaris_${currentLocalBerkasId.value}', label);
          print("💾 [LOCAL CACHE] Berhasil menyimpan status baru ($label) untuk ID: ${currentLocalBerkasId.value}");
        }
      } else {
        // rollback kalau gagal
        statusPengerjaan.value = previousLabel;

        String message = "Status pengerjaan gagal diperbarui";
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }

        Get.snackbar("Gagal", message);
      }
    } catch (e) {
      statusPengerjaan.value = previousLabel;
      print("ERROR UPDATE STATUS NOTARIS: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat memperbarui status");
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Color getStatusPekerjaanBg(String status) {
    switch (status.toUpperCase()) {
      case 'SELESAI':
        return const Color(0xFFDCFCE7);
      case 'REVISI':
        return const Color(0xFFDBEAFE);
      case 'DITOLAK':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7); // Default warna kuning untuk PROSES/PENDING
    }
  }

  Color getStatusPekerjaanColor(String status) {
    switch (status.toUpperCase()) {
      case 'SELESAI':
        return const Color(0xFF15803D);
      case 'REVISI':
        return const Color(0xFF1D4ED8);
      case 'DITOLAK':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFFB45309); // Default warna coklat/amber teks
    }
  }

  void displayNotarisDocument({required String label, required String localPath}) {}
}