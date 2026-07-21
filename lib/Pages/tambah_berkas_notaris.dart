import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/Form_Notaris_controller.dart';  
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF334155), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Berkas Notaris',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                    ),
                  ),
                ],
              ),
            ),

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
                          _buildLabel('Jenis Pekerjaan'),
                          const SizedBox(height: 8),
                          _buildJenisPekerjaanDropdown(c),
                          const SizedBox(height: 20),

                          _buildLabel('Nama Klien / Nama Perusahaan'),
                          const SizedBox(height: 8),
                          _buildTextField(c.namaKlienCtrl, 'Masukkan nama lengkap'),
                          const SizedBox(height: 20),

                          _buildLabel('Nomor Akta'),
                          const SizedBox(height: 8),
                          _buildTextField(c.nomorAktaCtrl, 'Masukkan nomor akta'),
                          const SizedBox(height: 20),

                          _buildLabel('Total Biaya Layanan'),
                          const SizedBox(height: 8),
                          _buildBiayaField(c),
                          const SizedBox(height: 20),

                          _buildLabel('Nama Staff'),
                          const SizedBox(height: 8),
                          _buildTextField(c.namaStaffCtrl, 'Masukkan nama staff'),
                          const SizedBox(height: 24),

                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),

                          const Text(
                            'DOKUMEN PERSYARATAN',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Obx(
                            () => Column(
                              children: [
                                for (final field in c.docFields)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildDokumenItem(c, field),
                                  ),
                              ],
                            ),
                          ),
                          _buildTambahDokumenBtn(context, c),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => c.submitForm(),
                        icon: const Icon(Icons.save_outlined, color: Colors.white),
                        label: const Text(
                          'Simpan Berkas',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF913632),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 4,
                        ),
                      ),
                    ),

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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildJenisPekerjaanDropdown(NotarisFormController c) {
    return Obx(
      () => Container(
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
            value: c.jenisPekerjaanOptions.contains(c.jenisPekerjaan.value)
                ? c.jenisPekerjaan.value
                : null,
            hint: const Text('Pilih Jenis Pekerjaan', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
            items: c.jenisPekerjaanOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              c.jenisPekerjaan.value = value ?? '';
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBiayaField(NotarisFormController c) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: const Text('Rp.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const VerticalDivider(color: Color(0xFFE2E8F0), width: 1),
          Expanded(
            child: TextField(
              controller: c.biayaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenItem(NotarisFormController c, NotarisDocField field) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
              ),
              child: field.isLoading.value
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : field.localFilePath.value.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(field.localFilePath.value),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          field.fileValue.value.isNotEmpty
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          color: field.fileValue.value.isNotEmpty
                              ? Colors.green
                              : const Color(0xFF94A3B8),
                          size: 28,
                        ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.label,
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadBtn(
                          Icons.photo_camera_outlined,
                          'Ambil',
                          () => c.pickAndUploadFile(field, ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildUploadBtn(
                          Icons.image_outlined,
                          'Galeri',
                          () => c.pickAndUploadFile(field, ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF334155)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _buildTambahDokumenBtn(BuildContext context, NotarisFormController c) {
    return GestureDetector(
      onTap: () => _showTambahDokumenDialog(context, c),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF94A3B8), size: 20),
            SizedBox(width: 8),
            Text('Kelengkapan Tambahan',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showTambahDokumenDialog(BuildContext context, NotarisFormController c) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Dokumen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama dokumen, misal: Akta Pendirian'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              c.addExtraDocField(controller.text);
              Get.back();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}