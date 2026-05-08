import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Ppat_Controller.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import 'package:notaris_app/Widget/Berkas_Card.dart';
import 'package:notaris_app/Widget/Jenis_Filter_Chip.dart';
import 'package:notaris_app/Widget/Page_Header_Widget.dart';
import 'package:notaris_app/Widget/Search_Bar_Widget.dart';
import 'package:notaris_app/Widget/Status_Chip.dart';

class PpatPage extends StatelessWidget {
  PpatPage({super.key});

  final controller = Get.put(PpatController());

  final List<String> _jenisList = const [
    "Semua Berkas",
    "AJB",
    "APHB",
    "SKMHT",
    "APHT",
    "Hibah",
    "Tukar Menukar",
    "Turun Waris",
    "APHW",
    "Validasi",
    "ROYA",
    "Ralat",
    "Ganti Nama",
    "Ganti Blanko",
    "Lelang",
    "Wakaf",
  ];

  final List<Map<String, dynamic>> _statusList = const [
    {"label": "PROSES", "text": Color(0xFFFF9800), "bg": Color(0xFFFFF3E0)},
    {"label": "SELESAI", "text": Color(0xFF4CAF50), "bg": Color(0xFFE8F5E9)},
    {"label": "REVISI", "text": Color(0xFFF44336), "bg": Color(0xFFFFEBEE)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PageHeaderWidget(
                title: "Berkas PPAT",
                icon: Icons.insert_drive_file_outlined,
                buttonLabel: "Tambah",
                onButtonPressed: () {
                  Get.to(() => TambahPekerjaanPage());
                },
              ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(
                      hintText: "Cari nama klien...",
                      onChanged: controller.setSearch,
                    ),

                    const SizedBox(height: 8),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(
                        () => Row(
                          children: _jenisList.map((jenis) {
                            return JenisFilterChip(
                              label: jenis,
                              isSelected:
                                  controller.selectedJenis.value == jenis,
                              onTap: () => controller.setJenis(jenis),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 16,
                                  color: Color(0xFF666666),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "STATUS",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ..._statusList.map(
                            (s) => StatusChip(
                              label: s["label"],
                              textColor: s["text"],
                              bgColor: s["bg"],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "DAFTAR BERKAS TERKINI",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF8B1A1A),
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${controller.filteredList.length} Berkas ditemukan",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Obx(() {
                if (controller.filteredList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 48,
                          color: Color(0xFFCCCCCC),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Tidak ada data",
                          style: TextStyle(color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: controller.filteredList.length,
                  itemBuilder: (context, index) {
                    final data = controller.filteredList[index];
                    return BerkasCard(data: data);
                  },
                );
              }),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 2:
              break;
            case 3:
              Get.offAll(() => CalculatorPage());
              break;
          }
        },
      ),
    );
  }
}
