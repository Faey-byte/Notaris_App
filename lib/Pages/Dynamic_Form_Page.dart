import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/dynamic_form_controller.dart';
import '../Widget/dynamic_form/field_builder.dart';
import '../utils/app_colors.dart';

class DynamicFormPage extends StatelessWidget {
  final String jenis;

  const DynamicFormPage({super.key, required this.jenis});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DynamicFormController(jenis),
      tag: jenis,
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          "Form $jenis",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.fields.isEmpty) {
          return const Center(child: Text("Form belum tersedia"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "Form $jenis",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "DOKUMEN PERSYARATAN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...controller.fields.map(
                    (f) => FieldBuilder(
                      field: f,
                      controller: controller,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "SIMPAN BERKAS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}