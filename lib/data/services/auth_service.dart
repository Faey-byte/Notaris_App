import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notaris_app/data/services/logging_service.dart';

class AuthService {
  static const String baseUrl =
      "https://virtually-persian-nevertheless-properties.trycloudflare.com/api/v1";

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/signin");

    final response = await http.post(
      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"email": email, "password": password}),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await LoggingService.saveLoginData(
        token: data['token'],
        email: data['email'],
      );
      return data;
    } else {
      throw Exception(data["message"] ?? "Login gagal");
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    String?
    companyName,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body;
    }

    final errorMessage = body['error'] ?? 'Terjadi kesalahan';

    switch (response.statusCode) {
      case 400:
        throw Exception(
          errorMessage,
        );
      case 429:
        throw Exception('Terlalu banyak permintaan OTP. Tunggu 5 menit.');
      case 500:
      default:
        throw Exception(errorMessage);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify/code');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otpCode': otp,
      }),
    );

    print("VERIFY OTP STATUS: ${response.statusCode}");
    print("VERIFY OTP BODY: ${response.body}");

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    }

    final errorMessage = body['error'] ?? 'Verifikasi OTP gagal';

    switch (response.statusCode) {
      case 400:
        throw Exception(errorMessage);
      case 404:
        throw Exception('User tidak ditemukan');
      case 500:
      default:
        throw Exception(errorMessage);
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final url = Uri.parse('$baseUrl/resend/otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print("RESEND OTP STATUS: ${response.statusCode}");
    print("RESEND OTP BODY: ${response.body}");

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    }

    final errorMessage = body['error'] ?? 'Gagal mengirim ulang OTP';

    switch (response.statusCode) {
      case 400:
        throw Exception(errorMessage);
      case 404:
        throw Exception('User tidak ditemukan');
      case 429:
        throw Exception('Terlalu banyak permintaan. Tunggu 5 menit.');
      case 500:
      default:
        throw Exception(errorMessage);
    }
  }
}