import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/data/db_Helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusItem {
  final String label;
  final Color textColor;
  final Color bgColor;
  StatusItem({
    required this.label,
    required this.textColor,
    required this.bgColor,
  });
}

class AktaItem {
  final String berkasId;
  final String nama;
  final String jenis;
  final String no;
  final String tanggal;
  final String status;
  const AktaItem({
    required this.berkasId,
    required this.nama,
    required this.jenis,
    required this.no,
    required this.tanggal,
    required this.status,
  });
}

class NotarisController extends GetxController {
  late final DbHelper dbHelper;
  static const String baseUrl = "${ApiConfig.baseUrl}";

  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'SEMUA'.obs;
  final RxBool isLoading = false.obs;

  final statusList = [
    StatusItem(
      label: 'SEMUA',
      textColor: const Color(0xFF64748B),
      bgColor: const Color(0xFFF1F5F9),
    ),
    StatusItem(
      label: 'PENDING',
      textColor: const Color(0xFFB45309),
      bgColor: const Color(0xFFFEF3C7),
    ),
    StatusItem(
      label: 'PROSES',
      textColor: const Color(0xFFB45309),
      bgColor: const Color(0xFFFEF3C7),
    ),
    StatusItem(
      label: 'SELESAI',
      textColor: const Color(0xFF15803D),
      bgColor: const Color(0xFFDCFCE7),
    ),
    StatusItem(
      label: 'REVISI',
      textColor: const Color(0xFF1D4ED8),
      bgColor: const Color(0xFFDBEAFE),
    ),
    StatusItem(
      label: 'DITOLAK',
      textColor: const Color(0xFFDC2626),
      bgColor: const Color(0xFFFEE2E2),
    ),
  ];

  final RxList<AktaItem> allItems = <AktaItem>[].obs;

  @override
  void onInit() {
    dbHelper = DbHelper();
    super.onInit();
    loadFromLocal();
  }

  Future<void> loadFromLocal() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();

      final rows = await dbHelper.getAllNotarisDraft();

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var row in rows) {
        final berkasId = row['berkas_id']?.toString() ?? '';
        if (berkasId.isEmpty) continue;
        grouped.putIfAbsent(berkasId, () => []).add(row);
      }

      final List<AktaItem> hasil = [];

      grouped.forEach((berkasId, fields) {
        String getLabel(String label) {
          final match = fields.firstWhereOrNull((f) => f['label'] == label);
          return match?['text_value']?.toString() ?? '';
        }

        final nama = getLabel('Nama Klien/Perusahaan');
        final no = getLabel('Nomor Akta');
        final jenis = getLabel('Jenis Pekerjaan');

        String tanggal = '-';
        final parts = berkasId.split('_');
        if (parts.length == 2) {
          final ms = int.tryParse(parts[1]);
          if (ms != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(ms);
            tanggal =
                "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
          }
        }

        final statusTerupdate =
            prefs.getString('status_notaris_$berkasId') ?? 'PENDING';

        if (nama.isEmpty) return;

        hasil.add(
          AktaItem(
            berkasId: berkasId,
            nama: nama,
            jenis: jenis.isEmpty ? '-' : jenis,
            no: no.isEmpty ? '-' : no,
            tanggal: tanggal,
            status: statusTerupdate,
          ),
        );
      });

      allItems.value = hasil;
    } catch (e) {
      print("❌ [NOTARIS LIST] Gagal ambil data lokal: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat data berkas notaris",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<int>?> fetchNotaryImage({
    required String notaryType,
    required String url,
    required String id,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final uri = Uri.parse('$baseUrl/api/v1/read-notary').replace(
        queryParameters: {'notary_type': notaryType, 'url': url, 'id': id},
      );

      final response = await http.get(
        uri,
        headers: {if (token.isNotEmpty) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Server Error (${response.statusCode}): ${response.body}",
        );
      }

      return response.bodyBytes;
    } catch (e) {
      print("❌ [NOTARIS READ IMAGE ERROR]: $e");
      return null;
    }
  }

  List<AktaItem> get filteredItems {
    List<AktaItem> hasil = allItems;

    if (selectedStatus.value != 'SEMUA') {
      hasil = hasil.where((e) => e.status == selectedStatus.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      hasil = hasil
          .where(
            (e) =>
                e.nama.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                e.no.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }

    return hasil;
  }

  void setStatus(String val) => selectedStatus.value = val;
  void setSearch(String val) => searchQuery.value = val;
}
