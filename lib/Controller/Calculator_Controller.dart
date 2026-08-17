import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalculatorController extends GetxController {
  var selectedType = 'BPHTB'.obs;

  final nilaiController = TextEditingController();
  final npoptkpController = TextEditingController();
  final besaranController = TextEditingController();

  var hasilFinal = "".obs;
  var isCalculated = false.obs;

  final formatter = NumberFormat("#,###", "id_ID");

  @override
  void onInit() {
    super.onInit();

    ever(selectedType, (_) => hitungOtomatis());
  }

  void changeType(String type) {
    selectedType.value = type;
  }

  bool get isBPHTB => selectedType.value == 'BPHTB';

  bool isSelected(String type) => selectedType.value == type;

  double parseCurrency(String value) {
    return double.tryParse(
          value.replaceAll('.', '').replaceAll('Rp', '').trim(),
        ) ??
        0;
  }

  void hitungOtomatis() {
    double nilai = parseCurrency(nilaiController.text);
    double npoptkp = parseCurrency(npoptkpController.text);

    double hasil = isBPHTB
        ? ((nilai - npoptkp) > 0 ? (nilai - npoptkp) * 0.05 : 0)
        : nilai * 0.025;

    besaranController.text = formatRupiah(hasil);
    hasilFinal.value = formatRupiah(hasil);
  }

  void hitungFinal() {
  if (nilaiController.text.isEmpty) {
    Get.snackbar(
      "Belum Lengkap",
      "Mohon masukkan nilai terlebih dahulu.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  if (isBPHTB && npoptkpController.text.isEmpty) {
    Get.snackbar(
      "Belum Lengkap",
      "Nilai NPOPTKP wajib diisi untuk perhitungan BPHTB.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  hitungOtomatis();
  isCalculated.value = true;
}

  String formatRupiah(double value) {
    return "Rp ${formatter.format(value)}";
  }
}
