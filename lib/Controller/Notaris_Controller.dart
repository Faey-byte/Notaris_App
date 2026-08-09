import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  final List<String> transactionTypes;
  final String aktaNature;
  final int penghadapCount;

  const AktaItem({
    required this.berkasId,
    required this.nama,
    required this.jenis,
    required this.no,
    required this.tanggal,
    required this.status,
    this.transactionTypes = const [],
    this.aktaNature = '',
    this.penghadapCount = 0,
  });
}

class NotarisController extends GetxController {
  late final DbHelper dbHelper;
  static const String baseUrl = "${ApiConfig.baseUrl}";

  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'SEMUA'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  static const int _limit = 5;

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
    loadFromServer(reset: true);
  }

  String _mapStatus(String? rawStatus) {
    switch ((rawStatus ?? '').toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'proses':
      case 'in_progress':
      case 'process':
        return 'PROSES';
      case 'selesai':
      case 'done':
      case 'completed':
        return 'SELESAI';
      case 'revisi':
      case 'revision':
        return 'REVISI';
      case 'ditolak':
      case 'rejected':
        return 'DITOLAK';
      default:
        return 'PENDING';
    }
  }

  // ✅ NEW: ubah "2026-08-05" jadi "5 Agustus 2026"
  String _formatTanggalManusiawi(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  // ✅ NEW: berkasId di-pass, dipakai buat cek cache lokal status pengerjaan
  AktaItem _mapItem(Map<String, dynamic> item, SharedPreferences prefs) {
    final client = item['client'] as Map<String, dynamic>?;
    final nama = client?['name']?.toString() ?? '-';
    final rawTypes = item['transaction_types'];
    final types = (rawTypes is List)
        ? rawTypes.map((e) => e.toString()).toList()
        : <String>[];
    final jenis = types.isNotEmpty ? types.join(', ') : '-';
    final monthlyNumber = item['monthly_number'];
    final no = monthlyNumber != null ? monthlyNumber.toString() : '-';
    // ✅ CHANGED: format tanggal jadi human-readable, bukan yyyy-mm-dd lagi
    final tanggal = _formatTanggalManusiawi(item['akta_date']?.toString());
    final berkasId = item['id']?.toString() ?? '';

    // Status dari backend (source of truth default)
    var status = _mapStatus(item['status']?.toString());

    // ✅ NEW: kalau ada override lokal (mis. user pilih "PROSES" yang secara
    // backend sebenarnya sama-sama tersimpan sebagai "pending"), pakai itu.
    // Ini harus konsisten dengan key yang dipakai di DetailBerkasNotarisController:
    // 'status_notaris_${currentLocalBerkasId.value}'
    if (berkasId.isNotEmpty) {
      final cachedStatus = prefs.getString('status_notaris_$berkasId');
      if (cachedStatus != null && cachedStatus.isNotEmpty) {
        status = cachedStatus;
      }
    }

    final rawPenghadap = item['penghadap'];
    final penghadapCount = (rawPenghadap is List) ? rawPenghadap.length : 0;
    final aktaNature = item['akta_nature']?.toString() ?? '';

    return AktaItem(
      berkasId: berkasId,
      nama: nama,
      jenis: jenis,
      no: no,
      tanggal: tanggal,
      status: status,
      transactionTypes: types,
      aktaNature: aktaNature,
      penghadapCount: penghadapCount,
    );
  }

  Future<void> loadFromServer({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      allItems.clear();
    }

    if (!hasMore.value) return;

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/show-all-notary',
      ).replace(queryParameters: {'page': _currentPage.toString()});

      final response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Server Error (${response.statusCode}): ${response.body}",
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final List rawData = decoded['data'] ?? [];

      // ✅ CHANGED: pass prefs biar _mapItem bisa cek override status lokal
      final mapped = rawData
          .whereType<Map<String, dynamic>>()
          .map((raw) => _mapItem(raw, prefs))
          .toList();

      if (reset) {
        allItems.value = mapped;
      } else {
        allItems.addAll(mapped);
      }

      hasMore.value = mapped.length >= _limit;

      if (mapped.isNotEmpty) {
        _currentPage += 1;
      }
    } catch (e) {
      print("❌ [NOTARIS LIST] Gagal ambil data dari server: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat data berkas notaris",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore.value) return;
    await loadFromServer(reset: false);
  }

  Future<void> refresh() async {
    await loadFromServer(reset: true);
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