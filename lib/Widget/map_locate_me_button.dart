import 'package:flutter/material.dart';

/// Tombol bulat kecil buat re-fetch lokasi device saat ini.
class MapLocateMeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const MapLocateMeButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "btn_current_location",
      mini: true,
      backgroundColor: Colors.white,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location, color: Color(0xFF801E1D)),
    );
  }
}