import 'package:get/get.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Pages/Tambah_Pekerjaan_Page.dart';
import 'package:notaris_app/utils/app_colors.dart';

class StatusModel {
  final String label;
  final color;
  final bgColor;

  StatusModel({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  get textColor => color;
}

class PpatController extends GetxController {
  var search = "".obs;
  var selectedJenis = "Semua Berkas".obs;

  var berkasList = <BerkasModel>[].obs;
  var filteredList = <BerkasModel>[].obs;

  final jenisList = [
    "Semua Berkas",
    "AJB",
    "APHB",
    "SKMHT",
    "APHT",
    "Hibah",
    "Tukar Menukar",
    "Turun Waris",
    "APHW",
    "Validasi",
    "ROYA",
    "Ralat",
    "Ganti Nama",
    "Ganti Blanko",
    "Lelang",
    "Wakaf",
  ];

  final statusList = [
    StatusModel(
      label: "PROSES",
      color: AppColors.statusProses,
      bgColor: AppColors.statusProsesBg,
    ),
    StatusModel(
      label: "SELESAI",
      color: AppColors.statusSelesai,
      bgColor: AppColors.statusSelesaiBg,
    ),
    StatusModel(
      label: "REVISI",
      color: AppColors.statusRevisi,
      bgColor: AppColors.statusRevisiBg,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    berkasList.value = [
      BerkasModel(
        nama: "Budi Santoso",
        no: "2024/AJB/001",
        jenis: "AJB",
        tanggal: "12 Jan 2024",
        status: "PROSES",
      ),
      BerkasModel(
        nama: "Siti Aminah",
        no: "2024/HIB/002",
        jenis: "Hibah",
        tanggal: "10 Jan 2024",
        status: "SELESAI",
      ),
      BerkasModel(
        nama: "Andi Wijaya",
        no: "2024/APHT/003",
        jenis: "APHT",
        tanggal: "08 Jan 2024",
        status: "REVISI",
      ),
    ];

    applyFilter();
  }

  void setSearch(String value) {
    search.value = value;
    applyFilter();
  }

  void setJenis(String jenis) {
    selectedJenis.value = jenis;
    applyFilter();
  }

  void applyFilter() {
    filteredList.value = berkasList.where((item) {
      final matchSearch = item.nama.toLowerCase().contains(
        search.value.toLowerCase(),
      );

      final matchJenis = selectedJenis.value == "Semua Berkas"
          ? true
          : item.jenis == selectedJenis.value;

      return matchSearch && matchJenis;
    }).toList();
  }

  void goToTambah() {
    Get.to(() => TambahPekerjaanPage());
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 2:
        break;
      case 3:
        Get.offAll(() => CalculatorPage());
        break;
    }
  }
}
