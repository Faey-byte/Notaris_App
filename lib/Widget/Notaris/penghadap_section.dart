import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/form_notaris_controller.dart';
import 'package:notaris_app/Widget/common/section_title.dart';

class PenghadapSection extends StatelessWidget {
  final NotarisFormController controller;

  const PenghadapSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'PENGHADAP', trailingText: 'Min. 1 orang'),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              for (final penghadap in controller.penghadapList)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PenghadapItem(
                    controller: controller,
                    penghadap: penghadap,
                  ),
                ),
            ],
          ),
        ),
        _TambahPenghadapButton(controller: controller),
      ],
    );
  }
}

class _PenghadapItem extends StatelessWidget {
  final NotarisFormController controller;
  final NotarisPenghadap penghadap;

  const _PenghadapItem({required this.controller, required this.penghadap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penghadap ${penghadap.orderNumber}',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => controller.removePenghadap(penghadap),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: penghadap.nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Nama lengkap penghadap',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: penghadap.titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Gelar, misal: Tuan / Nyonya / Sarjana Hukum',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TambahPenghadapButton extends StatelessWidget {
  final NotarisFormController controller;

  const _TambahPenghadapButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.addPenghadap(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Tambah Penghadap',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
