import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Model/form_field_model.dart';

class DynamicFormController extends GetxController {
  final String jenis;

  DynamicFormController(this.jenis);

  var fields = <FormFieldModel>[].obs;
  final Map<String, TextEditingController> controllers = {};

  @override
  void onInit() {
    super.onInit();
    loadForm();
  }

  final Map<String, List<FormFieldModel>> formConfig = {
    "AJB": [
      FormFieldModel(label: "Nama Penjual", type: "text"),
      FormFieldModel(label: "Nama Pembeli", type: "text"),
      FormFieldModel(label: "Harga Transaksi", type: "number"),
    ],
    "HIBAH": [
      FormFieldModel(label: "Pemberi Hibah", type: "text"),
      FormFieldModel(label: "Penerima Hibah", type: "text"),
    ],
  };

  void loadForm() {
    fields.value = formConfig[jenis] ?? [];

    fields.insertAll(0, [FormFieldModel(label: "Nama Klien", type: "text")]);

    fields.addAll([
      FormFieldModel(label: "Total Biaya", type: "number"),
      FormFieldModel(label: "Nama Staff", type: "text"),
    ]);

    for (var field in fields) {
      controllers[field.label] = TextEditingController();
    }
  }

  void submit() {
    final result = controllers.map((key, value) {
      return MapEntry(key, value.text);
    });

    print("DATA: $result");

    Get.snackbar("Sukses", "Data berhasil disimpan");
  }
}
