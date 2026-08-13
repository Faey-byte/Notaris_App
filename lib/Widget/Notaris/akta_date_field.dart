import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/form_notaris_controller.dart';

class AktaDateField extends StatelessWidget {
  final NotarisFormController controller;

  const AktaDateField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = controller.aktaDateValue.value;
      final label = date == null
          ? 'Pilih tanggal akta'
          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

      return GestureDetector(
        onTap: () => controller.pickAktaDate(),
        child: Container(
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
              Text(
                label,
                style: TextStyle(
                  color: date == null
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  fontSize: 15,
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      );
    });
  }
}
