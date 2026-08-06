class JenisPekerjaanModel {
  final String title;
  final String kode;
  final String desc;

  JenisPekerjaanModel({
    required this.title,
    required this.kode,
    required this.desc,
  });
}

const List<String> kJenisPekerjaanOptions = [
  "Akta Pendirian PT",
  "Akta Pendirian CV",
  "Akta Yayasan",
  "Akta Kuasa",
  "Legalisasi Dokumen",
];