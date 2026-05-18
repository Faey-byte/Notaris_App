import 'dart:convert';
<<<<<<< HEAD
import 'package:flutter/material.dart';
=======
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/utils/app_colors.dart';

class StatusModel {
  final String label;
  final dynamic color;
  final dynamic bgColor;
<<<<<<< HEAD
=======

>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
  StatusModel({
    required this.label,
    required this.color,
    required this.bgColor,
  });
<<<<<<< HEAD
=======

>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
  dynamic get textColor => color;
}

class PpatController extends GetxController {
  var search = "".obs;
  var selectedJenis = "Semua Berkas".obs;
  var selectedStatus = "SEMUA".obs;
  var isLoading = false.obs;
<<<<<<< HEAD
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  int _currentPage = 1;
=======
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111

  var berkasList = <BerkasModel>[].obs;
  var filteredList = <BerkasModel>[].obs;

<<<<<<< HEAD
  final String baseUrl =
      'https://should-achieved-pentium-bool.trycloudflare.com';
  final String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOjEsImVtYWlsIjoibWlraGFlbGpob24yMkBnbWFpbC5jb20iLCJpYXQiOjE3NzkwNzYxMzksImV4cCI6MTc3OTE2MjUzOX0.rCGJ0YtQUaIpWbWjhemyAqpSpTpMcntvabVzPdCKWmY';
=======
  final String baseUrl = 'https://desktops-effectively-filename-attached.trycloudflare.com';
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111

  final jenisList = [
    "Semua Berkas", "AJB", "APHB", "SKMHT", "APHT", "Hibah",
    "Tukar Menukar", "Turun Waris", "APHW", "Validasi",
    "ROYA", "Ralat", "Ganti Nama", "Ganti Blanko", "Lelang", "Wakaf",
  ];

  final statusList = [
<<<<<<< HEAD
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
=======
    StatusModel(label: "SEMUA", color: AppColors.textSecondary, bgColor: AppColors.border),
    StatusModel(label: "PENDING", color: AppColors.statusProses, bgColor: AppColors.statusProsesBg),
    StatusModel(label: "PROSES", color: AppColors.statusProses, bgColor: AppColors.statusProsesBg),
    StatusModel(label: "SELESAI", color: AppColors.statusSelesai, bgColor: AppColors.statusSelesaiBg),
    StatusModel(label: "REVISI", color: AppColors.statusRevisi, bgColor: AppColors.statusRevisiBg),
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
  ];

  @override
  void onInit() {
    super.onInit();
<<<<<<< HEAD
    fetchBerkasData(isRefresh: true);
  }

  // Dipanggil dari UI via NotificationListener
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
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
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
      } else {
        Get.snackbar("Error", "Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Koneksi Bermasalah", "Gagal terhubung ke REST API.");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
=======
    fetchBerkasData();
  }

  Future<void> fetchBerkasData() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/get-all-ppat-documents'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final List dynamicList = json.decode(response.body);

        berkasList.value = dynamicList.map((json) => BerkasModel.fromJson(json)).toList();
        applyFilter();

        fetchLiveGraphQLStatus();
      } else {
        Get.snackbar("Error", "Gagal memuat data dari REST API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error REST API: $e");
      Get.snackbar("Koneksi Bermasalah", "Gagal terhubung ke REST API.");
    } finally {
      isLoading.value = false;
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
    }
  }

  Future<void> fetchLiveGraphQLStatus() async {
    if (berkasList.isEmpty) return;
<<<<<<< HEAD
    try {
      const String query = r'''
        query getPpatRecords {
          getPpatRecords { id status_pengerjaan }
        }
      ''';
=======

    try {
      const String query = r'''
        query getPpatRecords {
          getPpatRecords {
            id
            status_pengerjaan
          }
        }
      ''';

>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
      final response = await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"query": query}),
      );
<<<<<<< HEAD
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
=======

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        final List? serverData = resBody['data']?['getPpatRecords'];

        if (serverData != null) {
          for (var item in serverData) {
            String serverId = item['id']?.toString() ?? "";
            String currentStatus = item['status_pengerjaan'] ?? "PENDING";

            int index = berkasList.indexWhere((berkas) => berkas.id == serverId);
            if (index != -1) {
              berkasList[index].status = currentStatus; 
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
            }
          }
          berkasList.refresh();
          applyFilter();
        }
      }
    } catch (e) {
<<<<<<< HEAD
      print("Gagal sinkronisasi GraphQL: $e");
=======
      print("Gagal Sinkronisasi Status GraphQL: $e");
>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
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
<<<<<<< HEAD
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
=======
      final matchSearch = item.nama.toLowerCase().contains(search.value.toLowerCase());

      final matchJenis = selectedJenis.value == "Semua Berkas"
          ? true
          : item.jenis.toLowerCase() == selectedJenis.value.toLowerCase();

      final matchStatus = selectedStatus.value == "SEMUA"
          ? true
          : item.status.toUpperCase() == selectedStatus.value.toUpperCase();

>>>>>>> 51c62cdcb0ea11fd6782ec84e3544823243dd111
      return matchSearch && matchJenis && matchStatus;
    }).toList();
  }

  void goToTambah() => Get.to(() => TambahPekerjaanPage());

  void onBottomNavTap(int index) {
    if (index == 3) Get.offAll(() => CalculatorPage());
  }
}
