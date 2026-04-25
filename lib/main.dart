
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:notaris_app/Pages/PPAT_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp (
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: PpatPage(),
    );
  }
}
