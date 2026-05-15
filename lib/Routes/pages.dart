import 'package:get/get.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Dynamic_Form_Page.dart';
import 'package:notaris_app/Pages/PPAT_page.dart';
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/Pages/Profile_Page.dart';
import 'package:notaris_app/Pages/Notaris_Page.dart'; // ← tambahan
import 'package:notaris_app/Pages/main_wrapper.dart';
import 'package:notaris_app/Pages/signup_page.dart';
import 'package:notaris_app/Routes/routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.loginpage,page: () => LoginPage()),
    GetPage(name: AppRoutes.signuppage,page: () => SignupPage(),
),
    GetPage(name: AppRoutes.homepage,        page: () => const MainWrapper()),
    GetPage(name: AppRoutes.notaris,         page: () => const NotarisPage()), // ← tambahan
    GetPage(name: AppRoutes.profilepage,     page: () => const ProfilePage()),
    GetPage(name: AppRoutes.calculator,      page: () =>  CalculatorPage()),
    GetPage(
      name: AppRoutes.dynamicForm,
      page: () => DynamicFormPage(
        jenis: Get.parameters['jenis'] ?? 'default',
      ),
    ),
    GetPage(name: AppRoutes.ppat,            page: () => PpatPage()),
    GetPage(name: AppRoutes.tambahPekerjaan, page: () => TambahPekerjaanPage()),
  ];
}