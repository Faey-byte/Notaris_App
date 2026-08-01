import 'package:get/get.dart';

class DynamicField {
  final String label;
  final String type; // Contoh: "upload", "coordinate", "text", "number", "date"
  final String? placeholder;

  // Rx Variables untuk Reactivity GetX (Obx)
  var fileValue = ''.obs;      // Menyimpan URL file yang diupload
  var fileId = ''.obs;         // Menyimpan ID / public_id file dari server
  var matchKey = ''.obs;       // Menyimpan matchkey enkripsi file
  var localFilePath = ''.obs;  // Menyimpan path file lokal (cache/preview)
  var isLoading = false.obs;   // Status loading saat upload per field

  // Untuk field tipe Koordinat (Lokasi)
  var latitude = (-6.175392).obs;
  var longitude = (106.827153).obs;

  // Untuk field tipe Tanggal (Date)
  var dateValue = Rxn<DateTime>();

  DynamicField({
    required this.label,
    required this.type,
    this.placeholder,
    String? initialFileValue,
    String? initialFileId,
    String? initialMatchKey,
  }) {
    if (initialFileValue != null) fileValue.value = initialFileValue;
    if (initialFileId != null) fileId.value = initialFileId;
    if (initialMatchKey != null) matchKey.value = initialMatchKey;
  }

  /// Reset/Membersihkan data pada field ini
  void clear() {
    fileValue.value = '';
    fileId.value = '';
    matchKey.value = '';
    localFilePath.value = '';
    isLoading.value = false;
    dateValue.value = null;
  }

  /// Konversi ke Map jika butuh dikirim sebagai JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type,
      'file_value': fileValue.value,
      'file_id': fileId.value,
      'match_key': matchKey.value,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'date_value': dateValue.value?.toIso8601String(),
    };
  }
}