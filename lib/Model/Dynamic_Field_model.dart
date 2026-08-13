import 'package:get/get.dart';

class DynamicField {
  final String label;
  final String type;
  final String? placeholder;

  var fileValue = ''.obs;
  var fileId = ''.obs;
  var matchKey = ''.obs;
  var localFilePath = ''.obs;
  var isLoading = false.obs;

  var latitude = (-6.175392).obs;
  var longitude = (106.827153).obs;

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

  void clear() {
    fileValue.value = '';
    fileId.value = '';
    matchKey.value = '';
    localFilePath.value = '';
    isLoading.value = false;
    dateValue.value = null;
  }

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
