import 'package:get/get_rx/src/rx_types/rx_types.dart';

class DynamicField {
  final String label;
  final String type;
  final String? placeholder;
  
  var fileValue = "".obs; 

  DynamicField({
    required this.label,
    required this.type,
    this.placeholder,
  });
}