import 'package:flutter/material.dart';
import 'package:notaris_app/Controller/dynamic_form_controller.dart';

import 'text_field_widget.dart';
import 'upload_field_widget.dart';
import 'coordinate_field_widget.dart';

class FieldBuilder extends StatelessWidget {
  final DynamicField field;
  final DynamicFormController controller;

  const FieldBuilder({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case "text":
      case "number":
        return TextFieldWidget(field, controller);

      case "upload":
        return UploadFieldWidget(field);

      case "coordinate":
        return CoordinateFieldWidget(field);

      default:
        return const SizedBox();
    }
  }
}