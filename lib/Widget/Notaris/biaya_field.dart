import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/form_notaris_controller.dart';

class BiayaField extends StatelessWidget {
  final NotarisFormController controller;

  const BiayaField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
            child: const Text(
              'Rp.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const VerticalDivider(color: Color(0xFFE2E8F0), width: 1),
          Expanded(
            child: TextField(
              controller: controller.biayaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
