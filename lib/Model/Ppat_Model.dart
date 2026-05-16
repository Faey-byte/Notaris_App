class BerkasModel {
  final String id;
  final String nama;
  final String jenis;
  String status;

  BerkasModel({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.status,
  });

  factory BerkasModel.fromJson(Map<String, dynamic> json) {
    var inputList = json['input_data'] as List? ?? [];
    String clientName = "Tanpa Nama";
    try {
      final found = inputList.firstWhere(
        (e) => e['label'].toString().toLowerCase().contains('client') || 
               e['label'].toString().toLowerCase().contains('perusahaan'),
        orElse: () => null
      );
      if (found != null) clientName = found['value'] ?? "Tanpa Nama";
    } catch (_) {}

    return BerkasModel(
      id: json['id']?.toString() ?? "",
      nama: clientName,
      jenis: json['jenis_pekerjaan'] ?? "AJB",
      status: json['status_pengerjaan'] ?? "PENDING",
    );
  }
}