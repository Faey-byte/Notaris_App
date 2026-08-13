import 'package:get/get.dart';
import 'package:notaris_app/Pages/home_page.dart';
import 'package:notaris_app/Pages/notaris_page.dart';
import 'package:notaris_app/Pages/Ppat_Page.dart';
import 'package:notaris_app/Pages/calculator_page.dart';
import 'package:notaris_app/Controller/rekap_laporan_controller.dart';

class MainNavHandler {
  static void handleTap(int index) {
    switch (index) {
      case 0:
        Get.offAll(() => HomePage());
        break;
      case 1:
        Get.offAll(() => NotarisPage());
        break;
      case 2:
        Get.offAll(() => PpatPage());
        break;
      case 3:
        Get.offAll(() => CalculatorPage());
        break;
      case 4:
        Get.offAll(() => const RekapLaporanController());
        break;
    }
  }
}
