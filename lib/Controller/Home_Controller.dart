import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routes/routes.dart';

class HomeController extends GetxController {
  static const String baseUrl = "${ApiConfig.baseUrl}";

  final RxString totalIncome = 'Rp 0'.obs;
  final RxString incomeGrowth = '0%'.obs;

  final RxBool isLoadingIncome = false.obs;

  final RxString notarisFiles = '0'.obs;
  final RxString ppatFiles = '0'.obs;
  final RxString inProcess = '0'.obs;
  final RxString completed = '0'.obs;

  final RxBool isLoadingSummary = false.obs;

  final RxBool hasNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    fetchTotalIncome();
  }

  Future<void> fetchTotalIncome() async {
    try {
      isLoadingIncome.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final uri = Uri.parse('$baseUrl/api/v1/get-total-amount');

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print("=== TOTAL INCOME ===");
      print("URL: $uri");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Gagal memuat total pemasukan (Status: ${response.statusCode})",
        );
      }

      final decoded = json.decode(response.body);

      if (decoded['success'] != true) {
        throw Exception("Response dari server menyatakan status gagal.");
      }

      final dynamic rawAmount = decoded['current_amount'];
      int amountInt = 0;

      if (rawAmount is int) {
        amountInt = rawAmount;
      } else if (rawAmount is double) {
        amountInt = rawAmount.toInt();
      } else if (rawAmount is String) {
        amountInt =
            int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }

      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      totalIncome.value = formatter.format(amountInt);

      final dynamic rawPercentage = decoded['percentage'];
      num percentageNum = 0;

      if (rawPercentage is num) {
        percentageNum = rawPercentage;
      } else if (rawPercentage is String) {
        percentageNum = num.tryParse(rawPercentage) ?? 0;
      }

      if (percentageNum > 0) {
        incomeGrowth.value = '+$percentageNum%';
      } else {
        incomeGrowth.value = '$percentageNum%';
      }
    } catch (e) {
      print("❌ [TOTAL INCOME ERROR]: $e");
    } finally {
      isLoadingIncome.value = false;
    }
  }

  Future<void> fetchDashboardSummary() async {
    try {
      isLoadingSummary.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final uri = Uri.parse('$baseUrl/api/v1/dashboard/summary');

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print("=== DASHBOARD SUMMARY ===");
      print("URL: $uri");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Gagal memuat ringkasan (Status: ${response.statusCode})",
        );
      }

      final decoded = json.decode(response.body);

      if (decoded['status'] != true || decoded['data'] == null) {
        throw Exception(
          decoded['message']?.toString() ?? "Data ringkasan tidak valid",
        );
      }

      final data = decoded['data'];

      notarisFiles.value = (data['notaris_file'] ?? 0).toString();
      ppatFiles.value = (data['ppat_file'] ?? 0).toString();
      inProcess.value = (data['process'] ?? 0).toString();
      completed.value = (data['finished'] ?? 0).toString();
    } catch (e) {
      print("❌ [DASHBOARD SUMMARY ERROR]: $e");
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void logout() {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "Apakah Anda yakin ingin keluar dari aplikasi?",
      textCancel: "Batal",
      textConfirm: "Ya, Keluar",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      cancelTextColor: const Color(0xFF64748B),
      onConfirm: () async {
        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.remove('auth_token');
          print("TOKEN BERHASIL DIHAPUS DARI STORAGE");

          Get.deleteAll(force: true);

          Get.snackbar(
            "Logout Berhasil",
            "Anda telah keluar dari akun manajemen",
            backgroundColor: const Color(0xFFFEF2F2),
            colorText: const Color(0xFFDC2626),
          );

          Get.offAllNamed(AppRoutes.loginpage);
        } catch (e) {
          print("ERROR LOGOUT: $e");
          Get.snackbar("Error", "Gagal melakukan logout, coba lagi.");
        }
      },
    );
  }
}
