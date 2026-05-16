import 'dart:convert';
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

  var berkasList = <BerkasModel>[].obs;
  var filteredList = <BerkasModel>[].obs;

  final String baseUrl = 'https://desktops-effectively-filename-attached.trycloudflare.com';

  final jenisList = [
    "Semua Berkas", "AJB", "APHB", "SKMHT", "APHT", "Hibah",
    "Tukar Menukar", "Turun Waris", "APHW", "Validasi",
    "ROYA", "Ralat", "Ganti Nama", "Ganti Blanko", "Lelang", "Wakaf",
  ];

  final statusList = [
    StatusModel(label: "SEMUA", color: AppColors.textSecondary, bgColor: AppColors.border),
    StatusModel(label: "PENDING", color: AppColors.statusProses, bgColor: AppColors.statusProsesBg),
    StatusModel(label: "PROSES", color: AppColors.statusProses, bgColor: AppColors.statusProsesBg),
    StatusModel(label: "SELESAI", color: AppColors.statusSelesai, bgColor: AppColors.statusSelesaiBg),
    StatusModel(label: "REVISI", color: AppColors.statusRevisi, bgColor: AppColors.statusRevisiBg),
  ];

  @override
  void onInit() {
    super.onInit();
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
    }
  }

  Future<void> fetchLiveGraphQLStatus() async {
    if (berkasList.isEmpty) return;

    try {
      const String query = r'''
        query getPpatRecords {
          getPpatRecords {
            id
            status_pengerjaan
          }
        }
      ''';

      final response = await http.post(
        Uri.parse('$baseUrl/graphql'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"query": query}),
      );

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
            }
          }
          berkasList.refresh();
          applyFilter();
        }
      }
    } catch (e) {
      print("Gagal Sinkronisasi Status GraphQL: $e");
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
      final matchSearch = item.nama.toLowerCase().contains(search.value.toLowerCase());

      final matchJenis = selectedJenis.value == "Semua Berkas"
          ? true
          : item.jenis.toLowerCase() == selectedJenis.value.toLowerCase();

      final matchStatus = selectedStatus.value == "SEMUA"
          ? true
          : item.status.toUpperCase() == selectedStatus.value.toUpperCase();

      return matchSearch && matchJenis && matchStatus;
    }).toList();
  }

  void goToTambah() {
    Get.to(() => TambahPekerjaanPage());
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 2:
        break;
      case 3:
        Get.offAll(() => CalculatorPage());
        break;
    }
  }
}