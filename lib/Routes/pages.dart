import 'package:get/get.dart';
import 'package:notaris_app/Pages/Splash_screen.dart';
import 'package:notaris_app/Pages/Tambah_Berkas_Notaris.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/dynamic_form_page.dart';
import 'package:notaris_app/Pages/Ppat_Page.dart'; // Memastikan case-sensitive folder aman
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/Pages/Profile_Page.dart';
import 'package:notaris_app/Pages/Notaris_Page.dart';
import 'package:notaris_app/Pages/signup_page.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'package:notaris_app/Pages/rekap_laporan_page.dart';
import 'package:notaris_app/Routes/routes.dart';
import 'package:notaris_app/Controller/Splash_screen_controller.dart';

// KUNCI PERBAIKAN 1: Import Model & Widget Laporan agar tidak "Undefined class"
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart'; 

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splashpage,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(name: AppRoutes.loginpage, page: () => LoginPage()),
    GetPage(name: AppRoutes.signuppage, page: () => SignupPage()),
    GetPage(name: AppRoutes.homepage, page: () => HomePage()),
    GetPage(
      name: AppRoutes.tambahberkasnotaris,
      page: () => TambahBerkasNotarisPage(),
    ),
    GetPage(name: AppRoutes.notaris, page: () => NotarisPage()),
    GetPage(name: AppRoutes.profilepage, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.calculator, page: () => CalculatorPage()),
    GetPage(
      name: AppRoutes.dynamicForm,
      page: () => DynamicFormPage(jenis: Get.parameters['jenis'] ?? 'default'),
    ),
    GetPage(name: AppRoutes.ppat, page: () => PpatPage()),
    GetPage(name: AppRoutes.tambahPekerjaan, page: () => TambahPekerjaanPage()),
  ];
}





















0











0