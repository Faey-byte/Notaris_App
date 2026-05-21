import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  // Constructor menerima data koordinat default langsung dari controller tanpa passing arguments rute
  const MapPickerPage({
    Key? key,
    required this.initialLat,
    required this.initialLng,
  }) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _selectedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Jika koordinat dari luar bernilai 0.0, fallback otomatis ke Jakarta Pusat agar tidak null/error
    double lat = widget.initialLat == 0.0 ? -6.175392 : widget.initialLat;
    double lng = widget.initialLng == 0.0 ? 106.827153 : widget.initialLng;
    
    _selectedLocation = LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi Objek"),
        backgroundColor: const Color(0xFF801E1D), // Menyesuaikan tema merah aplikasi notaris
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Widget Google Maps Utama
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 16.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
              // Efek kamera bergeser smooth ke titik baru yang diklik manual
              _mapController?.animateCamera(CameraUpdate.newLatLng(location));
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected_target"),
                position: _selectedLocation,
                infoWindow: const InfoWindow(title: "Lokasi Terpilih"),
              ),
            },
          ),

          // Tombol floating konfirmasi simpan koordinat di bagian bawah layar peta
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF801E1D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Mengembalikan data bertipe LatLng dengan aman ke controller asal tanpa memicu crash null
                Get.back(result: _selectedLocation);
              },
              child: const Text(
                "KONFIRMASI TITIK LOKASI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}