import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/data/services/auth_service.dart';
import 'package:notaris_app/data/services/logging_service.dart';
import 'package:notaris_app/utils/app_colors.dart';

class StatusModel {
  final String label;
  final dynamic color;
  final dynamic bgColor;
  StatusModel({
    required this.label,
    required this.color,
    required this.bgColor,
  });
  dynamic get textColor => color;
}

class PpatController extends GetxController {
  var search = "".obs;
  var selectedJenis = "Semua Berkas".obs;
  var selectedStatus = "SEMUA".obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  int _currentPage = 1;
  String _token = '';

  var berkasList = <BerkasModel>[].obs;
  var filteredList = <BerkasModel>[].obs;

  final String baseUrl =
      'https://teach-wiley-grid-reproduced.trycloudflare.com';

  final jenisList = [
    "Semua Berkas",
    "AJB",
    "APHB",
    "SKMHT",
    "APHT",
    "Hibah",
    "Tukar Menukar",
    "Turun Waris",
    "APHW",
    "Validasi",
    "ROYA",
    "Ralat",
    "Ganti Nama",
    "Ganti Blanko",
    "Lelang",
    "Wakaf",
  ];

  final statusList = [
    StatusModel(
      label: "SEMUA",
      color: AppColors.textSecondary,
      bgColor: AppColors.border,
    ),
    StatusModel(
      label: "PENDING",
      color: AppColors.statusProses,
      bgColor: AppColors.statusProsesBg,
    ),
    StatusModel(
      label: "PROSES",
      color: AppColors.statusProses,
      bgColor: AppColors.statusProsesBg,
    ),
    StatusModel(
      label: "SELESAI",
      color: AppColors.statusSelesai,
      bgColor: AppColors.statusSelesaiBg,
    ),
    StatusModel(
      label: "REVISI",
      color: AppColors.statusRevisi,
      bgColor: AppColors.statusRevisiBg,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initToken();
  }

  Future<void> _initToken() async {
    final savedToken = await LoggingService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      Get.offAllNamed('/login');
      return;
    }

    _token = savedToken;
    fetchBerkasData(isRefresh: true);
  }

  Map<String, String> get _headers => {
    "Accept": "application/json",
    "Authorization": "Bearer $_token",
  };

  void onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      final isNearBottom = metrics.pixels >= metrics.maxScrollExtent - 300;
      if (isNearBottom &&
          !isLoadingMore.value &&
          hasMore.value &&
          !isLoading.value) {
        fetchBerkasData();
      }
    }
  }

  Future<void> fetchBerkasData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      berkasList.clear();
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/show-all-ppat?page=$_currentPage'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List dynamicList = decoded['data'] ?? [];

        if (dynamicList.isEmpty) {
          hasMore.value = false;
        } else {
          final newItems = dynamicList
              .map((item) => BerkasModel.fromJson(item))
              .toList();

          berkasList.addAll(newItems);
          _currentPage++;

          if (dynamicList.length < 5) {
            hasMore.value = false;
          }
        }

        applyFilter();
        if (isRefresh) fetchLiveGraphQLStatus();
      } else if (response.statusCode == 401) {
        await LoggingService.clearLoginData();
        Get.offAllNamed('/login');
      } else {
        Get.snackbar("Error", "Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Koneksi Bermasalah", "Gagal terhubung ke REST API.");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchLiveGraphQLStatus() async {
    if (berkasList.isEmpty) return;
    try {
      const String query = r'''
        query getPpatRecords {
          getPpatRecords { id status_pengerjaan }
        }
      ''';
      final response = await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: json.encode({"query": query}),
      );
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        final List? serverData = resBody['data']?['getPpatRecords'];
        if (serverData != null) {
          for (var item in serverData) {
            final serverId = item['id']?.toString() ?? "";
            final currentStatus = item['status_pengerjaan'] ?? "PENDING";
            final index = berkasList.indexWhere((b) => b.id == serverId);
            if (index != -1) {
              (berkasList[index] as dynamic).status = currentStatus;
            }
          }
          berkasList.refresh();
          applyFilter();
        }
      }
    } catch (e) {
      print("Gagal sinkronisasi GraphQL: $e");
    }
  }

  void setSearch(String value) {
    search.value = value;
    applyFilter();
  }

  void setJenis(String jenis) {
    selectedJenis.value = jenis;
    applyFilter();
  }

  void setStatus(String status) {
    selectedStatus.value = status;
    applyFilter();
  }

  void applyFilter() {
    filteredList.value = berkasList.where((item) {
      final matchSearch = item.client.name.toLowerCase().contains(
        search.value.toLowerCase(),
      );
      final matchJenis = selectedJenis.value == "Semua Berkas"
          ? true
          : item.caseData.caseName.toLowerCase() ==
                selectedJenis.value.toLowerCase();
      final matchStatus = selectedStatus.value == "SEMUA"
          ? true
          : item.status.toUpperCase() == selectedStatus.value.toUpperCase();
      return matchSearch && matchJenis && matchStatus;
    }).toList();
  }

  void goToTambah() => Get.to(() => TambahPekerjaanPage());

  void onBottomNavTap(int index) {
    if (index == 3) Get.offAll(() => CalculatorPage());
  }
}
