import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/Form_Notaris_controller.dart';
import 'package:get/get.dart';

/// Widget input "Jenis Pekerjaan" — dropdown preset + input manual,
/// hasilnya ditampung sebagai list chip. Sesuai notary_type yang
/// sekarang array di backend (lihat UploadNotaryAsset).
///
/// Dipisah dari tambah_berkas_notaris.dart biar reusable & file
/// halaman nggak kepanjangan.
class JenisPekerjaanInput extends StatelessWidget {
  final NotarisFormController controller;

  const JenisPekerjaanInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown preset — pilih salah satu langsung nambah ke list
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: null,
              hint: const Text(
                'Pilih dari daftar jenis pekerjaan',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
              items: c.jenisPekerjaanOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) c.addJenisPekerjaan(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Input manual — buat jenis pekerjaan yang nggak ada di daftar
        Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: c.manualJenisCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Atau ketik manual, lalu tekan +',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                c.addJenisPekerjaan(c.manualJenisCtrl.text);
                c.manualJenisCtrl.clear();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF913632),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Chip daftar jenis pekerjaan yang sudah dipilih/ditambahkan
        Obx(
          () => c.jenisPekerjaanList.isEmpty
              ? Text(
                  'Belum ada jenis pekerjaan dipilih',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.jenisPekerjaanList
                      .map(
                        (item) => Chip(
                          label: Text(item, style: const TextStyle(fontSize: 13)),
                          backgroundColor: const Color(0xFFF1F5F9),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => c.removeJenisPekerjaan(item),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}