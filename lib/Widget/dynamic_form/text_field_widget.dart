import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';
import 'package:notaris_app/utils/app_colors.dart';

class TextFieldWidget extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController c;

  const TextFieldWidget(this.field, this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c.controllers[field.label],
        keyboardType: field.type == "number"
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: field.placeholder,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}