import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl =
      "https://ball-catalyst-images-remove.trycloudflare.com/api/v1";

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final url = Uri.parse("$baseUrl/signin");

    final response = await http.post(
      url,

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      return data;

    } else {

      throw Exception(
        data["message"] ?? "Login gagal",
      );
    }
  }

  static Future<Map<String, dynamic>> signup({
  required String username,
  required String email,
  required String password,
  required String companyName,
}) async {

  final url = Uri.parse("$baseUrl/signup");

  final response = await http.post(
    url,

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      "companyName": companyName,
    }),
  );

  print("SIGNUP STATUS: ${response.statusCode}");
  print("SIGNUP BODY: ${response.body}");

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 ||
      response.statusCode == 201) {

    return data;

  } else {

    throw Exception(
      data["message"] ?? "Signup gagal",
    );
  }
}
}