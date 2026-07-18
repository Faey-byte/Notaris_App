import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/auth_controller.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'Routes/routes.dart';
import 'Routes/pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notaris_app/data/db_helper.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Info: Gagal memuat file .env: $e");
  }

  print("reload info data notaris");
  await DbHelper().cekSeluruhDataNotaris();


  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notaris & PPAT',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashpage,
      getPages: AppPages.pages,
    );
  }
}