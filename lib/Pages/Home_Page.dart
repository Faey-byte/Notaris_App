import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Home_Controller.dart';
import 'package:notaris_app/Controller/rekap_laporan_controller.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Notaris_Page.dart';
import 'package:notaris_app/Pages/ppat_page.dart';
import 'package:notaris_app/Pages/Profile_Page.dart';
import 'package:notaris_app/Pages/rekap_laporan_page.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import 'package:notaris_app/Widget/Home/Home_Income_Card.dart';
import 'package:notaris_app/Widget/Home/Home_Managemen_service.dart';
import 'package:notaris_app/Widget/Home/Home_Quick_Overview.dart';
import 'package:notaris_app/Widget/Home/Home_Top_Nav.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart';

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
