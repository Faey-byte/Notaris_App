import 'package:get/get.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';

class DokumenModel {
  final String nama;
  final String tanggal;
  final bool isImage;

  DokumenModel({
    required this.nama,
    required this.tanggal,
    this.isImage = false,
  });
}

class DetailBerkasController extends GetxController {
  final BerkasModel data;

  DetailBerkasController(this.data);

  var alamat = "".obs;
  var totalBiaya = "".obs;
  var namaStaff = "".obs;
  var statusPajak = "".obs;

  var dokumenList = <DokumenModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummy();
  }

  void loadDummy() {
    alamat.value =
        "Jl. Melati No. 45, Kebayoran Baru, Jakarta Selatan";

    totalBiaya.value = "Rp 4.500.000";
    namaStaff.value = "Andini Putri";
    statusPajak.value = "Lunas";

    dokumenList.value = [
      DokumenModel(
        nama: "Sertifikat_Asli_Scan.jpg",
        tanggal: "13 Nov 2023",
        isImage: true,
      ),
      DokumenModel(
        nama: "KTP Pemilik.pdf",
        tanggal: "12 Nov 2023",
      ),
      DokumenModel(
        nama: "Akta kematian.pdf",
        tanggal: "13 Nov 2023",
      ),
      DokumenModel(
        nama: "PBB Tahun Berjalan.pdf",
        tanggal: "13 Nov 2023",
      ),
      DokumenModel(
        nama: "Foto Object.pdf",
        tanggal: "13 Nov 2023",
      ),
    ];
  }
}