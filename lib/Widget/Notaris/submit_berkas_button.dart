import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/Form_Notaris_controller.dart';

class SubmitBerkasButton extends StatelessWidget {
  final NotarisFormController controller;

  const SubmitBerkasButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.submitForm(),
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
    );
  }
}