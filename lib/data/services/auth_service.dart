import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final baseUrl = "https://virtserver.swaggerhub.com/MikhaelJhon/notary/1.0.0";

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String company,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/signup");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": name,
        "email": email,
        "password": password,
        "companyName": company,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
}