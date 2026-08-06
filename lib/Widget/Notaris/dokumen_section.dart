import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notaris_app/Controller/Form_Notaris_controller.dart';
import 'package:notaris_app/Widget/common/section_title.dart';

class DokumenSection extends StatelessWidget {
  final NotarisFormController controller;

  const DokumenSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'DOKUMEN PERSYARATAN'),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              for (final field in controller.docFields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DokumenItem(controller: controller, field: field),
                ),
            ],
          ),
        ),
        _TambahDokumenButton(controller: controller),
      ],
    );
  }
}

class _DokumenItem extends StatelessWidget {
  final NotarisFormController controller;
  final NotarisDocField field;

  const _DokumenItem({required this.controller, required this.field});

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    field.label,
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _UploadButton(
                          icon: Icons.photo_camera_outlined,
                          label: 'Ambil',
                          onTap: () => controller.pickAndUploadFile(field, ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _UploadButton(
                          icon: Icons.image_outlined,
                          label: 'Galeri',
                          onTap: () => controller.pickAndUploadFile(field, ImageSource.gallery),
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
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
}

class _TambahDokumenButton extends StatelessWidget {
  final NotarisFormController controller;

  const _TambahDokumenButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTambahDokumenDialog(context, controller),
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
            Text(
              'Kelengkapan Tambahan',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahDokumenDialog(BuildContext context, NotarisFormController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Dokumen'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Nama dokumen, misal: Akta Pendirian'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              controller.addExtraDocField(textController.text);
              Get.back();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}