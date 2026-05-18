import 'package:get/get.dart';
import 'package:notaris_app/Model/jenis_pekerjaan_model.dart';
import 'package:notaris_app/Pages/dynamic_form_page.dart';

class TambahPekerjaanController extends GetxController {
  final List<JenisPekerjaanModel> allJenis = [
    JenisPekerjaanModel(
      title: "Jual Beli",
      kode: "AJB",
      desc: "Pemindahan hak atas tanah",
    ),
    JenisPekerjaanModel(
      title: "Akta Pembagian Hak Bersama",
      kode: "APHB",
      desc: "APHB untuk pemisahan aset",
    ),
    JenisPekerjaanModel(
      title: "SKMHT",
      kode: "SKMHT",
      desc: "Surat Kuasa Membebankan HT",
    ),
    JenisPekerjaanModel(
      title: "APHT",
      kode: "APHT",
      desc: "Akta Pemberian Hak Tanggungan",
    ),
    JenisPekerjaanModel(
      title: "Hibah",
      kode: "HIBAH",
      desc: "Pemberian sukarela tanpa imbalan",
    ),
    JenisPekerjaanModel(
      title: "Tukar Menukar",
      kode: "Tukar Menukar",
      desc: "Pertukaran objek antar pihak",
    ),
    JenisPekerjaanModel(
      title: "Turun Waris",
      kode: "Turun Waris",
      desc: "Pencatatan peralihan hak waris",
    ),
    JenisPekerjaanModel(
      title: "Akta Pembagian Hak Waris",
      kode: "APHW",
      desc: "Penetapan porsi bagian waris",
    ),
    JenisPekerjaanModel(
      title: "Validasi Buku Tanah",
      kode: "VALIDASI",
      desc: "Pengecekan keabsahan data BPN",
    ),
    JenisPekerjaanModel(
      title: "Roya",
      kode: "ROYA",
      desc: "Penghapusan Hak Tanggungan",
    ),
    JenisPekerjaanModel(
      title: "Ralat Data",
      kode: "Ralat Data",
      desc: "Perbaikan administrasi sertifikat",
    ),
    JenisPekerjaanModel(
      title: "Ganti Nama Kreditur",
      kode: "Ganti Nama Kreditur",
      desc: "Pengalihan piutang",
    ),
    JenisPekerjaanModel(
      title: "Ganti Blanko",
      kode: "Ganti Blanko",
      desc: "Penggantian formulir sertifikat",
    ),
    JenisPekerjaanModel(
      title: "Lelang",
      kode: "LELANG",
      desc: "Peralihan hak melalui lelang",
    ),
    JenisPekerjaanModel(
      title: "Wakaf",
      kode: "WAKAF",
      desc: "Peralihan hak untuk kepentingan sosial",
    ),
  ];

  var searchText = ''.obs;
  var filteredList = <JenisPekerjaanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredList.assignAll(allJenis);
  }

  void onSearchChanged(String value) {
    searchText.value = value;

    if (value.isEmpty) {
      filteredList.assignAll(allJenis);
    } else {
      filteredList.assignAll(
        allJenis.where((item) {
          return item.title.toLowerCase().contains(value.toLowerCase());
        }).toList(),
      );
    }
  }

  void goToForm(JenisPekerjaanModel item) {
    Get.to(() => DynamicFormPage(jenis: item.kode));
  }
}
