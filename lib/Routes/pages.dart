import 'package:get/get.dart';
import 'package:notaris_app/Pages/login_page.dart';
import 'package:notaris_app/Routes/routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.loginpage, page: () => LoginPage()),
  ];
}