import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/data/services/logging_service.dart';

class DokumenModel {
  final String nama;
  final String url;
  final String tanggal;
  final String ppatType;
  final String queryHint; // ✅ Identifier untuk query SQLite

  DokumenModel({
    required this.nama,
    required this.url,
    required this.tanggal,
    required this.ppatType,
    String? queryHint,
  }) : queryHint = queryHint ?? nama; // ✅ Fallback ke nama
}

class DetailBerkasController extends GetxController {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/v1";

  var isLoading = false.obs;
  var isLoadingPpat = false.obs;
  var ppatImageBytes = Rxn<Uint8List>();
  var publicId = "".obs;
  var alamat = "Tidak ada lokasi".obs;
  var totalBiaya = "Rp 0".obs;
  var statusPajak = "Belum Bayar".obs;
  var statusPengerjaan = "PENDING".obs;
  var namaStaff = "Sistem Otomatis".obs;
  var dokumenList = <DokumenModel>[].obs;

  String fallbackName = "";
  String fallbackPublicID = "";

  final DbHelper _dbHelper = DbHelper();

  // ============================================================
  // INIT DATA
  // ============================================================
  Future<void> initData(BerkasModel? data) async {
    if (data == null) return;

    fallbackName = data.client.name ?? "";
    fallbackPublicID = data.client.publicID ?? "";

    String resolvedPublicID = fallbackPublicID;

    if (resolvedPublicID.isEmpty) {
      final ppatType = data.caseData.caseName;
      if (ppatType.isNotEmpty) {
        final fileIdFromDb = await _dbHelper.getFileIdByJenis(ppatType);
        if (fileIdFromDb != null && fileIdFromDb.isNotEmpty) {
          resolvedPublicID = fileIdFromDb;
          debugPrint(
            "✅ [DetailBerkas] publicID (file_id) dari SQLite: $resolvedPublicID",
          );
        }
      }
    }

    publicId.value = resolvedPublicID;
    statusPengerjaan.value = data.status.toUpperCase();

    await fetchDetailBerkas(
      clientName: fallbackName,
      publicID: resolvedPublicID,
    );
  }

  // ============================================================
  // FETCH DETAIL BERKAS
  // ============================================================
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

      final uri = Uri.parse('$baseUrl/show-detailing-byClient').replace(
        queryParameters: {
          'clientName': clientName,
          'publicID': publicID,
        },
      );

      debugPrint("=== REQUEST URL ===");
      debugPrint(uri.toString());

      final response = await http.get(uri, headers: headers);

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

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
          // Parse total biaya
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

          // Parse lokasi
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

          // ============================================================
          // ✅ Parse daftar dokumen — gunakan for loop (bukan map)
          // karena async tidak bisa di dalam .map()
          // ============================================================
          final rawFiles = metadata['files'];
          if (rawFiles != null && rawFiles is List) {
            final String? clientIdFromData =
                data['client']?['id']?.toString();
            final String clientIdToUse = clientIdFromData ?? fallbackName;

            // ✅ Ambil ppatType dari caseName
            final String ppatTypeValue =
                data['case']?['caseName'] ?? asset?['ppat_type'] ?? '';

            final List<DokumenModel> tempList = [];

            for (final f in rawFiles) {
              if (f is! Map || (f['url'] ?? '').isEmpty) continue;

              final String fileUrl = f['url'] as String;

              // ✅ Nama file = field "name" dari API,
              // ini harus sama persis dengan label yang disimpan saat upload
              final String fileName =
                  f['name']?.toString() ?? fileUrl.split('/').last;

              debugPrint("[PARSE] 📄 File: '$fileName' | URL: '$fileUrl'");
              debugPrint(
                  "[PARSE] 🔍 QueryHint: '$fileName' | ClientId: '$clientIdToUse'");

              tempList.add(
                DokumenModel(
                  nama: fileName,
                  url: fileUrl,
                  tanggal: "13 Nov 2023",
                  ppatType: ppatTypeValue,
                  queryHint: fileName, // ✅ Sama dengan label saat upload
                ),
              );
            }

            dokumenList.value = tempList;
            debugPrint(
                "[PARSE] ✅ Total dokumen: ${tempList.length}");
          }
        }
      }
    } catch (e) {
      debugPrint("ERROR HANDLER: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DISPLAY DOCUMENT
  // ✅ Pakai documentName (= queryHint) untuk cari file_id di SQLite
  // ============================================================
  Future<void> displayDocument({
    required String documentName,
    required String documentUrl,
    required String clientId,
    required String ppatType,
  }) async {
    isLoadingPpat.value = true;
    try {
      debugPrint("[DOCUMENT] ════════════════════════════════════════");
      debugPrint("[DOCUMENT] 📄 Nama      : $documentName");
      debugPrint("[DOCUMENT] 🔍 QueryHint : $documentName");
      debugPrint("[DOCUMENT] 👤 ClientId  : $clientId");
      debugPrint("[DOCUMENT] 📋 PpatType  : $ppatType");
      debugPrint("[DOCUMENT] 🌐 URL       : $documentUrl");
      debugPrint("[DOCUMENT] ════════════════════════════════════════");

      // ✅ Cari file_id berdasarkan label (queryHint) + clientId
      final String? fileId = await _getFileIdFromSqlite(
        label: documentName,
        clientId: clientId,
      );

      if (fileId == null || fileId.isEmpty) {
        debugPrint(
            "[DOCUMENT] ❌ file_id tidak ditemukan untuk: $documentName");
        Get.snackbar("Error", "File ID tidak ditemukan untuk: $documentName");
        return;
      }

      debugPrint("[DOCUMENT] 🔑 File ID: $fileId");

      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final uri = Uri.parse('$baseUrl/read-ppat').replace(
        queryParameters: {
          'ppat_type': 'WAKAF',
          'url': documentUrl,
          'id': fileId,
        },
      );

print("PPAT TYPE: $ppatType");
      debugPrint("[DOCUMENT] 📡 REQUEST: $uri");

      final response = await http.get(uri, headers: headers);

      debugPrint("[DOCUMENT] Status: ${response.statusCode}");
      debugPrint(
          "[DOCUMENT] Content-Type: ${response.headers['content-type']}");
      debugPrint(
          "[DOCUMENT] Body length: ${response.bodyBytes.length} bytes");

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        ppatImageBytes.value = imageBytes;

        debugPrint(
            "[DOCUMENT] ✅ Image received: ${imageBytes.lengthInBytes} bytes");

        // ✅ FIX: Dialog dibenahi agar tinggi menyesuaikan gambar
        // (tidak ada lagi area putih kosong di bawah foto)
        Get.dialog(
          Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: Text(documentName),
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Flexible(
                      child: InteractiveViewer(
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        debugPrint("[DOCUMENT] ❌ Error ${response.statusCode}");
        debugPrint("[DOCUMENT] ❌ Response: ${response.body}");
        Get.snackbar("Error", "Gagal load dokumen (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("[DOCUMENT] ❌ Exception: $e");
      Get.snackbar("Error", "Gagal load dokumen: $e");
      rethrow;
    } finally {
      isLoadingPpat.value = false;
    }
  }

  // ============================================================
  // ✅ HELPER: Query SQLite dengan label (queryHint) + clientId
  // Urutan: exact (label+clientId) → exact (label) → fuzzy → url fallback
  // ============================================================
  Future<String?> _getFileIdFromSqlite({
    required String label,
    required String clientId,
  }) async {
    try {
      final dbClient = await _dbHelper.db;
      final String urlSegment = label; // label = queryHint = nama file

      debugPrint("[SQLite] 🔍 Mencari file_id...");
      debugPrint("[SQLite]    label    : '$label'");
      debugPrint("[SQLite]    clientId : '$clientId'");

      // Step 1: Exact match label + clientId
      List<Map<String, dynamic>> result = await dbClient.query(
        'ppat_draft',
        where: 'label = ? AND client_id = ?',
        whereArgs: [label, clientId],
      );
      debugPrint("[SQLite] Step 1 (exact label+clientId): ${result.length} rows");

      // Step 2: Exact label saja
      if (result.isEmpty) {
        result = await dbClient.query(
          'ppat_draft',
          where: 'label = ?',
          whereArgs: [label],
        );
        debugPrint("[SQLite] Step 2 (exact label): ${result.length} rows");
      }

      // Step 3: Case-insensitive label
      if (result.isEmpty) {
        result = await dbClient.query(
          'ppat_draft',
          where: 'LOWER(label) = LOWER(?)',
          whereArgs: [label],
        );
        debugPrint(
            "[SQLite] Step 3 (case-insensitive label): ${result.length} rows");
      }

      // Step 4: Fuzzy label
      if (result.isEmpty) {
        result = await dbClient.query(
          'ppat_draft',
          where: 'label LIKE ?',
          whereArgs: ['%$label%'],
        );
        debugPrint("[SQLite] Step 4 (fuzzy label): ${result.length} rows");
      }

      if (result.isEmpty) {
        debugPrint(
            "[SQLite] ❌ Tidak ditemukan file_id untuk label='$label'");
        return null;
      }

      final fileId = result.first['file_id']?.toString();
      debugPrint("[SQLite] ✅ file_id: '$fileId'");
      return fileId;
    } catch (e) {
      debugPrint("[SQLite] ❌ Error: $e");
      return null;
    }
  }

  // ============================================================
  // FETCH READ PPAT (Image Bytes)
  // ============================================================
  Future<void> fetchReadPpat({
    required String ppatType,
    required String url,
    required String clientId,
  }) async {
    isLoadingPpat.value = true;
    try {
      final String? fileId = await _dbHelper.getFileIdByClientId(clientId);
      if (fileId == null || fileId.isEmpty) {
        debugPrint(
          "[PPAT] ❌ file_id tidak ditemukan di SQLite untuk client_id: $clientId",
        );
        return;
      }

      debugPrint("[PPAT] 🔍 client_id: $clientId");
      debugPrint("[PPAT] ✅ file_id: $fileId");

      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final uri = Uri.parse('$baseUrl/read-ppat').replace(
        queryParameters: {
          'ppat_type': 'WAKAF',
          'url': url,
          'id': fileId,
        },
      );

      debugPrint("=== [PPAT] REQUEST URL ===");
      debugPrint(uri.toString());

      final response = await http.get(uri, headers: headers);

      debugPrint("[PPAT] Status: ${response.statusCode}");
      debugPrint("[PPAT] Content-Type: ${response.headers['content-type']}");
      debugPrint("[PPAT] Body length: ${response.bodyBytes.length} bytes");

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        ppatImageBytes.value = imageBytes;
        debugPrint(
          "[PPAT] ✅ Image bytes: ${imageBytes.lengthInBytes} bytes",
        );
      } else {
        debugPrint("[PPAT] ❌ Gagal: ${response.statusCode}");
        debugPrint("[PPAT] Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("[PPAT] ❌ ERROR: $e");
      rethrow;
    } finally {
      isLoadingPpat.value = false;
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================
  Future<void> updateStatusPekerjaan(String value) async {
    statusPengerjaan.value = value.toUpperCase();
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
  }

  // ============================================================
  // WARNA STATUS
  // ============================================================
  Color getStatusPekerjaanColor(String status) {
    switch (status.toUpperCase()) {
      case 'DONE':
      case 'SELESAI':
        return AppColors.statusSelesai;
      case 'REVISI':
        return AppColors.statusRevisi;
      case 'PROSES':
      case 'ON PROGRESS':
        return AppColors.statusProses;
      case 'PENDING':
      default:
        return AppColors.statusProses;
    }
  }

  Color getStatusPekerjaanBg(String status) {
    switch (status.toUpperCase()) {
      case 'DONE':
      case 'SELESAI':
        return AppColors.statusSelesaiBg;
      case 'REVISI':
        return AppColors.statusRevisiBg;
      case 'PROSES':
      case 'ON PROGRESS':
        return AppColors.statusProsesBg;
      case 'PENDING':
      default:
        return AppColors.statusProsesBg;
    }
  }

  Color getStatusPajakColor(String status) {
    switch (status) {
      case 'Lunas':
        return AppColors.statusSelesai;
      case 'Belum Bayar':
      default:
        return AppColors.statusProses;
    }
  }

  Color getStatusPajakBg(String status) {
    switch (status) {
      case 'Lunas':
        return AppColors.statusSelesaiBg;
      case 'Belum Bayar':
      default:
        return AppColors.statusProsesBg;
    }
  }
}