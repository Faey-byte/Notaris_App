import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routes/routes.dart';

class HomeController extends GetxController {
  // State untuk income
  final RxString totalIncome = 'Rp 145.500.000'.obs;
  final RxString incomeGrowth = '+12.5%'.obs;

  // State untuk quick overview stats
  final RxString notarisFiles = '124'.obs;
  final RxString ppatFiles = '86'.obs;
  final RxString inProcess = '12'.obs;
  final RxString completed = '198'.obs;

  // State untuk notifikasi
  final RxBool hasNotification = true.obs;

  // Fungsi Logout dengan Dialog Konfirmasi
  void logout() {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "Apakah Anda yakin ingin keluar dari aplikasi?",
      textCancel: "Batal",
      textConfirm: "Ya, Keluar",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626), // Warna merah solid
      cancelTextColor: const Color(0xFF64748B),
      onConfirm: () async {
        try {
          // 1. Inisialisasi SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          
          // 2. Hapus token otentikasi dari local storage
          await prefs.remove('auth_token');
          print("TOKEN BERHASIL DIHAPUS DARI STORAGE");

          // 3. Bersihkan data/state controller GetX yang tertinggal di memory
          Get.deleteAll(force: true);

          // 4. Berikan pesan info sukses
          Get.snackbar(
            "Logout Berhasil", 
            "Anda telah keluar dari akun manajemen",
            backgroundColor: const Color(0xFFFEF2F2),
            colorText: const Color(0xFFDC2626),
          );

          // 5. Tendang user kembali ke halaman Login & hapus seluruh tumpukan halaman belakang
          Get.offAllNamed(AppRoutes.loginpage);
          
        } catch (e) {
          print("ERROR LOGOUT: $e");
          Get.snackbar("Error", "Gagal melakukan logout, coba lagi.");
        }
      },
    );
  }
}