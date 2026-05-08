import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Pages/Dynamic_Form_Page.dart';

class TambahPekerjaanPage extends StatelessWidget {
  TambahPekerjaanPage({super.key});

  final List<Map<String, String>> jenisList = [
    {"title": "Jual Beli", "kode": "AJB", "desc": "Pemindahan hak atas tanah"},
    {
      "title": "Akta Pembagian Hak Bersama",
      "kode": "APHB",
      "desc": "APHB untuk pemisahan aset",
    },
    {"title": "SKMHT", "kode": "SKMHT", "desc": "Surat Kuasa Membebankan HT"},
    {"title": "APHT", "kode": "APHT", "desc": "Akta Pemberian Hak Tanggungan"},
    {
      "title": "Hibah",
      "kode": "HIBAH",
      "desc": "Pemberian sukarela tanpa imbalan",
    },
    {
      "title": "Tukar Menukar",
      "kode": "TUKAR",
      "desc": "Pertukaran objek antar pihak",
    },
    {
      "title": "Turun Waris",
      "kode": "WARIS",
      "desc": "Pencatatan peralihan hak waris",
    },
    {
      "title": "Akta Pembagian Hak Waris",
      "kode": "APHW",
      "desc": "Penetapan porsi bagian waris",
    },
    {
      "title": "Validasi Buku Tanah",
      "kode": "VALIDASI",
      "desc": "Pengecekan keabsahan data BPN",
    },
    {"title": "Roya", "kode": "ROYA", "desc": "Penghapusan Hak Tanggungan"},
    {
      "title": "Ralat Data",
      "kode": "RALAT",
      "desc": "Perbaikan administrasi sertifikat",
    },
    {
      "title": "Ganti Nama Kreditur",
      "kode": "CESSIE",
      "desc": "Pengalihan piutang",
    },
    {
      "title": "Ganti Blanko",
      "kode": "BLANKO",
      "desc": "Penggantian formulir sertifikat",
    },
    {
      "title": "Lelang",
      "kode": "LELANG",
      "desc": "Peralihan hak melalui lelang",
    },
    {
      "title": "Wakaf",
      "kode": "WAKAF",
      "desc": "Peralihan hak untuk kepentingan sosial",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Pilih Jenis Pekerjaan PPAT",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Cari jenis pekerjaan...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: jenisList.length,
              itemBuilder: (context, index) {
                final item = jenisList[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(() => DynamicFormPage(jenis: item["kode"]!));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Colors.redAccent,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"]!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["desc"]!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
