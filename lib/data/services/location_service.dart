import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final LatLng coordinate;
  const LocationResult(this.coordinate);
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  const LocationService();

  Future<LocationResult> getCurrentDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        "GPS tidak aktif. Aktifkan GPS terlebih dahulu.",
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException("Izin lokasi ditolak.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        "Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.",
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationResult(LatLng(position.latitude, position.longitude));
    } catch (e) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LocationResult(LatLng(last.latitude, last.longitude));
      }
      throw const LocationServiceException(
        "Gagal mendapatkan lokasi device. Pastikan GPS aktif dan coba lagi.",
      );
    }
  }

  Future<LocationResult> searchAddress(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw const LocationServiceException("Alamat tidak boleh kosong.");
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': trimmed,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'id',
    });

    http.Response response;
    try {
      response = await http
          .get(
            uri,
            headers: {
              // Nominatim wajib ada User-Agent yang jelas, kalau kosong bisa di-block
              'User-Agent': 'notaris_app (contact: support@notarisapp.local)',
            },
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const LocationServiceException(
        "Gagal terhubung ke server pencarian. Cek koneksi internet.",
      );
    }

    if (response.statusCode != 200) {
      throw const LocationServiceException(
        "Server pencarian alamat sedang bermasalah, coba lagi nanti.",
      );
    }

    final List<dynamic> results = jsonDecode(response.body);
    if (results.isEmpty) {
      throw const LocationServiceException(
        "Alamat tidak ditemukan. Coba kata kunci lain.",
      );
    }

    final first = results.first as Map<String, dynamic>;
    final lat = double.tryParse(first['lat']?.toString() ?? '');
    final lon = double.tryParse(first['lon']?.toString() ?? '');

    if (lat == null || lon == null) {
      throw const LocationServiceException(
        "Format hasil pencarian tidak valid.",
      );
    }

    return LocationResult(LatLng(lat, lon));
  }
}
