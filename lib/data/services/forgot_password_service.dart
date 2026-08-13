import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/utils/logger.dart';

class ForgotPasswordService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/v1";

  static Future<String> requestResetPassword(String email) async {
    final uri = Uri.parse('$baseUrl/request/reset-password');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    AppLogger.log("=== REQUEST RESET PASSWORD ===");
    AppLogger.log("URL: $uri");
    AppLogger.log("Status: ${response.statusCode}");
    AppLogger.log("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Reset password code sent to your email";
    }

    throw Exception(
      decoded['message'] ?? decoded['error'] ?? "Gagal mengirim kode reset",
    );
  }

  static Future<String> verifyCode(String email, String otpCode) async {
    final uri = Uri.parse('$baseUrl/verify/code');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otpCode": otpCode}),
    );

    AppLogger.log("=== VERIFY CODE ===");
    AppLogger.log("URL: $uri");
    AppLogger.log("Status: ${response.statusCode}");
    AppLogger.log("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Email verified successfully";
    }

    throw Exception(
      decoded['message'] ?? decoded['error'] ?? "Kode verifikasi tidak valid",
    );
  }

  static Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
        "newPassword": newPassword,
      }),
    );

    AppLogger.log("=== RESET PASSWORD ===");
    AppLogger.log("URL: $uri");
    AppLogger.log("Status: ${response.statusCode}");
    AppLogger.log("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Password reset success, please login";
    }

    throw Exception(
      decoded['message'] ?? decoded['error'] ?? "Gagal reset password",
    );
  }
}
