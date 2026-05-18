import 'package:get/get.dart';

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

  void logout() {
    // TODO: tambahkan logika logout di sini
    // Contoh: Get.offAllNamed('/login');
  }
}