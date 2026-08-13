import 'package:flutter/material.dart';

class MapLocateMeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const MapLocateMeButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

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
