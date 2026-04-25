
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Calculator_Controller.dart';
import 'package:notaris_app/Pages/PPAT_page.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import '../Widget/Text_Field_Widget.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage({super.key});

  final c = Get.put(CalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Kalkulator BPHTB & SSP"),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF913632)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Hitung estimasi pajak pembeli (BPHTB/SSP) transaksi jual beli properti Anda secara instan.",
                      style: TextStyle(color: Color(0xFF913632)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Obx(() => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF913632),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: ['BPHTB', 'SSP'].map((e) {
                      bool selected = c.selectedType.value == e;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => c.selectedType.value = e,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  selected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    selected ? Color(0xFF913632) : const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),

            const SizedBox(height: 20),

            TextfieldsWidget(
              label: "Nilai",
              controller: c.nilaiController,
              prefixText: "Rp ",
              keyboardType: TextInputType.number,
            ),

            Obx(() => c.selectedType.value == 'BPHTB'
                ? TextfieldsWidget(
                    label: "NPOPTKP",
                    controller: c.npoptkpController,
                    prefixText: "Rp ",
                    keyboardType: TextInputType.number,
                  )
                : const SizedBox()),

            

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.hitungFinal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF913632),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Hitung Estimasi",
                 style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),


              ),
            ),

            const SizedBox(height: 20),

            Obx(() => c.isCalculated.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bar_chart,color: Color(0xFF913632),),
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
                          border:
                              Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                        "*Hasil ini merupakan estimasi awal. Biaya real dapat bervariasi tergantung kebijakan daerah dan kesepakatan notaris.",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                : const SizedBox()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
  currentIndex: 3,
  onTap: (index) {
    switch (index) {
      case 2:
        Get.offAll(() => PpatPage());
        break;
      case 3:
        break; // sudah di kalkulator
    }
  },
),
    );
  }
}