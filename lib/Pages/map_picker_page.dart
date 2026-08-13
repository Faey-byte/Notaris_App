import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notaris_app/Widget/map_locate_me_button.dart';
import 'package:notaris_app/Widget/map_search_field.dart';
import 'package:notaris_app/data/services/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  static const LatLng _fallbackLocation = LatLng(-6.175392, 106.827153);
  static const LocationService _locationService = LocationService();

  late LatLng _selectedLocation;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _isSearching = false;

  bool get _hasSavedLocation =>
      widget.initialLat != null && widget.initialLng != null;

  @override
  void initState() {
    super.initState();

    if (_hasSavedLocation) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _selectedLocation = _fallbackLocation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLocateMe();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _moveCameraTo(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 17.0));
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  Future<void> _handleLocateMe() async {
    setState(() => _isLoadingLocation = true);
    try {
      final result = await _locationService.getCurrentDeviceLocation();
      setState(() => _selectedLocation = result.coordinate);
      _moveCameraTo(result.coordinate);
    } on LocationServiceException catch (e) {
      _showError("Gagal Ambil Lokasi Device", e.message);
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _handleSearch(String query) async {
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);
    try {
      final result = await _locationService.searchAddress(query);
      setState(() => _selectedLocation = result.coordinate);
      _moveCameraTo(result.coordinate);
    } on LocationServiceException catch (e) {
      _showError("Pencarian Gagal", e.message);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _handleMapTap(LatLng location) {
    setState(() => _selectedLocation = location);
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi Objek"),
        backgroundColor: const Color(0xFF801E1D),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 16.0,
            ),
            zoomControlsEnabled: false, // hindari numpuk sama custom button
            onMapCreated: (controller) => _mapController = controller,
            onTap: _handleMapTap,
            markers: {
              Marker(
                markerId: const MarkerId("selected_target"),
                position: _selectedLocation,
                infoWindow: const InfoWindow(title: "Lokasi Terpilih"),
              ),
            },
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: MapSearchField(
              controller: _searchController,
              isSearching: _isSearching,
              onSearch: _handleSearch,
            ),
          ),

          Positioned(
            bottom: 90,
            right: 16,
            child: MapLocateMeButton(
              isLoading: _isLoadingLocation,
              onPressed: _handleLocateMe,
            ),
          ),

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
              onPressed: () => Get.back(result: _selectedLocation),
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
