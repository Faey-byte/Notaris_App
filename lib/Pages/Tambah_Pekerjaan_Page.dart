
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:notaris_app/Pages/Dynamic_Form_Page.dart';

class TambahPekerjaanPage extends StatelessWidget{
  TambahPekerjaanPage({super.key});

  final List<Map<String, String>> jenisList = [
    {"title": "Jual Beli", "kode": "AJB"},
    {"title": "Hibah", "kode": "HIBAH"},
    {"title": "APHT", "kode": "APHT"},
    {"title": "SKMHT", "kode": "SKMHT"},
    {"title": "Tukar Menukar", "kode": "TUKAR MENUKAR"},
    {"title": "Turun Waris", "kode": "TURUN WARIS"},
    {"title": "APHW", "kode": "APHW"},
    {"title": "Validasi", "kode": "VALIDASI"},
    {"title": "Roya", "kode": "ROYA"},
    {"title": "Ralat", "kode": "RALAT"},
    {"title": "Ganti Nama", "kode": "GANTI NAMA"},
    {"title": "Ganti Blanko", "kode": "GANTI BLANKO"},
    {"title": "Lelang", "kode": "LELANG"},
    {"title": "Wakaf", "kode": "WAKAF"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Jenis Pekerjaan")),
      body: ListView.builder(
        itemCount: jenisList.length,
        itemBuilder: (context, index) {
          final item = jenisList[index];

          return ListTile(
            title: Text(item["title"]!),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.to(() => DynamicFormPage(
                    jenis: item["kode"]!,
                  ));
            },
          );
        },
      ),
    );
  }
}