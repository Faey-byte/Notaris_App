import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/Widget/Berkas/Page_Header_Widget.dart';
import 'package:notaris_app/Widget/dynamic_form/upload_field_widget.dart';

class TambahBerkasNotarisPage extends StatelessWidget {
  const TambahBerkasNotarisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER + BACK ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(), // ✅ back ke notaris page
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

            // ─── CONTENT ───
            Expanded(
              child: SingleChildScrollView(  // ✅ bisa scroll
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── FORM CARD ───
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
                          // ─── JENIS PEKERJAAN ───
                          _buildLabel('Jenis Pekerjaan'),
                          const SizedBox(height: 8),
                          _buildDropdown('Pilih Jenis Pekerjaan'),
                          const SizedBox(height: 20),

                          // ─── NAMA KLIEN ───
                          _buildLabel('Nama Klien / Nama Perusahaan'),
                          const SizedBox(height: 8),
                          _buildTextField('Masukkan nama lengkap'),
                          const SizedBox(height: 20),

                          // ─── NOMOR AKTA ───
                          _buildLabel('Nomor Akta'),
                          const SizedBox(height: 8),
                          _buildTextField('Masukkan nomor akta'),
                          const SizedBox(height: 20),

                          // ─── TOTAL BIAYA ───
                          _buildLabel('Total Biaya Layanan'),
                          const SizedBox(height: 8),
                          _buildBiayaField(),
                          const SizedBox(height: 20),

                          // ─── NAMA STAFF ───
                          _buildLabel('Nama Staff'),
                          const SizedBox(height: 8),
                          _buildTextField('Masukkan nama staff'),
                          const SizedBox(height: 24),

                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),

                          // ─── DOKUMEN ───
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

                          // ✅ pake UploadFieldWidget yang udah ada
                          _buildDokumenItem('KTP (Pemilik/Direktur)'),
                          const SizedBox(height: 12),
                          _buildDokumenItem('Kartu Keluarga'),
                          const SizedBox(height: 12),
                          _buildDokumenItem('NPWP'),
                          const SizedBox(height: 12),
                          _buildDokumenItem('Kelengkapan Tambahan', isAdd: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── TOMBOL SIMPAN ───
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {}, // TODO: logika simpan
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

  // ─── HELPERS ───

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildBiayaField() {
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
          const Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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

  Widget _buildDokumenItem(String label, {bool isAdd = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // preview box
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
            ),
            child: Icon(
              isAdd ? Icons.add_circle_outline : Icons.camera_alt_outlined,
              color: const Color(0xFF94A3B8),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // ✅ tombol ambil & galeri
                Row(
                  children: [
                    Expanded(child: _buildUploadBtn(Icons.photo_camera_outlined, 'Ambil')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildUploadBtn(Icons.image_outlined, 'Galeri')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {}, // TODO: image picker
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
}