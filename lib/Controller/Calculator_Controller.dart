import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalculatorController extends GetxController {
  var selectedType = 'BPHTB'.obs;

  final nilaiController = TextEditingController();
  final npoptkpController = TextEditingController();
  final besaranController = TextEditingController();

  // 🔥 TAMBAHAN
  var hasilFinal = "".obs;
  var isCalculated = false.obs;

  final formatter = NumberFormat("#,###", "id_ID");

  @override
  void onInit() {
    super.onInit();

    nilaiController.addListener(hitungOtomatis);
    npoptkpController.addListener(hitungOtomatis);

    ever(selectedType, (_) => hitungOtomatis());
  }

  double parseCurrency(String value) {
    return double.tryParse(
          value.replaceAll('.', '').replaceAll('Rp', '').trim(),
        ) ??
        0;
  }

  void hitungOtomatis() {
    double nilai = parseCurrency(nilaiController.text);
    double npoptkp = parseCurrency(npoptkpController.text);

    double hasil = 0;

    if (selectedType.value == 'BPHTB') {
      double dasar = nilai - npoptkp;
      hasil = dasar > 0 ? dasar * 0.05 : 0;
    } else {
      hasil = nilai * 0.025;
    }

    // isi field atas
    besaranController.text = formatRupiah(hasil);

    // simpan untuk hasil bawah
    hasilFinal.value = formatRupiah(hasil);
  }

  // 🔥 DIPANGGIL SAAT KLIK BUTTON
  void hitungFinal() {
    hitungOtomatis();
    isCalculated.value = true;
  }

  String formatRupiah(double value) {
    return "Rp ${formatter.format(value)}";
  }
}