import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notaris_app/config/base_url.dart';

class ForgotPasswordService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/v1";

  /// Step 1: Kirim kode reset ke email
  static Future<String> requestResetPassword(String email) async {
    final uri = Uri.parse('$baseUrl/request/reset-password');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    print("=== REQUEST RESET PASSWORD ===");
    print("URL: $uri");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Reset password code sent to your email";
    }

    throw Exception(decoded['message'] ?? decoded['error'] ?? "Gagal mengirim kode reset");
  }

  /// Step 2: Verifikasi kode OTP (4 digit) dari email
  static Future<String> verifyCode(String email, String otpCode) async {
    final uri = Uri.parse('$baseUrl/verify/code');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otpCode": otpCode}),
    );

    print("=== VERIFY CODE ===");
    print("URL: $uri");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Email verified successfully";
    }

    throw Exception(decoded['message'] ?? decoded['error'] ?? "Kode verifikasi tidak valid");
  }

  /// Step 3: Reset password pakai kode (5 digit) + password baru
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

    print("=== RESET PASSWORD ===");
    print("URL: $uri");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['message'] ?? "Password reset success, please login";
    }

    throw Exception(decoded['message'] ?? decoded['error'] ?? "Gagal reset password");
  }
}