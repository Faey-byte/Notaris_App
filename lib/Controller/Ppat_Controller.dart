import 'package:get/get.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';

class PpatController extends GetxController {

  var search = "".obs;
  var selectedJenis = "Semua berkas".obs;

  var berkasList = <BerkasModel>[].obs;
  var filteredList = <BerkasModel>[].obs;

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
      final matchSearch = item.nama
          .toLowerCase()
          .contains(search.value.toLowerCase());

      final matchJenis = selectedJenis.value == "Semua berkas"
          ? true
          : item.jenis == selectedJenis.value;

      return matchSearch && matchJenis;
    }).toList();
  }
}