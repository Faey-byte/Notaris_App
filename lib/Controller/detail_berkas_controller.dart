import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/ppat_model.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/data/services/logging_service.dart';

class DetailBerkasController extends GetxController {
  static const String baseUrl = "${ApiConfig.baseUrl}";

  static const Map<String, String> statusLabelToAction = {
    "PENDING": "pending",
    "REVISI": "revision",
    "SELESAI": "done",
    "PROSES": "reject",
  };

  static const Map<String, String> backendStatusToLabel = {
    "pending": "PENDING",
    "revision": "REVISI",
    "done": "SELESAI",
    "rejected": "PROSES",
  };

  static String labelFromBackendStatus(String? backendStatus) {
    final key = (backendStatus ?? "pending").toLowerCase().trim();
    return backendStatusToLabel[key] ?? key.toUpperCase();
  }

  static const Map<String, String> statusPajakLabelToBackend = {
    "Belum Lunas": "BelumLunas",
    "Lunas": "Lunas",
    "Titip Biaya": "TitipBiaya",
  };

  static const Map<String, String> backendToStatusPajakLabel = {
    "BelumLunas": "Belum Lunas",
    "Lunas": "Lunas",
    "TitipBiaya": "Titip Biaya",
  };

  static String statusPajakLabelFromBackend(String? backendStatus) {
    final key = (backendStatus ?? "BelumLunas").trim();
    return backendToStatusPajakLabel[key] ?? key;
  }

  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isUpdatingStatusPajak = false.obs;

  var publicId = "".obs;
  var alamat = "Tidak ada lokasi".obs;
  var totalBiaya = "Rp 0".obs;
  var statusPajak = "Belum Lunas".obs;
  var titipBiayaAmount = 0.obs;
  var titipBiayaAmountFormatted = "".obs;
  var statusPengerjaan = "PENDING".obs;
  var namaStaff = "Sistem Otomatis".obs;

  var dokumenList = <PpatDocMetadata>[].obs;

  var jenisTransaksi = "".obs;

  String fallbackName = "";
  String fallbackPublicID = "";
  int transactionId = 0;

  static String _formatRupiah(int amount) {
    if (amount <= 0) return "";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void initData(PpatDetailModel? data) {
    if (data != null) {
      fallbackName = data.client.name;
      fallbackPublicID = data.client.publicId;

      publicId.value = fallbackPublicID;
      transactionId = data.id;
      statusPengerjaan.value = labelFromBackendStatus(data.status);

      jenisTransaksi.value = data.caseData.caseName;

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
          '$baseUrl/api/v1/show-detailing-byClient'
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
        namaStaff.value =
            staff?['StaffName'] ?? staff?['name'] ?? "Sistem Otomatis";

        final client = data['client'];
        publicId.value =
            client?['publicID'] ?? client?['public_id'] ?? fallbackPublicID;

        final rawId = data['id'];
        if (rawId is int) {
          transactionId = rawId;
        } else if (rawId is String) {
          transactionId = int.tryParse(rawId) ?? transactionId;
        }

        statusPengerjaan.value = labelFromBackendStatus(
          data['status']?.toString(),
        );

        statusPajak.value = statusPajakLabelFromBackend(
          data['payment_status']?.toString(),
        );

        if (jenisTransaksi.value.isEmpty) {
          final caseData =
              data['case_data'] ?? data['caseData'] ?? data['case'];
          jenisTransaksi.value =
              (caseData?['case_name'] ?? caseData?['caseName'] ?? '')
                  .toString();
        }

        final rawTitip = data['titip_biaya_input'];
        if (rawTitip is int) {
          titipBiayaAmount.value = rawTitip;
        } else if (rawTitip is String) {
          titipBiayaAmount.value =
              int.tryParse(rawTitip.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        } else {
          titipBiayaAmount.value = 0;
        }
        titipBiayaAmountFormatted.value = _formatRupiah(titipBiayaAmount.value);

        final docTransaction = data['document_transaction'];
        final asset = docTransaction?['asset'];
        final metadata = asset?['metadata'];

        final dynamic rawAmount =
            data['amount'] ??
            (metadata is Map ? metadata['amount'] : null) ??
            data['total_biaya'] ??
            data['price'];

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
        totalBiaya.value = amountInt > 0 ? formatter.format(amountInt) : "Rp 0";

        List<PpatDocMetadata> fetchedDocs = [];

        if (metadata != null) {
          if (metadata is Map) {
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
            if (rawFiles is List) {
              for (var f in rawFiles) {
                if (f is Map) {
                  print("🔍 [PPAT RAW FILE] $f");

                  fetchedDocs.add(
                    PpatDocMetadata.fromJson(Map<String, dynamic>.from(f)),
                  );
                }
              }
            }
          } else if (metadata is List) {
            for (var item in metadata) {
              if (item is Map) {
                print("🔍 [PPAT RAW FILE] $item");

                fetchedDocs.add(
                  PpatDocMetadata.fromJson(Map<String, dynamic>.from(item)),
                );
              }
            }
          }
        }

        dokumenList.value = fetchedDocs;
      }
    } catch (e) {
      print("ERROR HANDLER: $e");
    } finally {
      isLoading.value = false;
    }
  }

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

    statusPengerjaan.value = label;
    isUpdatingStatus.value = true;

    try {
      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final url = Uri.parse(
        '$baseUrl/api/v1/transactions/$transactionId/progress',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({"action": action}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
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
      Get.snackbar("Gagal", "Terjadi kesalahan saat memperbarui status");
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> updateStatusPajak(String label) async {
    final backendStatus = statusPajakLabelToBackend[label];
    if (backendStatus == null) {
      Get.snackbar("Gagal", "Status pajak \"$label\" tidak dikenali");
      return;
    }

    if (transactionId == 0) {
      Get.snackbar("Gagal", "ID transaksi tidak ditemukan");
      return;
    }

    final previousLabel = statusPajak.value;
    final previousAmount = titipBiayaAmount.value;
    if (previousLabel == label) return;

    int amount = 0;
    if (backendStatus == "TitipBiaya") {
      final inputAmount = await _askTitipBiayaAmount();
      if (inputAmount == null || inputAmount <= 0) {
        return;
      }
      amount = inputAmount;
    }

    statusPajak.value = label;
    titipBiayaAmount.value = amount;
    titipBiayaAmountFormatted.value = _formatRupiah(amount);
    isUpdatingStatusPajak.value = true;

    try {
      final String? token = await LoggingService.getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final url = Uri.parse('$baseUrl/api/v1/managamenet/payment/progress');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "transactionID": transactionId,
          "status": backendStatus,
          "titipBiayaAmount": amount,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        statusPajak.value = previousLabel;
        titipBiayaAmount.value = previousAmount;
        titipBiayaAmountFormatted.value = _formatRupiah(previousAmount);

        String message = "Status pembayaran gagal diperbarui";
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
      statusPajak.value = previousLabel;
      titipBiayaAmount.value = previousAmount;
      titipBiayaAmountFormatted.value = _formatRupiah(previousAmount);
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan saat memperbarui status pembayaran",
      );
    } finally {
      isUpdatingStatusPajak.value = false;
    }
  }

  Future<int?> _askTitipBiayaAmount() async {
    final textController = TextEditingController(
      text: titipBiayaAmount.value > 0 ? titipBiayaAmount.value.toString() : "",
    );

    final result = await Get.dialog<int?>(
      AlertDialog(
        title: const Text("Titip Biaya"),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Masukkan nominal titip biaya",
            prefixText: "Rp ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              final raw = textController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final parsed = int.tryParse(raw);
              if (parsed == null || parsed <= 0) {
                Get.snackbar("Gagal", "Nominal titip biaya harus lebih dari 0");
                return;
              }
              Get.back(result: parsed);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result;
  }

  Color getStatusPekerjaanColor(String status) => AppColors.statusProses;
  Color getStatusPekerjaanBg(String status) => AppColors.statusProsesBg;

  Color getStatusPajakColor(String status) {
    switch (status) {
      case 'Lunas':
        return const Color(0xFF15803D);
      case 'Titip Biaya':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFFB91C1C);
    }
  }

  Color getStatusPajakBg(String status) {
    switch (status) {
      case 'Lunas':
        return const Color(0xFFDCFCE7);
      case 'Titip Biaya':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFFEE2E2);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAesEncFileTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? "";
    final teamKey = prefs.getString('teamkey') ?? "";

    if (token.isEmpty) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }
    if (teamKey.isEmpty) {
      throw Exception("TeamKey tidak ditemukan. Silakan login ulang.");
    }

    final uri = Uri.parse('$baseUrl/api/v1/show/aes/enc/fileTeam');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"aes_institute_key": teamKey}),
    );

    print("=== SHOW AES ENC FILE TEAM ===");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Gagal mengambil daftar file team (${response.statusCode})",
      );
    }

    final decoded = json.decode(response.body);
    if (decoded is Map &&
        decoded['success'] == true &&
        decoded['data'] is List) {
      return List<Map<String, dynamic>>.from(
        (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    return [];
  }

  String? _resolveIdFromTeamList(
    List<Map<String, dynamic>> teamFiles,
    String documentUrl,
  ) {
    final normalizedTarget = documentUrl.trim();

    for (final item in teamFiles) {
      final itemUrl = (item['url_file'] ?? '').toString().trim();
      if (itemUrl.isNotEmpty && itemUrl == normalizedTarget) {
        final aesKey = (item['file_aes_key'] ?? '').toString();
        if (aesKey.isNotEmpty) {
          print("✅ [MATCH TEAM FILE] url: $itemUrl -> file_aes_key: $aesKey");
          return aesKey;
        }
      }
    }

    print(
      "⚠️ [NO MATCH TEAM FILE] Tidak ada url_file yang cocok dengan: $normalizedTarget",
    );
    return null;
  }

  Future<void> displayDocument({
    required BuildContext context,
    required String documentName,
    required String documentUrl,
    required String clientId,
    required String? fileId,
    required String? ppatType,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";
      String resolvedId = (fileId != null && fileId.isNotEmpty)
          ? fileId
          : clientId;

      try {
        final teamFiles = await _fetchAesEncFileTeam();
        final matchedId = _resolveIdFromTeamList(teamFiles, documentUrl);
        if (matchedId != null && matchedId.isNotEmpty) {
          resolvedId = matchedId;
        }
      } catch (e) {
        print("⚠️ [AES ENC FILE TEAM ERROR] Fallback ke id lama: $e");
      }

      final uri = Uri.parse('$baseUrl/api/v1/read-ppat').replace(
        queryParameters: {
          'ppat_type': ppatType ?? '',
          'url': documentUrl,
          'id': resolvedId,
        },
      );

      print("=== READ PPAT (displayDocument) ===");
      print("URL: $uri");

      final response = await http.get(
        uri,
        headers: {if (token.isNotEmpty) 'Authorization': 'Bearer $token'},
      );

      print("Status: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("Body: ${response.body}");
      }

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (response.statusCode == 200) {
        _tampilkanPopupGambar(context, response.bodyBytes);
      } else {
        String message = "Gagal memuat berkas (Status: ${response.statusCode})";
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        Get.snackbar("Error", message);
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print("ERROR READ PPAT (displayDocument): $e");
      Get.snackbar("Error", "Gagal memuat berkas: $e");
    }
  }

  void _tampilkanPopupGambar(BuildContext context, Uint8List bytes) {
    bool isPdf = false;
    if (bytes.length >= 4) {
      if (bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        isPdf = true;
      }
    }

    if (isPdf) {
      Get.snackbar(
        "Format PDF Detected",
        "Dokumen ini berformat PDF, gunakan PDF Viewer untuk membuka.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Gagal menampilkan file.\nFormat file tidak didukung sebagai Gambar.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
