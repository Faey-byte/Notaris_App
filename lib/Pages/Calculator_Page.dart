import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Calculator_Controller.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'package:notaris_app/Pages/Notaris_Page.dart';
import 'package:notaris_app/Pages/PPAT_page.dart';
import 'package:notaris_app/Pages/Profile_Page.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import 'package:notaris_app/utils/app_colors.dart';
import '../Widget/Text_Field_Widget.dart';
import '../Widget/App_Bottom_Navbar.dart';
import 'PPAT_page.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage({super.key});

  final c = Get.put(CalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Kalkulator BPHTB & SSP"),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Hitung estimasi pajak pembeli (BPHTB/SSP) secara instan.",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: ['BPHTB', 'SSP'].map((e) {
                    final selected = c.isSelected(e);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => c.changeType(e),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextfieldsWidget(
              label: "Nilai",
              controller: c.nilaiController,
              prefixText: "Rp ",
              keyboardType: TextInputType.number,
            ),

            Obx(
              () => c.isBPHTB
                  ? TextfieldsWidget(
                      label: "NPOPTKP",
                      controller: c.npoptkpController,
                      prefixText: "Rp ",
                      keyboardType: TextInputType.number,
                    )
                  : const SizedBox(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.hitungFinal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Hitung Estimasi",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => c.isCalculated.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              "Hasil Perhitungan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            color: AppColors.greySoft,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.selectedType.value),
                              Text(
                                c.hasilFinal.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "*Hasil ini merupakan estimasi awal.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(
  currentIndex: 3,
  onTap: (index) {
          switch (index) {
            case 0:
            Get.offAll(() => const HomePage());
              break;
            case 1:
              Get.offAll(() => const NotarisPage());
              break;
            case 2:
              Get.offAll(() => PpatPage());
              break;
            case 3:
              Get.offAll(() => CalculatorPage());
              break;
            case 4:
              Get.offAll(() => const ProfilePage());
              break;
          }
        },
),
    );
  }
}
