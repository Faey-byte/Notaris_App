import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/auth_controller.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'Routes/routes.dart';
import 'Routes/pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // wajib untuk async di awal

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
      initialRoute: AppRoutes.splashpage, // ← mulai dari splash
      getPages: AppPages.pages,
    );
  }
  
  Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
}