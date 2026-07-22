import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Home_Controller.dart';
import 'package:notaris_app/Pages/Notifikasi_Page.dart';
import 'package:notaris_app/Pages/Profile_Page.dart'; // <--- Pastikan import ProfilePage sudah benar

class HomeTopNav extends StatelessWidget {
  const HomeTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      color: Colors.white.withOpacity(0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Bungkus Logo dan Teks Nama Sistem dengan InkWell agar bisa diklik menuju ProfilePage
              InkWell(
                onTap: () => Get.to(() => ProfilePage()), // <--- Navigasi ke Halaman Profil
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(4.0), // Padding kecil agar area klik lebih nyaman
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF913632),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.gavel, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notaris & PPAT',
                            style: TextStyle(
                              color: Color(0xFF913632),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Manajemen Sistem',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Widget Lonceng Notifikasi (Tetap menuju NotifikasiPage)
              InkWell(
                onTap: () => Get.to(() => NotifikasiPage()),
                borderRadius: BorderRadius.circular(14),
                child: Obx(
                  () => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF913632),
                          size: 22,
                        ),
                      ),
                      if (controller.hasNotification.value)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}