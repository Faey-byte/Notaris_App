import 'package:get/get.dart';
import 'package:notaris_app/Controller/profile_controller.dart';
import 'package:notaris_app/Controller/rekap_laporan_controller.dart';
import 'package:notaris_app/Pages/otp_pages.dart';
import 'package:notaris_app/Pages/splash_screen.dart';
import 'package:notaris_app/Pages/Tambah_Berkas_Notaris.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/Pages/calculator_page.dart';
import 'package:notaris_app/Pages/dynamic_form_page.dart';
import 'package:notaris_app/Pages/Ppat_Page.dart';
import 'package:notaris_app/Pages/tambah_pekerjaan_page.dart';
import 'package:notaris_app/Pages/profile_page.dart';
import 'package:notaris_app/Pages/notaris_page.dart';
import 'package:notaris_app/Pages/reset_password_page.dart';
import 'package:notaris_app/Pages/signup_page.dart';
import 'package:notaris_app/Pages/home_page.dart';
import 'package:notaris_app/Routes/routes.dart';
import 'package:notaris_app/Controller/splash_screen_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splashpage,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.rekap,
      page: () => const RekapLaporanController(),
      binding: BindingsBuilder(() {
        Get.put(RekapLaporanController());
      }),
    ),
    GetPage(
      name: AppRoutes.resetPasswordPage,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(name: AppRoutes.loginpage, page: () => LoginPage()),
    GetPage(name: AppRoutes.signuppage, page: () => SignupPage()),
    GetPage(name: AppRoutes.otppage, page: () => const OtpPages()),
    GetPage(name: AppRoutes.homepage, page: () => HomePage()),
    GetPage(
      name: AppRoutes.tambahberkasnotaris,
      page: () => TambahBerkasNotarisPage(),
    ),
    GetPage(name: AppRoutes.notaris, page: () => NotarisPage()),
    GetPage(
      name: '/ProfilePage',
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(name: AppRoutes.calculator, page: () => CalculatorPage()),
    GetPage(
      name: AppRoutes.dynamicForm,
      page: () => DynamicFormPage(jenis: Get.parameters['jenis'] ?? 'default'),
    ),
    GetPage(name: AppRoutes.ppat, page: () => PpatPage()),
    GetPage(name: AppRoutes.tambahPekerjaan, page: () => TambahPekerjaanPage()),
  ];
}
