import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:notaris_app/Model/notaris_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DetailBerkasNotarisController extends GetxController {
  late final DbHelper dbHelper;
  static const String baseUrl = "${ApiConfig.baseUrl}";

  final RxBool isLoading = true.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxBool isUpdatingStatusPajak = false.obs;
  final Rxn<NotarisDetailModel> detail = Rxn<NotarisDetailModel>();
  final RxList<NotarisPenghadapModel> penghadapList =
      <NotarisPenghadapModel>[].obs;
  final RxString fallbackName = ''.obs;
  final RxString publicId = ''.obs;
  final RxString statusPengerjaan = 'PENDING'.obs;
  final RxString statusPajak = 'Belum Lunas'.obs;
  final RxInt titipBiayaAmount = 0.obs;
  final RxString titipBiayaAmountFormatted = ''.obs;
  final RxString totalBiaya = '-'.obs;
  final RxString namaStaff = '-'.obs;
  final RxString jenisPekerjaan = '-'.obs;
  final RxList<NotarisDocMetadata> dokumenList = <NotarisDocMetadata>[].obs;

  // ✅ NEW: field tambahan dari detail berkas
  final RxString sifatAkta = '-'.obs;
  final RxString tanggalAkta = '-'.obs;
  final RxString statusPerkawinan = '-'.obs;
  final RxString keterangan = ''.obs;

  final RxString currentLocalBerkasId = ''.obs;

  int transactionId = 0;

  static const Map<String, String> statusLabelToAction = {
    "PENDING": "pending",
    "PROSES": "pending",
    "REVISI": "revision",
    "SELESAI": "done",
    "DITOLAK": "reject",
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

  static String _formatRupiah(int amount) {
    if (amount <= 0) return "";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // ✅ NEW: kapitalisasi tiap kata, contoh "pendirian cv" -> "Pendirian Cv"
  static String _capitalizeWords(String value) {
    if (value.trim().isEmpty) return '-';
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ✅ NEW: format tanggal akta "2026-08-05" -> "05 Agustus 2026"
  static String _formatTanggalAkta(String rawDate) {
    if (rawDate.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

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

    if (localBerkasId != null) {
      currentLocalBerkasId.value = localBerkasId;
    }
    await fetchDetail(clientName: clientName, publicId: publicIdParam);
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
        headers: {if (token.isNotEmpty) 'Authorization': 'Bearer $token'},
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

      if (currentLocalBerkasId.isNotEmpty) {
        final savedStatus = prefs.getString(
          'status_notaris_${currentLocalBerkasId.value}',
        );
        statusPengerjaan.value =
            savedStatus ?? labelFromBackendStatus(model.status);

        final savedStatusPajak = prefs.getString(
          'status_pajak_notaris_${currentLocalBerkasId.value}',
        );
        statusPajak.value =
            savedStatusPajak ??
            statusPajakLabelFromBackend(model.paymentStatus);
      } else {
        statusPengerjaan.value = labelFromBackendStatus(model.status);
        statusPajak.value = statusPajakLabelFromBackend(model.paymentStatus);
      }

      titipBiayaAmount.value = model.titipBiayaInput ?? 0;
      titipBiayaAmountFormatted.value = _formatRupiah(titipBiayaAmount.value);
      totalBiaya.value = model.amount > 0 ? _formatRupiah(model.amount) : '-';
      print("💰 [NOTARIS DETAIL] amount dari backend: ${model.amount}");

      namaStaff.value = model.staff.staffName.isEmpty
          ? '-'
          : model.staff.staffName;

      jenisPekerjaan.value = model.transactionTypes.isNotEmpty
          ? model.transactionTypes.join(', ').toUpperCase()
          : '-';

      // ✅ NEW: isi field tambahan dari detail berkas
      sifatAkta.value = _capitalizeWords(model.aktaNature);
      tanggalAkta.value = _formatTanggalAkta(model.aktaDate);
      statusPerkawinan.value = _capitalizeWords(model.lifeStatus);
      keterangan.value = model.description.trim();

      dokumenList.value = model.documentTransaction?.asset.metadata ?? [];

      // ✅ NEW: urutkan penghadap berdasarkan OrderNumber sebelum ditampilkan
      final sortedPenghadap = [...model.penghadap]
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      penghadapList.value = sortedPenghadap;
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

  void publicId2(String value) {
    publicId.value = value;
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final url = Uri.parse(
        '$baseUrl/api/v1/notary/transactions/$transactionId/progress',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({"action": action}),
      );

      print("=== UPDATE STATUS NOTARIS ===");
      print("URL: $url");
      print("Action dikirim: $action");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (currentLocalBerkasId.value.isNotEmpty) {
          await prefs.setString(
            'status_notaris_${currentLocalBerkasId.value}',
            label,
          );
          print(
            "💾 [LOCAL CACHE] Berhasil menyimpan status baru ($label) untuk ID: ${currentLocalBerkasId.value}",
          );
        }
      } else {
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final url = Uri.parse(
        '$baseUrl/api/v1/managamenet/payment/progress/notary',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "notaryTransactionID": transactionId,
          "status": backendStatus,
          "titipBiayaAmount": amount,
        }),
      );

      print("=== UPDATE STATUS PAJAK NOTARIS ===");
      print("URL: $url");
      print("Status dikirim: $backendStatus, titipBiayaAmount: $amount");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (currentLocalBerkasId.value.isNotEmpty) {
          await prefs.setString(
            'status_pajak_notaris_${currentLocalBerkasId.value}',
            label,
          );
        }
      } else {
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
      print("ERROR UPDATE STATUS PAJAK NOTARIS: $e");
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

  Color getStatusPekerjaanBg(String status) {
    switch (status.toUpperCase()) {
      case 'SELESAI':
        return const Color(0xFFDCFCE7);
      case 'REVISI':
        return const Color(0xFFDBEAFE);
      case 'DITOLAK':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
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
        return const Color(0xFFB45309);
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

    print("=== SHOW AES ENC FILE TEAM (NOTARIS) ===");
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

  Future<void> displayNotarisDocument({
    required BuildContext context,
    required NotarisDocMetadata document,
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

      String resolvedId = "";
      try {
        final teamFiles = await _fetchAesEncFileTeam();
        final matchedId = _resolveIdFromTeamList(teamFiles, document.url);
        if (matchedId != null && matchedId.isNotEmpty) {
          resolvedId = matchedId;
        }
      } catch (e) {
        print("⚠️ [AES ENC FILE TEAM ERROR] $e");
      }

      final uri = Uri.parse('$baseUrl/api/v1/read-notary').replace(
        queryParameters: {
          'notary_type': detail.value?.transactionTypes.isNotEmpty == true
              ? detail.value!.transactionTypes.first
              : '',
          'url': document.url,
          'id': resolvedId,
        },
      );

      print("=== READ NOTARIS (displayNotarisDocument) ===");
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
      print("ERROR READ NOTARIS (displayNotarisDocument): $e");
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