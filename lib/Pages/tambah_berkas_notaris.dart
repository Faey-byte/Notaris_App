import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Form_Notaris_controller.dart';
import 'package:notaris_app/Widget/Notaris/akta_date_field.dart';
import 'package:notaris_app/Widget/Notaris/biaya_field.dart';
import 'package:notaris_app/Widget/Notaris/dokumen_section.dart';
import 'package:notaris_app/Widget/Notaris/jenis_pekerjaan_input.dart';
import 'package:notaris_app/Widget/Notaris/penghadap_section.dart';
import 'package:notaris_app/Widget/Notaris/submit_berkas_button.dart';
import 'package:notaris_app/Widget/Notaris/tambah_berkas_top_bar.dart';
import 'package:notaris_app/Widget/common/app_text_field.dart';
import 'package:notaris_app/Widget/common/form_label.dart';
import 'package:notaris_app/utils/app_colors.dart';

class TambahBerkasNotarisPage extends StatelessWidget {
  const TambahBerkasNotarisPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<NotarisFormController>()) {
      Get.delete<NotarisFormController>(force: true);
    }
    final NotarisFormController c = Get.put(NotarisFormController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TambahBerkasTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormLabel('Jenis Pekerjaan'),
                          const SizedBox(height: 8),
                          JenisPekerjaanInput(controller: c),
                          const SizedBox(height: 20),

                          const FormLabel('Nama Klien / Nama Perusahaan'),
                          const SizedBox(height: 8),
                          AppTextField(controller: c.namaKlienCtrl, hint: 'Masukkan nama lengkap'),
                          const SizedBox(height: 20),

                          const FormLabel('Nomor Akta'),
                          const SizedBox(height: 8),
                          AppTextField(controller: c.nomorAktaCtrl, hint: 'Masukkan nomor akta'),
                          const SizedBox(height: 20),

                          const FormLabel('Tanggal Akta'),
                          const SizedBox(height: 8),
                          AktaDateField(controller: c),
                          const SizedBox(height: 20),

                          const FormLabel('Sifat / Jenis Akta'),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: c.aktaNatureCtrl,
                            hint: 'Contoh: Akta Kuasa Menjual, Akta Pendirian, dll',
                          ),
                          const SizedBox(height: 20),

                          const FormLabel('Total Biaya Layanan'),
                          const SizedBox(height: 8),
                          BiayaField(controller: c),
                          const SizedBox(height: 20),

                          const FormLabel('Nama Staff'),
                          const SizedBox(height: 8),
                          AppTextField(controller: c.namaStaffCtrl, hint: 'Masukkan nama staff'),
                          const SizedBox(height: 24),

                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),

                          PenghadapSection(controller: c),

                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),

                          DokumenSection(controller: c),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubmitBerkasButton(controller: c),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}