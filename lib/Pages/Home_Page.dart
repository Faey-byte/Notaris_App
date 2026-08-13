import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/home_controller.dart';
import 'package:notaris_app/Controller/rekap_laporan_controller.dart';
import 'package:notaris_app/Pages/calculator_page.dart';
import 'package:notaris_app/Pages/notaris_page.dart';
import 'package:notaris_app/Pages/ppat_page.dart';
import 'package:notaris_app/Widget/app_bottom_navbar.dart';
import 'package:notaris_app/Widget/Home/home_income_card.dart';
import 'package:notaris_app/Widget/Home/home_managemen_service.dart';
import 'package:notaris_app/Widget/Home/home_quick_overview.dart';
import 'package:notaris_app/Widget/Home/home_top_nav.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
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
        },
      ),
      body: Column(
        children: [
          const HomeTopNav(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  HomeIncomeCard(),
                  SizedBox(height: 20),
                  HomeQuickOverview(),
                  SizedBox(height: 20),
                  HomeManagementServices(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
