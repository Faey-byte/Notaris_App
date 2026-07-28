import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';

class ProfileService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/v1";

  /// Update profile (nama & tanggal lahir) sesuai struktur backend:
  /// POST body: { currentName, newName, birthDay } (birthDay format: YYYY-MM-DD)
  static Future<String> updateProfile({
    required String token,
    required String currentName,
    required String newName,
    required DateTime birthDay,
  }) async {
    final uri = Uri.parse('$baseUrl/profile/update'); // sesuaikan path route-nya

    final birthDayFormatted =
        "${birthDay.year.toString().padLeft(4, '0')}-"
        "${birthDay.month.toString().padLeft(2, '0')}-"
        "${birthDay.day.toString().padLeft(2, '0')}";

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "currentName": currentName,
        "newName": newName,
        "birthDay": birthDayFormatted,
      }),
    );

    print("=== PROFILE UPDATE ===");
    print("URL: $uri");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Profile updated successfully";
    }

    // Tangani error sesuai daftar error dari backend
    final errorMsg = decoded['message'] ?? decoded['error'] ?? "Gagal update profile";
    throw Exception(errorMsg);
  }
}