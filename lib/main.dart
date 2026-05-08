
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Routes/routes.dart';
import 'Routes/pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notaris & PPAT',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loginpage,  // mulai dari login
      getPages: AppPages.pages,
    );
  }
}