import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicFormPage extends StatelessWidget {
  final String jenis;

  DynamicFormPage({super.key, required this.jenis});

  final Map<String, List<Map<String, dynamic>>> formConfig = {
    "AJB": [],
    "APHB": [],
    "SKMHT": [],
    "APHT":[],
    "HIBAH": [],
    "TUKAR MENUKAR": [],
    "TURUN WARIS": [],
    "APHW": [],
    "VALIDASI": [],
    "ROYA": [],
    "RALAT": [],
    "GANTI NAMA": [],
    "GANTI BLANKO": [],
    "LELANG": [],
    "WAKAF": [],
  };

  final Map<String, TextEditingController> controllers = {};

  @override
  Widget build(BuildContext context) {
    final fields = formConfig[jenis] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Form $jenis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...fields.map((field) {
              final label = field["label"];
              controllers[label] = TextEditingController();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[label],
                  keyboardType: field["type"] == "number"
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final result = controllers.map((key, value) {
                  return MapEntry(key, value.text);
                });

                print("DATA: $result");

                Get.snackbar("Sukses", "Data berhasil disimpan");
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}