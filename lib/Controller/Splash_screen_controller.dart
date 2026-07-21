import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Routes/routes.dart';

class SplashController extends GetxController {
  static const String _baseUrl =
      'https://sagem-unsigned-auto-games.trycloudflare.com';
  static const String _checkAuthEndpoint = '/api/v1/checkAuth/token';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      await checkAuth();
    });
  }

  Future<void> checkAuth() async {
    try {
      final token = await _getSavedToken();

      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      final isValid = await _verifyToken(token);
      isValid ? _goToHome() : _goToLogin();
    } catch (e) {
      _goToLogin();
    }
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl$_checkAuthEndpoint');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic valid =
            body['authenticated'] ?? body['message'] == "authenticated";
        if (valid is bool) return valid;
        if (valid is String) return valid.toLowerCase() == 'true';
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _goToHome() => Get.offAllNamed(AppRoutes.homepage);

  void _goToLogin() => Get.offAllNamed(AppRoutes.loginpage);
}
